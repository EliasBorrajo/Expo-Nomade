import 'package:expo_nomade/map/map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.points});

  final List<LatLng> points;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isPopupOpen = false;
  String popupTitle = '';

  void openPopup(String title) {
    setState(() {
      isPopupOpen = true;
      popupTitle = title;
    });
  }

  void closePopup() {
    setState(() {
      isPopupOpen = false;
      popupTitle = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: const LatLng(46.2228401, 7.2939617),
          zoom: 12.0,
        ),
        children: [
          Stack(
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  for (var point in widget.points)
                    MapMarker(
                      position: point,
                      markerPopupData: [
                        const MapEntry('Name', 'John Doe'),
                        const MapEntry('Age', '25'),
                      ],
                    ).createMarker(context),
                ]
              ),
            ],
          ),
        ],
      ),
    );
  }

}
