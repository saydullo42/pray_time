import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../data/repositories/tracking_repository.dart';

/// Fasting (ro'za) days marked as kept, per year: year -> set of day numbers
/// (1-30). They are saved on the server and cached on the device, so they show
/// up at once and still work offline.
///
/// - The first time on a device, the days already marked here are added to the
///   server's (nothing is lost); after that the server is the source of truth.
/// - A change that could not be sent (offline) is remembered and sent later.
/// - Days cached for another account are dropped, never merged.
class RozaNotifier extends Notifier<Map<int, Set<int>>> {
  static const _keyPrefix = 'roza_days_';
  static const _syncedKey = 'roza_synced';
  static const _dirtyKey = 'roza_dirty';
  static const _ownerKey = 'roza_owner';
  static const _firstYear = 1940;

  // Counts the changes made, so a sync that was already in flight does not
  // overwrite a change made meanwhile.
  int _edits = 0;

  @override
  Map<int, Set<int>> build() {
    Future.microtask(sync);
    return _loadLocal();
  }

  LocalStorageService get _storage => ref.read(localStorageServiceProvider);

  Map<int, Set<int>> _loadLocal() {
    final result = <int, Set<int>>{};
    for (var year = _firstYear; year <= DateTime.now().year; year++) {
      final raw = _storage.getString('$_keyPrefix$year');
      if (raw == null || raw.isEmpty) continue;
      result[year] = raw.split(',').map(int.parse).toSet();
    }
    return result;
  }

  Future<void> _saveLocal(int year, Set<int> days) {
    final sorted = days.toList()..sort();
    return _storage.setString('$_keyPrefix$year', sorted.join(','));
  }

  Set<int> _readDirty() {
    final raw = _storage.getString(_dirtyKey);
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as List<dynamic>).map((y) => y as int).toSet();
  }

  Future<void> _writeDirty(Set<int> years) =>
      _storage.setString(_dirtyKey, jsonEncode(years.toList()));

  Future<bool> _push(int year, Set<int> days) async {
    try {
      await ref.read(trackingRepositoryProvider).saveRozaYear(year, days);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pulls the days from the server and sends up what the server lacks.
  /// Does nothing while offline.
  Future<void> sync() async {
    final edits = _edits;
    final ({int userId, Map<int, Set<int>> years}) server;
    try {
      server = await ref.read(trackingRepositoryProvider).getRoza();
    } catch (_) {
      return;
    }

    // Days cached for another account must not leak into this one.
    final owner = _storage.getString(_ownerKey);
    if (owner != null && owner != '${server.userId}') {
      for (var year = _firstYear; year <= DateTime.now().year; year++) {
        await _storage.remove('$_keyPrefix$year');
      }
      await _storage.remove(_dirtyKey);
      await _storage.remove(_syncedKey);
    }
    await _storage.setString(_ownerKey, '${server.userId}');

    final local = _loadLocal();
    final dirty = _readDirty();
    final firstSync = _storage.getBool(_syncedKey) != true;

    final merged = <int, Set<int>>{};
    final toPush = <int>[];
    for (final year in {...server.years.keys, ...local.keys}) {
      final fromServer = server.years[year] ?? <int>{};
      final fromHere = local[year] ?? <int>{};
      if (dirty.contains(year)) {
        merged[year] = fromHere; // unsent changes win
        toPush.add(year);
      } else if (firstSync) {
        merged[year] = {...fromServer, ...fromHere};
        if (merged[year]!.length != fromServer.length) toPush.add(year);
      } else {
        merged[year] = fromServer;
      }
    }

    final stillDirty = <int>{};
    for (final year in toPush) {
      if (!await _push(year, merged[year]!)) stillDirty.add(year);
    }
    await _writeDirty(stillDirty);
    if (stillDirty.isEmpty) await _storage.setBool(_syncedKey, true);

    // Changed meanwhile: that change is already saved, keep it.
    if (_edits != edits) return;
    for (final entry in merged.entries) {
      await _saveLocal(entry.key, entry.value);
    }
    state = merged;
  }

  Future<void> setDone(int year, int day, bool done) async {
    final days = {...(state[year] ?? <int>{})};
    done ? days.add(day) : days.remove(day);
    _edits++;
    state = {...state, year: days};
    await _saveLocal(year, days);

    // Sent in the background: the screen must not wait for the network.
    unawaited(_sendYear(year, days));
  }

  Future<void> _sendYear(int year, Set<int> days) async {
    final ok = await _push(year, days);
    final dirty = _readDirty();
    ok ? dirty.remove(year) : dirty.add(year);
    await _writeDirty(dirty);
  }
}

final rozaProvider = NotifierProvider<RozaNotifier, Map<int, Set<int>>>(
  RozaNotifier.new,
);
