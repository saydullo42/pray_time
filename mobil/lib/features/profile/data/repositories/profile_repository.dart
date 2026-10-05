import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final DioClient _client;

  Future<UserModel> getMe() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.profile);
    return UserModel.fromJson(response.data!);
  }

  Future<UserModel> updateProfile({String? fullName, String? avatarUrl}) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: {
        'full_name': ?fullName,
        'avatar_url': ?avatarUrl,
      },
    );
    return UserModel.fromJson(response.data!);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioClientProvider));
});
