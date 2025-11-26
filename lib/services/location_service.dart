import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    // Location enabled?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    // Permission check
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

static Future<String?> getAddressFromCoordinates(
  double latitude, 
  double longitude
) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude, 
      longitude
    );
    
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return '${place.locality}, ${place.administrativeArea}';
    }
  } catch (e) {
    print('Error getting address: $e');
  }
  return null;
}
}
