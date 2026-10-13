import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quran_page_model.dart';

/// Fetches the Uthmani-script ayah text for a surah from the public
/// alquran.cloud API (not our own backend), grouped by real Mushaf page
/// number so each page matches the standard 604-page printed layout.
/// The basmala is part of the first ayah's text in this API for every surah
/// except al-Fatiha (where it *is* ayah 1) and at-Tawba (which has none).
const quranBasmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

bool surahShowsBasmala(int surahNumber) => surahNumber != 1 && surahNumber != 9;

class QuranTextRepository {
  QuranTextRepository(this._dio);

  final Dio _dio;

  /// Returns the surah's ayahs grouped by Mushaf page number, in order.
  Future<Map<int, List<QuranAyahText>>> getSurahPages(int surahNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani',
    );
    final ayahs =
        (response.data!['data'] as Map<String, dynamic>)['ayahs']
            as List<dynamic>;

    final pages = <int, List<QuranAyahText>>{};
    for (final raw in ayahs) {
      var ayah = QuranAyahText.fromJson(raw as Map<String, dynamic>);
      if (ayah.numberInSurah == 1 && surahShowsBasmala(surahNumber)) {
        // Drop the leading four basmala words; it is shown as its own line.
        final words = ayah.text.trim().split(' ');
        if (words.length > 4) {
          ayah = QuranAyahText(
            numberInSurah: ayah.numberInSurah,
            text: words.skip(4).join(' '),
            page: ayah.page,
          );
        }
      }
      pages.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    return pages;
  }
}

final quranTextRepositoryProvider = Provider<QuranTextRepository>((ref) {
  return QuranTextRepository(Dio());
});
