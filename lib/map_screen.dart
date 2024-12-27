import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart'; // For current location

import 'package:offline_map_app/search.dart'; // Import the SearchScreen class

class Tile {
  final int x;
  final int y;

  Tile(this.x, this.y);
}

class AssetTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(
      TileCoordinates coordinates, TileLayer options) {
    final zoom = coordinates.z.toInt(); // Get the zoom level
    final x = coordinates.x;
    final y = coordinates.y;

    // Construct the path based on coordinates and zoom level
    String tilePath = 'assets/tiles/$zoom/$x-$y.png';
    print("Loading tile: $tilePath"); // Debugging line, check in console

    return AssetImage(tilePath); // Return the image for the specific tile
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  final List<LatLng> _places = [
    LatLng(23.734972699527226, 90.39574943610096), // Example place 1
    LatLng(23.729639605140775, 90.39645758535048), // Example place 2
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it
      print('Location services are disabled.');
      return;
    }

    // Check if the app has permission to access the device's location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // The user denied the permission
        print('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // The user has permanently denied the permission
      print('Location permission permanently denied');
      return;
    }

    // If permissions are granted, fetch the location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Map"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              LatLng? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
              if (result != null) {
                setState(() {
                  _places.add(result);
                  _mapController.move(result, 14.0);
                });
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition ??
              LatLng(23.734972699527226, 90.39574943610096), // Default center
          minZoom: 14.0, // Minimum zoom level
          maxZoom: 16.0, // Maximum zoom level
          onTap: (tapPosition, point) {
            setState(() {
              _places.add(point);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'assets/tiles/{z}/{x}/{y}.png',
            tileProvider: AssetTileProvider(),
          ),
          MarkerLayer(
            markers: _places.map((place) {
              return Marker(
                width: 40.0,
                height: 40.0,
                point: place,
                child: const Icon(Icons.pin_drop, color: Colors.red),
              );
            }).toList(),
          ),
          MarkerLayer(
            markers: _currentPosition == null
                ? []
                : [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _currentPosition!,
                      child: Icon(Icons.location_on, color: Colors.blue),
                    ),
                  ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
