import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prayer_tracking_model.dart';
import '../../data/repositories/tracking_repository.dart';

final selectedTrackingDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dailyTrackingProvider =
    FutureProvider.autoDispose.family<DailyTrackingModel, DateTime>((ref, date) {
  return ref.watch(trackingRepositoryProvider).getDaily(date);
});

/// Day-of-month -> completed prayer count, for the given (year, month), used
/// to color the home screen's monthly calendar cells.
final monthCalendarCountsProvider = FutureProvider.autoDispose
    .family<Map<int, int>, ({int year, int month})>((ref, args) {
  return ref
      .watch(trackingRepositoryProvider)
      .getMonthCalendarCounts(year: args.year, month: args.month);
});

/// Month (1-12) -> day-of-month -> completed prayer count, for every month
/// of the given year, used by the "Yillik" year-at-a-glance calendar grid.
final yearlyCalendarCountsProvider =
    FutureProvider.autoDispose.family<Map<int, Map<int, int>>, int>((ref, year) async {
  final repository = ref.watch(trackingRepositoryProvider);
  final results = await Future.wait([
    for (var month = 1; month <= 12; month++)
      repository.getMonthCalendarCounts(year: year, month: month),
  ]);
  return {for (var month = 1; month <= 12; month++) month: results[month - 1]};
});

class TrackingActions {
  TrackingActions(this._ref);
  final Ref _ref;

  Future<void> saveDailyChecklist({
    required DateTime date,
    required Map<String, bool> checklist,
  }) async {
    await _ref.read(trackingRepositoryProvider).saveDailyChecklist(
          date: date,
          checklist: checklist,
        );
    _ref.invalidate(dailyTrackingProvider);
    _ref.invalidate(monthCalendarCountsProvider);
    _ref.invalidate(yearlyCalendarCountsProvider);
  }
}

final trackingActionsProvider = Provider((ref) => TrackingActions(ref));
