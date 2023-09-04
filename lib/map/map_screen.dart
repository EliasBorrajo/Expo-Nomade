import 'package:expo_nomade/map/custom-polygon-layer.dart';
import 'package:expo_nomade/map/map_marker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../dataModels/Migration.dart';
import '../firebase/firebase_crud.dart';
import 'map_filters.dart';

class MapScreen extends StatefulWidget {

  final FirebaseDatabase database;
  const MapScreen({super.key, required this.points, required this.database});

  final List<LatLng> points;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isPopupOpen = false;
  String popupTitle = '';
  late List<Migration> migrations = [];

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
  void initState() {
    super.initState();
    final firebaseUtils = FirebaseUtils(widget.database);
    firebaseUtils.loadMigrationsAndListen((updatedMigrations) {
      setState(() {
        migrations = updatedMigrations;
      });
    });
  }

  void _openFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FiltersWindow(database: widget.database); // Remplacez par le widget de votre fenêtre de filtre
      },
    );
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
              CustomPolygonLayer(migrations: migrations),
              MarkerLayer(
                key: const Key('Object marker'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openFilters();
        },
        label: const Text('Filtres'),
        icon: const Icon(Icons.filter_list_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    // Calculate the centroid of the polygon
    // Replace this logic with your own centroid calculation
    double sumX = 0.0;
    double sumY = 0.0;

    for (var point in points) {
      sumX += point.latitude;
      sumY += point.longitude;
    }

    final centroid = LatLng(
      sumX / points.length,
      sumY / points.length,
    );

    return centroid;
  }

}

