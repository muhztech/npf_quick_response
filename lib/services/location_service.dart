import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> resolveAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return 'Unknown location';

      final place = placemarks.first;

      final city = place.locality ?? place.subAdministrativeArea;
      final state = place.administrativeArea;

      if (city != null && state != null) {
        return '$city, $state';
      }

      return state ?? 'Unknown location';
    } catch (_) {
      return 'Unknown location';
    }
  }
}
