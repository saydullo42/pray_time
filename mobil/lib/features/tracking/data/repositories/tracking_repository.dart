import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/prayer_tracking_model.dart';

class TrackingRepository {
  TrackingRepository(this._client);

  final DioClient _client;

  Future<DailyTrackingModel> getDaily(DateTime date) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.trackingDaily,
      query: {'date': date.toIso8601String().split('T').first},
    );
    return DailyTrackingModel.fromJson(response.data!);
  }

  /// Bulk-saves one day's checkboxes, e.g. {'Bomdod': true, 'Vitr': false}.
  Future<void> saveDailyChecklist({
    required DateTime date,
    required Map<String, bool> checklist,
  }) async {
    final data = <String, dynamic>{
      'date': date.toIso8601String().split('T').first,
    };
    checklist.forEach((prayer, done) => data[prayer.toLowerCase()] = done);

    await _client.post(ApiEndpoints.trackingDailyChecklist, data: data);
  }

  /// Day-of-month -> number of prayers marked done, for calendar coloring.
  Future<Map<int, int>> getMonthCalendarCounts({required int year, required int month}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.trackingCalendar,
      query: {'year': year, 'month': month},
    );
    final results = response.data!['results'] as Map<String, dynamic>;
    return results.map((key, value) => MapEntry(DateTime.parse(key).day, value as int));
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(ref.watch(dioClientProvider));
});
