import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/uzbek_transliterator.dart';

/// Resolves the device's current GPS position, requesting permission if
/// needed. Prayer time calculation depends on accurate coordinates.
final currentPositionProvider = FutureProvider<Position>((ref) async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('Joylashuvga ruxsat berilmadi');
  }

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Joylashuv xizmati o\'chirilgan');
  }

  return Geolocator.getCurrentPosition();
});

final _viloyatSuffix = RegExp(r"\s*viloyat(i)?\s*$", caseSensitive: false);

/// "Viloyat, tuman" label for the device's current position, reverse
/// geocoded from GPS coordinates, e.g. "Farg'ona, Marg'ilon tumani". Always
/// transliterated to Latin, since some devices' geocoders return Cyrillic.
final deviceLocationLabelProvider = FutureProvider.autoDispose<String>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  try {
    await setLocaleIdentifier('uz_UZ');
  } catch (_) {
    // Locale override isn't supported on every platform; fall back to
    // whatever the device's default geocoder locale returns and rely on
    // the transliteration below to normalize it to Latin.
  }
  final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  if (placemarks.isEmpty) return '';

  final place = placemarks.first;
  var region = cyrillicToLatinUz(place.administrativeArea ?? '');
  region = region.replaceAll(_viloyatSuffix, '').trim();
  final district = cyrillicToLatinUz(
    (place.subAdministrativeArea?.isNotEmpty ?? false) ? place.subAdministrativeArea! : (place.locality ?? ''),
  );

  if (region.isEmpty && district.isEmpty) return '';
  if (region.isEmpty) return district;
  if (district.isEmpty) return region;
  return '$region, $district';
});
