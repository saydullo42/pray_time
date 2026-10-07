import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quran_page_model.dart';

/// Fetches the Uthmani-script ayah text for a surah from the public
/// alquran.cloud API (not our own backend), grouped by real Mushaf page
/// number so each page matches the standard 604-page printed layout.
class QuranTextRepository {
  QuranTextRepository(this._dio);

  final Dio _dio;

  /// Returns the surah's ayahs grouped by Mushaf page number, in order.
  Future<Map<int, List<QuranAyahText>>> getSurahPages(int surahNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani',
    );
    final ayahs = (response.data!['data'] as Map<String, dynamic>)['ayahs'] as List<dynamic>;

    final pages = <int, List<QuranAyahText>>{};
    for (final raw in ayahs) {
      final ayah = QuranAyahText.fromJson(raw as Map<String, dynamic>);
      pages.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    return pages;
  }
}

final quranTextRepositoryProvider = Provider<QuranTextRepository>((ref) {
  return QuranTextRepository(Dio());
});
