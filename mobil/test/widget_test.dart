import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobil/app.dart';
import 'package:mobil/core/storage/local_storage_service.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
        ],
        child: const NamozVaqtlariApp(),
      ),
    );

    expect(find.text('Namoz Vaqtlari'), findsWidgets);
  });
}
