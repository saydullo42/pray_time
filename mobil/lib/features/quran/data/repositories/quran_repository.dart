import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/surah_model.dart';

/// Fetches Qur'an content metadata (surah list with their pdf/audio/video
/// URLs) from the Django backend; the actual media files are streamed or
/// downloaded on demand from those URLs (backend-hosted storage/CDN).
class QuranRepository {
  QuranRepository(this._client);

  final DioClient _client;

  Future<List<SurahModel>> getSurahs() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.quranSurahs);
    final list = response.data!['results'] as List<dynamic>;
    return list.map((e) => SurahModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ReciterModel>> getReciters() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.quranAudio);
    final list = response.data!['reciters'] as List<dynamic>;
    return list.map((e) => ReciterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Surahs with that specific reciter's audio URL (empty until the
  /// reciter's recitations have been uploaded).
  Future<List<SurahModel>> getReciterSurahs(int reciterId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.reciterSurahAudio(reciterId),
    );
    final list = response.data!['results'] as List<dynamic>;
    return list.map((e) => SurahModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(ref.watch(dioClientProvider));
});
