import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for non-sensitive local data
/// (theme mode, selected city, calculation method, onboarding flags, ...).
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}

/// Must be overridden in main() with the resolved SharedPreferences instance
/// before the app is run (see lib/main.dart).
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider was not overridden');
});
