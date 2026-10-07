import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quran_translation_model.dart';

/// Fetches the Uzbek translation (Muhammad Sodik Muhammad Yusuf, edition
/// `uz.sodik`) for a surah from the public alquran.cloud API, grouped by
/// real Mushaf page number so each page matches the standard 604-page
/// printed layout — same pagination the Arabic reader uses.
class QuranTranslationRepository {
  QuranTranslationRepository(this._dio);

  final Dio _dio;

  Future<Map<int, List<QuranTranslationAyah>>> getSurahPages(int surahNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.alquran.cloud/v1/surah/$surahNumber/uz.sodik',
    );
    final ayahs = (response.data!['data'] as Map<String, dynamic>)['ayahs'] as List<dynamic>;

    final pages = <int, List<QuranTranslationAyah>>{};
    for (final raw in ayahs) {
      final ayah = QuranTranslationAyah.fromJson(raw as Map<String, dynamic>);
      pages.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    return pages;
  }
}

final quranTranslationRepositoryProvider = Provider<QuranTranslationRepository>((ref) {
  return QuranTranslationRepository(Dio());
});
