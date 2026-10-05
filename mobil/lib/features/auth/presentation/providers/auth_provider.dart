import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AuthOtpSent extends AuthState {
  const AuthOtpSent(this.phoneNumber);
  final String phoneNumber;
}

class AuthNeedsRegistration extends AuthState {
  const AuthNeedsRegistration(this.user);
  final UserModel user;
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

  Future<void> requestOtp(String phoneNumber) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.requestOtp(phoneNumber);
      return AuthOtpSent(phoneNumber);
    });
  }

  Future<void> verifyOtp({required String phoneNumber, required String code}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.verifyOtp(phoneNumber: phoneNumber, code: code);
      return result.isNewUser
          ? AuthNeedsRegistration(result.user)
          : AuthAuthenticated(result.user);
    });
  }

  Future<void> completeRegistration(String fullName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.completeRegistration(fullName: fullName);
      return AuthAuthenticated(user);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.logout();
      return const AuthUnauthenticated();
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
