import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Wrapper around [FlutterSecureStorage] for sensitive data such as
/// auth/refresh tokens.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: AppConstants.keyAuthToken, value: token);

  Future<String?> readAuthToken() =>
      _storage.read(key: AppConstants.keyAuthToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.keyRefreshToken, value: token);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});
