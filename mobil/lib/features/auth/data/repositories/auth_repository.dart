import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// Handles the SMS OTP auth flow against the Django backend, which in turn
/// delivers the SMS via Eskiz.uz. There is no password: a phone number is
/// verified with a one-time code for both login and registration.
class AuthRepository {
  AuthRepository(this._client, this._secureStorage);

  final DioClient _client;
  final SecureStorageService _secureStorage;

  /// Requests the backend to send an OTP code to [phoneNumber] via Eskiz.uz.
  Future<void> requestOtp(String phoneNumber) async {
    await _client.post(
      ApiEndpoints.requestOtp,
      data: {'phone_number': phoneNumber},
    );
  }

  /// Verifies the OTP and returns the authenticated user.
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {'phone_number': phoneNumber, 'code': code},
    );
    final data = response.data!;
    await _secureStorage.saveAuthToken(data['access_token'] as String);
    await _secureStorage.saveRefreshToken(data['refresh_token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.post(ApiEndpoints.logout);
    await _secureStorage.clearTokens();
  }

  Future<bool> hasValidSession() async {
    final token = await _secureStorage.readAuthToken();
    return token != null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioClientProvider),
    ref.watch(secureStorageServiceProvider),
  );
});
