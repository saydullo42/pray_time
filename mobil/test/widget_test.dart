import 'dart:ui' show Size;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobil/app.dart';
import 'package:mobil/core/storage/local_storage_service.dart';
import 'package:mobil/core/storage/secure_storage_service.dart';

/// A secure storage with nothing saved: the app is opened for the first time.
class _EmptySecureStorage extends Fake implements SecureStorageService {
  @override
  Future<String?> readAuthToken() async => null;
}

void main() {
  testWidgets('A first launch (no saved session) opens the login screen', (
    WidgetTester tester,
  ) async {
    // The test font is wider than real text, so use a roomy screen.
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(
            LocalStorageService(prefs),
          ),
          secureStorageServiceProvider.overrideWithValue(_EmptySecureStorage()),
        ],
        child: const NamozVaqtlariApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google orqali kirish'), findsOneWidget);
  });
}
