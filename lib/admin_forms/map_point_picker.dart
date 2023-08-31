import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPointPicker extends StatefulWidget {
  // Define the kind of picker
  // 1: Polygon
  // 2: Museum or object
  final int pickerType;
  const MapPointPicker({super.key, required this.pickerType});

  @override
  _MapPointPickerState createState() => _MapPointPickerState();
}

class _MapPointPickerState extends State<MapPointPicker> {
  List<List<LatLng>> validatedPolygons = [];
  List<LatLng> currentPolygonPoints = [];
  bool isEditingPolygon = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Polygons on Map')),
      body: FlutterMap(
        options: MapOptions(
          center: const LatLng(46.2228401, 7.2939617),
          zoom: 12.0,
          onTap: (point, position) {
            setState(() {
              if (isEditingPolygon) {
                currentPolygonPoints.add(position);
              }
            });
          },
        ),
        children: [
          Stack(
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              PolygonLayer(
                polygons: [
                  for (var points in validatedPolygons)
                    Polygon(
                      points: points,
                      color: Colors.green.withOpacity(0.3),
                      borderColor: Colors.green,
                      borderStrokeWidth: 2.0,
                      isFilled: true,
                    ),
                  if (isEditingPolygon && currentPolygonPoints.isNotEmpty)
                    Polygon(
                      points: currentPolygonPoints,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2.0,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (isEditingPolygon) {
              validatedPolygons.add([...currentPolygonPoints]);
              currentPolygonPoints.clear();
            }
            isEditingPolygon = !isEditingPolygon;
          });
        },
        backgroundColor: isEditingPolygon ? Colors.green : Colors.blue,
        child: Icon(isEditingPolygon ? Icons.check : Icons.edit),
      ),
    );
  }
}