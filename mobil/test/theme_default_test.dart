import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobil/core/storage/local_storage_service.dart';
import 'package:mobil/core/theme/theme_provider.dart';

Future<ProviderContainer> _container(Map<String, Object> stored) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('a fresh install starts in dark mode', () async {
    final c = await _container({});
    expect(c.read(themeModeProvider), ThemeMode.dark);
  });

  test('a saved light choice is kept', () async {
    final c = await _container({'theme_mode': 'light'});
    expect(c.read(themeModeProvider), ThemeMode.light);
  });

  test('a saved system choice still follows the system', () async {
    final c = await _container({'theme_mode': 'system'});
    expect(c.read(themeModeProvider), ThemeMode.system);
  });
}
