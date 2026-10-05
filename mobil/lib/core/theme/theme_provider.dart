import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage_service.dart';

/// Persisted app theme mode (system / light / dark).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.read(localStorageServiceProvider).getString(
          AppConstants.keyThemeMode,
        );
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(localStorageServiceProvider)
        .setString(AppConstants.keyThemeMode, mode.name);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
