import 'package:flutter/material.dart';
import 'map_screen.dart'; // Import the map screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(), // Set MapScreen as the home widget
    );
  }
}
