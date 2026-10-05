import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() {
    return ref.watch(profileRepositoryProvider).getMe();
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(profileRepositoryProvider).updateProfile(
            fullName: fullName,
            avatarUrl: avatarUrl,
          );
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserModel>(
  ProfileNotifier.new,
);
