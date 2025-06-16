import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gustoro/shared/app_colors.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class SelectLocationPage extends StatelessWidget {
  final LatLng? initialLocation;

  const SelectLocationPage({Key? key, this.initialLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LatLng selectedLocation = initialLocation ?? LatLng(34.8021, 38.9968);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mainColor,
        title: const Text('Select Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: initialLocation ?? LatLng(34.8021, 38.9968),
          zoom: 13.0,
          onTap: (tapPosition, point) {
            selectedLocation = point;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected location: $point')),
            );
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          Navigator.pop(context, selectedLocation);
        },
        child: Icon(Icons.check , color: mainColor,),
      ),
    );
  }
}
