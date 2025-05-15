import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../Model/properties.dart';


Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("Location services are disabled.");
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception("Location permission permanently denied.");
  }
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
Future<LatLng?> getCoordinatesFromAddress(Rentals rental) async {
  String address = '${rental.rentalAddress}, ${rental.rentalCity}, ${rental.rentalState}, ${rental.rentalCountry} ${rental.rentalPostcode}';
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    print('Failed to geocode address: $address. Error: $e');
  }
  return null;
}