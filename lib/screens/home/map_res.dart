import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import '../../shared/app_colors.dart';

class RestaurantMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const RestaurantMapPage(
      {Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Restaurant Location'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(latitude, longitude),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                builder: (ctx) => Icon(
                  Icons.location_on,
                  size: 40,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
