import 'package:expo_nomade/marker_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
                markers: _createMarkers(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Marker> _createMarkers() {
    return [
      Marker(
        point: const LatLng(46.2228401, 7.2939617),
        builder: (ctx) => GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (context) => const Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: MarkerPopup(
                      data: [
                        MapEntry('Name', 'John Doe'),
                        MapEntry('Age', '25'),
                        // Add more data items as needed
                      ],
                    ),
                  ),
                )
            );
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 50.0,
          ),
        ),
      ),
    ];
  }
}
