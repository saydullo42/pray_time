import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/storage/local_storage_service.dart';
import 'package:mobil/features/tracking/presentation/providers/roza_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
    ],
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with nothing marked', () async {
    final container = await _container();
    expect(container.read(rozaProvider), isEmpty);
  });

  test('marks and unmarks a day', () async {
    final container = await _container();
    final notifier = container.read(rozaProvider.notifier);

    await notifier.setDone(2026, 4, true);
    await notifier.setDone(2026, 1, true);
    expect(container.read(rozaProvider)[2026], {1, 4});

    await notifier.setDone(2026, 4, false);
    expect(container.read(rozaProvider)[2026], {1});
  });

  test('marked days are kept on the device and loaded again', () async {
    final first = await _container();
    await first.read(rozaProvider.notifier).setDone(2025, 30, true);
    await first.read(rozaProvider.notifier).setDone(2025, 2, true);
    await first.read(rozaProvider.notifier).setDone(1990, 15, true);

    final second = await _container(); // a fresh start of the app
    expect(second.read(rozaProvider)[2025], {2, 30});
    expect(second.read(rozaProvider)[1990], {15});
  });

  test('years are independent', () async {
    final container = await _container();
    await container.read(rozaProvider.notifier).setDone(2026, 5, true);
    expect(container.read(rozaProvider)[2025], isNull);
  });
}
