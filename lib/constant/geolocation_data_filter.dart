import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/properties.dart';
import '../VendorModule/model/workorder_model.dart';

// SharedPreferences flag: whether the OS location prompt has already been shown
// once. Used only to stop the automatic dashboard load from re-nagging on every
// launch (Android re-prompts while permission is `denied`).
const String _askedLocationKey = 'askedLocation';

/// [autoRequest] = the caller is the automatic first-load (dashboard init /
/// app-resume). In that mode the OS prompt is shown at most ONCE ever, so the
/// dashboard stops re-nagging on every load. A user-initiated retry (e.g. an
/// "Enable location" action) must pass `autoRequest: false` so it can still
/// re-prompt on Android while permission is only `denied` (not `deniedForever`).
Future<Position> getCurrentLocation({bool autoRequest = true}) async {
  // Ask for permission FIRST so first-time users (Vendor/Staff) get the popup
  // on first login even if the device location toggle happens to be off.
  // Requesting permission does not require the location service to be enabled
  // (true on both Android and iOS). Contract is unchanged: returns a Position
  // on success, throws on any failure (callers already catch and continue).
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // Ask-once guard: skip the prompt only for the automatic load once it has
    // already been shown. A manual retry (autoRequest:false) always re-prompts.
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_askedLocationKey) ?? false;
    if (!autoRequest || !alreadyAsked) {
      await prefs.setBool(_askedLocationKey, true);
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception("Location permission permanently denied.");
  }
  print('[LOCATION] permission ok ($permission) — checking device location service');
  // Then confirm the device location service is actually on.
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print('[LOCATION] device location service enabled = $serviceEnabled');
  if (!serviceEnabled) {
    throw Exception("Location services are disabled.");
  }
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
// Session cache of geocoded coordinates, keyed by the full address string, so
// the same property isn't re-geocoded (a network call) on every dashboard load.
// An address maps to fixed coordinates, so this never goes stale; a changed
// address is simply a new key.
final Map<String, LatLng> _geocodeCache = {};

Future<LatLng?> getCoordinatesFromAddress(Rentals rental) async {
  String address = '${rental.rentalAddress}, ${rental.rentalCity}, ${rental.rentalState}, ${rental.rentalCountry} ${rental.rentalPostcode}';
  if (_geocodeCache.containsKey(address)) return _geocodeCache[address];
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final coord =
          LatLng(locations.first.latitude, locations.first.longitude);
      _geocodeCache[address] = coord;
      return coord;
    }
  } catch (e) {
    print('Failed to geocode address: $address. Error: $e');
  }
  return null;
}
Future<LatLng?> getCoordinatesFromAddressforvendor(RentalData rental) async {
  String address = '${rental.rentalAddress}, ${rental.rentalCity}, ${rental.rentalState}, ${rental.rentalCountry} ${rental.rentalPostcode}';
  if (_geocodeCache.containsKey(address)) return _geocodeCache[address];
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final coord =
          LatLng(locations.first.latitude, locations.first.longitude);
      _geocodeCache[address] = coord;
      return coord;
    }
  } catch (e) {
    print('Failed to geocode address: $address. Error: $e');
  }
  return null;
}