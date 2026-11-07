import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/uzbekistan_regions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class RegionSelection {
  const RegionSelection({
    required this.regionName,
    required this.districtName,
    required this.latitude,
    required this.longitude,
  });

  final String regionName;
  final String districtName;
  final double latitude;
  final double longitude;
}

/// User-picked viloyat/tuman, persisted locally, used to compute prayer
/// times instead of device GPS.
class RegionSelectionNotifier extends Notifier<RegionSelection> {
  @override
  RegionSelection build() {
    final storage = ref.read(localStorageServiceProvider);
    final regionName =
        storage.getString(AppConstants.keySelectedRegion) ?? defaultRegionName;
    final districtName =
        storage.getString(AppConstants.keySelectedDistrict) ??
        defaultDistrictName;

    final district =
        findDistrict(regionName, districtName) ??
        findRegion(regionName)?.districts.first ??
        findDistrict(defaultRegionName, defaultDistrictName)!;

    return RegionSelection(
      regionName: regionName,
      districtName: district.name,
      latitude: district.latitude,
      longitude: district.longitude,
    );
  }

  Future<void> _applyLocally(String regionName, District district) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setString(AppConstants.keySelectedRegion, regionName);
    await storage.setString(AppConstants.keySelectedDistrict, district.name);

    state = RegionSelection(
      regionName: regionName,
      districtName: district.name,
      latitude: district.latitude,
      longitude: district.longitude,
    );
  }

  /// Saves the current choice on the account, without bothering the person if
  /// that fails (offline): the choice is kept on the device in any case.
  Future<void> _saveToAccountQuietly() async {
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateLocation(
            region: state.regionName,
            district: state.districtName,
          );
    } catch (_) {}
  }

  Future<void> setRegion(String regionName) async {
    final firstDistrict = findRegion(regionName)?.districts.first;
    if (firstDistrict == null) return;
    await _applyLocally(regionName, firstDistrict);
    unawaited(_saveToAccountQuietly());
  }

  Future<void> setDistrict(String districtName) async {
    final district = findDistrict(state.regionName, districtName);
    if (district == null) return;
    await _applyLocally(state.regionName, district);
    unawaited(_saveToAccountQuietly());
  }

  /// Sets region and district together and saves them on the account. Unlike
  /// the pickers on the home screen it reports a failure to save (used when
  /// registering, where the choice must reach the account).
  Future<void> setSelection(String regionName, String districtName) async {
    final district = findDistrict(regionName, districtName);
    if (district == null) return;
    await _applyLocally(regionName, district);
    await ref
        .read(profileRepositoryProvider)
        .updateLocation(region: regionName, district: district.name);
  }

  /// After an existing account signs in: the location saved on the account
  /// wins on this device; an account without one gets this device's choice.
  Future<void> adoptFromAccount(UserModel user) async {
    if (user.hasLocation) {
      final district = findDistrict(user.region!, user.district!);
      if (district != null) {
        await _applyLocally(user.region!, district);
        return;
      }
    }
    await _saveToAccountQuietly();
  }
}

final regionSelectionProvider =
    NotifierProvider<RegionSelectionNotifier, RegionSelection>(
      RegionSelectionNotifier.new,
    );
