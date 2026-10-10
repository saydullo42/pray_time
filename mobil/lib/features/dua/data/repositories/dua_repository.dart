import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dua_model.dart';

class DuaRepository {
  DuaRepository(this._client);

  final DioClient _client;

  Future<List<DuaCategoryModel>> getCategories() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.duaCategories,
    );
    final list = response.data!['results'] as List<dynamic>;
    return list
        .map((e) => DuaCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DuaModel>> getDuasByCategory(String categoryId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.duaList,
      query: {'category_id': categoryId},
    );
    final list = response.data!['results'] as List<dynamic>;
    return list
        .map((e) => DuaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return DuaRepository(ref.watch(dioClientProvider));
});
