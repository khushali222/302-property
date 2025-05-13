import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NearbyPropertiesScreen(),
    );
  }
}

class NearbyPropertiesScreen extends StatefulWidget {
  const NearbyPropertiesScreen({super.key});

  @override
  State<NearbyPropertiesScreen> createState() => _NearbyPropertiesScreenState();
}

class _NearbyPropertiesScreenState extends State<NearbyPropertiesScreen> {
  List<Map<String, String>> properties = [
    {
      "rental_address": "505 Stafford Ave.",
      "rental_city": "Newark",
      "rental_state": "DE",
      "rental_country": "US",
      "rental_postcode": "19711"
    },
    {
      "rental_address": "22 Herbert Drive",
      "rental_city": "New Castle",
      "rental_state": "DE",
      "rental_country": "USA",
      "rental_postcode": "19720"
    }
  ];

  List<Map<String, dynamic>> nearbyProperties = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNearbyProperties();
  }

  Future<void> fetchNearbyProperties() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position currentPosition = await _getCurrentLocation();
      for (var property in properties) {
        String fullAddress =
            "${property['rental_address']}, ${property['rental_city']}, ${property['rental_state']}, ${property['rental_country']} ${property['rental_postcode']}";

        double distance = await _getDistanceFromProperty(
            currentPosition.latitude, currentPosition.longitude, fullAddress);

        if (distance <= 10.0) {
          property['distance'] = distance.toStringAsFixed(2);
          nearbyProperties.add(property);
        }
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<double> _getDistanceFromProperty(
      double currentLat, double currentLng, String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      double distanceInMeters = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        locations[0].latitude,
        locations[0].longitude,
      );
      return distanceInMeters / 1000; // Convert to kilometers
    } catch (e) {
      print("Error getting distance: $e");
      return double.infinity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Properties"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: nearbyProperties.length,
        itemBuilder: (context, index) {
          final property = nearbyProperties[index];
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            child: ListTile(
              title: Text(
                  "${property['rental_address']}, ${property['rental_city']}"),
              subtitle: Text(
                  "${property['rental_state']}, ${property['rental_country']} - ${property['rental_postcode']}"),
              trailing: Text("${property['distance']} km away"),
            ),
          );
        },
      ),
    );
  }
}
