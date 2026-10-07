import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/local_storage_service.dart';
import 'features/notifications/data/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('uz');

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NamozVaqtlariApp(),
    ),
  );

  // Runs after the first frame so engine/plugin setup can't hold up the
  // native splash screen's dismissal.
  await container.read(localNotificationServiceProvider).init();
}
