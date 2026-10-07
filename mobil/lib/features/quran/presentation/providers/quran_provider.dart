import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quran_page_model.dart';
import '../../data/models/quran_translation_model.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/repositories/quran_text_repository.dart';
import '../../data/repositories/quran_translation_repository.dart';

final surahListProvider = FutureProvider.autoDispose<List<SurahModel>>((ref) {
  return ref.watch(quranRepositoryProvider).getSurahs();
});

final surahPagesProvider = FutureProvider.autoDispose
    .family<Map<int, List<QuranAyahText>>, int>((ref, surahNumber) {
  return ref.watch(quranTextRepositoryProvider).getSurahPages(surahNumber);
});

final surahTranslationPagesProvider = FutureProvider.autoDispose
    .family<Map<int, List<QuranTranslationAyah>>, int>((ref, surahNumber) {
  return ref.watch(quranTranslationRepositoryProvider).getSurahPages(surahNumber);
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
