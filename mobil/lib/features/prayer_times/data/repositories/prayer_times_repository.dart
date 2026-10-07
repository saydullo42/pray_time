import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/calculation_method.dart';
import '../models/custom_prayer_time_model.dart';
import '../models/prayer_time_model.dart';

/// Fetches backend-computed prayer times (the backend proxies Aladhan) for
/// the selected location. Custom overrides are fetched/displayed separately
/// (see [getCustomOverrides]) rather than baked in here, so the computed
/// table always reflects the currently selected viloyat/tuman.
class PrayerTimesRepository {
  PrayerTimesRepository(this._client);

  final DioClient _client;

  Future<PrayerTimeModel> getTodayTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    CalculationMethod method = CalculationMethod.muslimWorldLeague,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.prayerTimesToday,
      query: {
        'latitude': latitude,
        'longitude': longitude,
        'date': _formatDate(date),
        'method': method.id,
      },
    );
    return PrayerTimeModel.fromJson(response.data!);
  }

  Future<List<PrayerTimeModel>> getMonthlyTimes({
    required double latitude,
    required double longitude,
    required int month,
    required int year,
    CalculationMethod method = CalculationMethod.muslimWorldLeague,
  }) async {
    final response = await _client.get<List<dynamic>>(
      ApiEndpoints.prayerTimesMonthly,
      query: {
        'latitude': latitude,
        'longitude': longitude,
        'month': month,
        'year': year,
        'method': method.id,
      },
    );
    return (response.data ?? const [])
        .map((e) => PrayerTimeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomPrayerTimeModel> getCustomOverrides() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.customPrayerTimes,
    );
    return CustomPrayerTimeModel.fromJson(response.data ?? const {});
  }

  Future<void> saveCustomOverrides(CustomPrayerTimeModel overrides) async {
    await _client.put(ApiEndpoints.customPrayerTimes, data: overrides.toJson());
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  return PrayerTimesRepository(ref.watch(dioClientProvider));
});
