import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/network/api_exception.dart';
import 'package:mobil/core/network/dio_client.dart';
import 'package:mobil/core/storage/secure_storage_service.dart';

class _MemorySecureStorage extends Fake implements SecureStorageService {
  String? access;
  String? refresh;

  @override
  Future<String?> readAuthToken() async => access;
  @override
  Future<String?> readRefreshToken() async => refresh;
  @override
  Future<void> saveAuthToken(String token) async => access = token;
  @override
  Future<void> saveRefreshToken(String token) async => refresh = token;
  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }
}

/// A tiny stand-in for the backend: `/users/me/` needs the current access
/// token, `/auth/token/refresh/` rotates the tokens and blacklists the old
/// refresh token, exactly like simplejwt with ROTATE + BLACKLIST_AFTER_ROTATION.
class _FakeBackend implements HttpClientAdapter {
  String validAccess = 'access-2';
  String validRefresh = 'refresh-1';
  int refreshCalls = 0;
  int meCalls = 0;
  bool refreshOffline = false;
  bool alwaysUnauthorized = false;

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));

    if (options.path == '/auth/token/refresh/') {
      refreshCalls++;
      if (refreshOffline) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      final sent = (options.data as Map)['refresh'];
      if (sent != validRefresh) return _json(401, {'detail': 'blacklisted'});
      validRefresh = 'refresh-${refreshCalls + 1}';
      validAccess = 'access-${refreshCalls + 2}';
      return _json(200, {'access': validAccess, 'refresh': validRefresh});
    }

    meCalls++;
    final ok =
        !alwaysUnauthorized &&
        options.headers['Authorization'] == 'Bearer $validAccess';
    return ok
        ? _json(200, {'email': 'a@example.com'})
        : _json(401, {'detail': 'expired'});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeBackend backend;
  late _MemorySecureStorage storage;
  late DioClient client;

  setUp(() {
    backend = _FakeBackend();
    storage = _MemorySecureStorage()
      ..access =
          'access-1' // expired
      ..refresh = 'refresh-1';
    final dio = Dio()..httpClientAdapter = backend;
    client = DioClient(dio, storage);
  });

  test('a valid access token is used as is, with no refresh', () async {
    storage.access = 'access-2';
    final response = await client.get<Map<String, dynamic>>('/users/me/');
    expect(response.data!['email'], 'a@example.com');
    expect(backend.refreshCalls, 0);
  });

  test(
    'an expired access token is refreshed and the request replayed',
    () async {
      final response = await client.get<Map<String, dynamic>>('/users/me/');
      expect(response.statusCode, 200);
      expect(backend.refreshCalls, 1);
      expect(storage.access, 'access-3');
      expect(storage.refresh, 'refresh-2'); // the rotated refresh token is kept
    },
  );

  test('parallel requests share ONE refresh and none of them fails', () async {
    final responses = await Future.wait([
      for (var i = 0; i < 12; i++)
        client.get<Map<String, dynamic>>('/users/me/'),
    ]);
    expect(responses.every((r) => r.statusCode == 200), isTrue);
    expect(
      backend.refreshCalls,
      1,
      reason: 'a second refresh would use a blacklisted token',
    );
    expect(storage.refresh, isNotNull, reason: 'the session must survive');
  });

  test('a rejected refresh token ends the session', () async {
    storage.refresh = 'revoked';
    await expectLater(
      client.get<Map<String, dynamic>>('/users/me/'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
    expect(storage.access, isNull);
    expect(storage.refresh, isNull);
  });

  test('being offline during the refresh keeps the session', () async {
    backend.refreshOffline = true;
    await expectLater(
      client.get<Map<String, dynamic>>('/users/me/'),
      throwsA(isA<ApiException>()),
    );
    expect(storage.refresh, 'refresh-1');
    expect(storage.access, 'access-1');
  });

  test(
    'a request that is still rejected after refreshing is not retried forever',
    () async {
      backend.alwaysUnauthorized = true;
      await expectLater(
        client.get<Map<String, dynamic>>('/users/me/'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
      expect(backend.refreshCalls, 1);
      expect(backend.meCalls, 2); // the original + one replay
    },
  );

  test('no stored refresh token means no refresh attempt', () async {
    storage.refresh = null;
    await expectLater(
      client.get<Map<String, dynamic>>('/users/me/'),
      throwsA(isA<ApiException>()),
    );
    expect(backend.refreshCalls, 0);
  });
}
