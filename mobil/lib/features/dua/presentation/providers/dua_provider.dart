import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dua_model.dart';
import '../../data/repositories/dua_repository.dart';

final duaCategoriesProvider = FutureProvider.autoDispose<List<DuaCategoryModel>>((ref) {
  return ref.watch(duaRepositoryProvider).getCategories();
});

final duasByCategoryProvider =
    FutureProvider.autoDispose.family<List<DuaModel>, String>((ref, categoryId) {
  return ref.watch(duaRepositoryProvider).getDuasByCategory(categoryId);
});
