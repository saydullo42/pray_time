import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// "Continue with Google": the Google account's ID token is exchanged with
/// the Django backend for our own JWT pair. There is no password or SMS code.
///
/// [_serverClientId] is the OAuth *web* client id (the same one the backend
/// accepts); pass it with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`. It is
/// what makes Google include an ID token on Android.
class AuthRepository {
  AuthRepository(this._client, this._secureStorage);

  final DioClient _client;
  final SecureStorageService _secureStorage;

  static const _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
  );

  /// Opens Google's account chooser. Returns the signed-in user, or null if
  /// the person closed the chooser without picking an account.
  Future<UserModel?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final idToken = (await account.authentication).idToken;
    if (idToken == null) {
      await _googleSignIn.signOut();
      throw StateError(
        'Google tokeni olinmadi. GOOGLE_SERVER_CLIENT_ID sozlanganini tekshiring.',
      );
    }

    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.googleSignIn,
      data: {'id_token': idToken},
    );
    final data = response.data!;
    await _secureStorage.saveAuthToken(data['access_token'] as String);
    await _secureStorage.saveRefreshToken(data['refresh_token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Permanently deletes the signed-in account and all of its data.
  Future<void> deleteAccount() async {
    await _client.delete(ApiEndpoints.profile);
    await _secureStorage.clearTokens();
    await _signOutOfGoogle();
  }

  Future<void> logout() async {
    await _client.post(ApiEndpoints.logout);
    await _secureStorage.clearTokens();
    await _signOutOfGoogle();
  }

  /// Forget the Google account so the next sign-in shows the chooser again.
  Future<void> _signOutOfGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Not signed in with Google on this device, or Play Services missing.
    }
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
