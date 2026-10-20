import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/storage/local_storage_service.dart';
import 'package:mobil/features/tracking/data/repositories/tracking_repository.dart';
import 'package:mobil/features/tracking/presentation/providers/roza_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A server with its own storage; can be switched offline.
class _FakeServer implements TrackingRepository {
  _FakeServer({this.userId = 1, Map<int, Set<int>>? years})
    : years = years ?? {};

  int userId;
  Map<int, Set<int>> years;
  bool offline = false;
  int saves = 0;

  /// While set, getRoza() waits for it (a slow network).
  Completer<void>? gate;

  @override
  Future<({int userId, Map<int, Set<int>> years})> getRoza() async {
    // The answer is what the server held when the request arrived, even if
    // the reply is slow.
    final answer = (
      userId: userId,
      years: {
        for (final e in years.entries) e.key: {...e.value},
      },
    );
    await gate?.future;
    if (offline) throw Exception('offline');
    return answer;
  }

  @override
  Future<void> saveRozaYear(int year, Set<int> days) async {
    if (offline) throw Exception('offline');
    saves++;
    days.isEmpty ? years.remove(year) : years[year] = {...days};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> _container(_FakeServer server) async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
      trackingRepositoryProvider.overrideWithValue(server),
    ],
  );
}

/// Lets the background sync / upload finish.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with nothing marked', () async {
    final container = await _container(_FakeServer());
    expect(container.read(rozaProvider), isEmpty);
  });

  test('marks and unmarks a day', () async {
    final container = await _container(_FakeServer());
    final notifier = container.read(rozaProvider.notifier);

    await notifier.setDone(2026, 4, true);
    await notifier.setDone(2026, 1, true);
    expect(container.read(rozaProvider)[2026], {1, 4});

    await notifier.setDone(2026, 4, false);
    expect(container.read(rozaProvider)[2026], {1});
  });

  test('years are independent', () async {
    final container = await _container(_FakeServer());
    await container.read(rozaProvider.notifier).setDone(2026, 5, true);
    expect(container.read(rozaProvider)[2025], isNull);
  });

  test('marked days are sent to the server', () async {
    final server = _FakeServer();
    final container = await _container(server);
    await container.read(rozaProvider.notifier).setDone(2026, 3, true);
    await container.read(rozaProvider.notifier).setDone(2026, 1, true);
    await _settle();
    expect(server.years, {
      2026: {1, 3},
    });

    await container.read(rozaProvider.notifier).setDone(2026, 3, false);
    await container.read(rozaProvider.notifier).setDone(2026, 1, false);
    await _settle();
    expect(server.years, isEmpty); // an emptied year is cleared on the server
  });

  test('marked days are kept on the device and loaded again', () async {
    final server = _FakeServer()..offline = true;
    final first = await _container(server);
    await first.read(rozaProvider.notifier).setDone(2025, 30, true);
    await first.read(rozaProvider.notifier).setDone(2025, 2, true);
    await first.read(rozaProvider.notifier).setDone(1990, 15, true);

    final second = await _container(server); // a fresh start of the app
    expect(second.read(rozaProvider)[2025], {2, 30});
    expect(second.read(rozaProvider)[1990], {15});
  });

  test('a new device shows what the server has', () async {
    final server = _FakeServer(
      years: {
        2026: {1, 2, 3},
        2025: {30},
      },
    );
    final container = await _container(server);
    container.read(rozaProvider);
    await _settle();
    await _settle();
    expect(container.read(rozaProvider), {
      2026: {1, 2, 3},
      2025: {30},
    });
  });

  test(
    'days already on the device are added to the server the first time',
    () async {
      SharedPreferences.setMockInitialValues({'roza_days_2026': '1,2'});
      final server = _FakeServer(
        years: {
          2026: {2, 9},
        },
      );
      final container = await _container(server);
      container.read(rozaProvider);
      await _settle();
      await _settle();
      expect(container.read(rozaProvider)[2026], {1, 2, 9});
      expect(server.years[2026], {1, 2, 9});
    },
  );

  test(
    'after the first sync the server wins (a removal on another device sticks)',
    () async {
      final server = _FakeServer(
        years: {
          2026: {1, 2},
        },
      );
      final first = await _container(server);
      first.read(rozaProvider);
      await _settle();
      await _settle();

      server.years = {
        2026: {1},
      }; // day 2 was unmarked on another device
      final second = await _container(server);
      second.read(rozaProvider);
      await _settle();
      await _settle();
      expect(second.read(rozaProvider)[2026], {1});
      expect(server.years[2026], {1});
    },
  );

  test('a change made offline is sent when the network is back', () async {
    final server = _FakeServer()..offline = true;
    final first = await _container(server);
    await first.read(rozaProvider.notifier).setDone(2026, 7, true);
    await _settle();
    expect(server.years, isEmpty);

    server.offline = false;
    final second = await _container(server); // next start of the app
    second.read(rozaProvider);
    await _settle();
    await _settle();
    expect(server.years[2026], {7});
    expect(second.read(rozaProvider)[2026], {7});
  });

  test("another account's cached days are dropped, not merged", () async {
    final other = _FakeServer(userId: 1);
    final first = await _container(other);
    await first.read(rozaProvider.notifier).setDone(2026, 1, true);
    await _settle();
    await _settle();

    final mine = _FakeServer(
      userId: 2,
      years: {
        2025: {5},
      },
    );
    final second = await _container(mine);
    second.read(rozaProvider);
    await _settle();
    await _settle();
    expect(second.read(rozaProvider), {
      2025: {5},
    });
    expect(mine.years, {
      2025: {5},
    });
  });

  test('a sync that was running does not overwrite a newer change', () async {
    // Already synced once, so the server's list is what a sync would adopt.
    SharedPreferences.setMockInitialValues({
      'roza_synced': true,
      'roza_owner': '1',
    });
    final server = _FakeServer(
      years: {
        2026: {1},
      },
    )..gate = Completer<void>();
    final container = await _container(server);
    final notifier = container.read(
      rozaProvider.notifier,
    ); // sync starts, waits
    await _settle();

    await notifier.setDone(2026, 9, true); // changed while the server is slow
    server.gate!.complete();
    await _settle();
    await _settle();
    expect(container.read(rozaProvider)[2026], contains(9));
  });
}
