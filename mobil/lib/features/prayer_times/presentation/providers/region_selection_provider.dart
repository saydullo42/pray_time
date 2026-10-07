import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/uzbekistan_regions.dart';
import '../../../../core/storage/local_storage_service.dart';

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
    final regionName = storage.getString(AppConstants.keySelectedRegion) ?? defaultRegionName;
    final districtName = storage.getString(AppConstants.keySelectedDistrict) ?? defaultDistrictName;

    final district = findDistrict(regionName, districtName) ??
        findRegion(regionName)?.districts.first ??
        findDistrict(defaultRegionName, defaultDistrictName)!;

    return RegionSelection(
      regionName: regionName,
      districtName: district.name,
      latitude: district.latitude,
      longitude: district.longitude,
    );
  }

  Future<void> setRegion(String regionName) async {
    final firstDistrict = findRegion(regionName)?.districts.first;
    if (firstDistrict == null) return;

    final storage = ref.read(localStorageServiceProvider);
    await storage.setString(AppConstants.keySelectedRegion, regionName);
    await storage.setString(AppConstants.keySelectedDistrict, firstDistrict.name);

    state = RegionSelection(
      regionName: regionName,
      districtName: firstDistrict.name,
      latitude: firstDistrict.latitude,
      longitude: firstDistrict.longitude,
    );
  }

  Future<void> setDistrict(String districtName) async {
    final district = findDistrict(state.regionName, districtName);
    if (district == null) return;

    final storage = ref.read(localStorageServiceProvider);
    await storage.setString(AppConstants.keySelectedDistrict, districtName);

    state = RegionSelection(
      regionName: state.regionName,
      districtName: district.name,
      latitude: district.latitude,
      longitude: district.longitude,
    );
  }
}

final regionSelectionProvider =
    NotifierProvider<RegionSelectionNotifier, RegionSelection>(RegionSelectionNotifier.new);
