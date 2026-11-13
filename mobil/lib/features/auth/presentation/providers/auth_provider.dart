import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifications/data/services/notification_scheduler.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user, {this.isNewUser = false});
  final UserModel user;

  /// True right after the account was created (the app then asks for the region).
  final bool isNewUser;

  /// The viloyat and tuman are asked right after sign-in when the account has
  /// none saved: a brand-new account, or one made on the website (which does
  /// not save a location), so the saved location is always applied afterwards.
  bool get needsLocation => isNewUser || !user.hasLocation;
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;

  @override
  Future<AuthState> build() async {
    _repository = ref.watch(authRepositoryProvider);
    final hasSession = await _repository.hasValidSession();
    return hasSession ? const AuthInitial() : const AuthUnauthenticated();
  }

  /// Runs Google sign-in. Closing the account chooser leaves the state as
  /// [AuthUnauthenticated] without an error.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.signInWithGoogle();
      return result == null
          ? const AuthUnauthenticated()
          : AuthAuthenticated(result.user, isNewUser: result.isNewUser);
    });
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteAccount();
      await ref.read(notificationSchedulerProvider).cancelAll();
      return const AuthUnauthenticated();
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.logout();
      await ref.read(notificationSchedulerProvider).cancelAll();
      return const AuthUnauthenticated();
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
