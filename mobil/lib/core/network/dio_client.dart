import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

/// Dio client wired to the Django backend, with auth-token injection,
/// automatic refresh-token retry and logging.
class DioClient {
  DioClient(this._dio, this._secureStorage) {
    _dio.options
      ..baseUrl = ApiEndpoints.backendBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.readAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // An expired access token: swap in a new one using the refresh
          // token and replay the request once.
          final request = error.requestOptions;
          final isAuthCall =
              request.path == ApiEndpoints.googleSignIn ||
              request.path == ApiEndpoints.tokenRefresh;
          if (error.response?.statusCode == 401 &&
              !isAuthCall &&
              request.extra['retried'] != true &&
              await _refreshAccessToken()) {
            request.extra['retried'] = true;
            request.headers['Authorization'] =
                'Bearer ${await _secureStorage.readAuthToken()}';
            try {
              return handler.resolve(await _dio.fetch<dynamic>(request));
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
          handler.next(error);
        },
      ),
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  final Dio _dio;
  final SecureStorageService _secureStorage;

  Dio get raw => _dio;

  /// Exchanges the stored refresh token for a new access token (the backend
  /// also rotates the refresh token). Returns false, and drops the stored
  /// session, if the refresh token is missing or no longer valid.
  Future<bool> _refreshAccessToken() async {
    final refresh = await _secureStorage.readRefreshToken();
    if (refresh == null) return false;
    try {
      final response = await Dio(BaseOptions(baseUrl: _dio.options.baseUrl))
          .post<Map<String, dynamic>>(
            ApiEndpoints.tokenRefresh,
            data: {'refresh': refresh},
          );
      final data = response.data!;
      await _secureStorage.saveAuthToken(data['access'] as String);
      final rotated = data['refresh'] as String?;
      if (rotated != null) await _secureStorage.saveRefreshToken(rotated);
      return true;
    } on DioException catch (e) {
      // Only a rejected refresh token ends the session; being offline doesn't.
      if (e.response?.statusCode == 401) await _secureStorage.clearTokens();
      return false;
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _guard(() => _dio.get<T>(path, queryParameters: query));

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _guard(() => _dio.post<T>(path, data: data));

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _guard(() => _dio.put<T>(path, data: data));

  Future<Response<T>> patch<T>(String path, {Object? data}) =>
      _guard(() => _dio.patch<T>(path, data: data));

  Future<Response<T>> delete<T>(String path, {Object? data}) =>
      _guard(() => _dio.delete<T>(path, data: data));

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ApiException.timeout();
        case DioExceptionType.connectionError:
          throw ApiException.network();
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) throw ApiException.unauthorized();
          throw ApiException.unknown(_extractMessage(e.response?.data));
        default:
          throw ApiException.unknown(e.message);
      }
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['detail'] ?? data['message'])?.toString();
    }
    return null;
  }
}

final dioProvider = Provider<Dio>((ref) => Dio());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    ref.watch(dioProvider),
    ref.watch(secureStorageServiceProvider),
  );
});
