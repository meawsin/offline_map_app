import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Places")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: "Search for a place"),
              onSubmitted: (query) {
                "bathrrom: $query";
                LatLng searchResult = LatLng(23.734972699527226,
                    90.39574943610096); // Replace with actual search logic
                Navigator.pop(context, searchResult);
              },
            ),
          ],
        ),
      ),
    );
  }
}
