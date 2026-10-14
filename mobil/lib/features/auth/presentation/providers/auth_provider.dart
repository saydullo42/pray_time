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
  const AuthAuthenticated(this.user);
  final UserModel user;
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
      final user = await _repository.signInWithGoogle();
      return user == null
          ? const AuthUnauthenticated()
          : AuthAuthenticated(user);
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
