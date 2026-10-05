import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';

final surahListProvider = FutureProvider.autoDispose<List<SurahModel>>((ref) {
  return ref.watch(quranRepositoryProvider).getSurahs();
});

final reciterListProvider = FutureProvider.autoDispose<List<ReciterModel>>((ref) {
  return ref.watch(quranRepositoryProvider).getReciters();
});

final selectedReciterProvider = StateProvider<ReciterModel?>((ref) => null);

final reciterSurahsProvider = FutureProvider.autoDispose.family<List<SurahModel>, int>((
  ref,
  reciterId,
) {
  return ref.watch(quranRepositoryProvider).getReciterSurahs(reciterId);
});
