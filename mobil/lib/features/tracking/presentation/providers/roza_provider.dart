import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage_service.dart';

/// Fasting (ro'za) days marked as kept, per year: year -> set of day numbers
/// (1-30). Kept on the device only for now (no backend endpoint yet).
class RozaNotifier extends Notifier<Map<int, Set<int>>> {
  static const _keyPrefix = 'roza_days_';
  static const _firstYear = 1940;

  @override
  Map<int, Set<int>> build() {
    final storage = ref.read(localStorageServiceProvider);
    final result = <int, Set<int>>{};
    for (var year = _firstYear; year <= DateTime.now().year; year++) {
      final raw = storage.getString('$_keyPrefix$year');
      if (raw == null || raw.isEmpty) continue;
      result[year] = raw.split(',').map(int.parse).toSet();
    }
    return result;
  }

  Future<void> setDone(int year, int day, bool done) async {
    final days = {...(state[year] ?? <int>{})};
    done ? days.add(day) : days.remove(day);
    state = {...state, year: days};
    final sorted = days.toList()..sort();
    await ref
        .read(localStorageServiceProvider)
        .setString('$_keyPrefix$year', sorted.join(','));
  }
}

final rozaProvider = NotifierProvider<RozaNotifier, Map<int, Set<int>>>(
  RozaNotifier.new,
);
