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
  List<LatLng> currentPolygonPoints = [];
  List<LatLng> validatedPolygon = [];
  LatLng currentPoint = const LatLng(0.0, 0.0);
  LatLng validatedPoint = const LatLng(0.0, 0.0);
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
                if(widget.pickerType == 1){
                  if (isEditingPolygon) {
                    currentPolygonPoints.add(position);
                  }
                }else{
                  currentPoint = position;
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
                widget.pickerType == 1 ?
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: validatedPolygon,
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
                )
                    :
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPoint,
                      builder: (_) => const Icon(Icons.location_on, color: Colors.blue),
                    ),
                    Marker(
                      point: validatedPoint,
                      builder: (_) => const Icon(Icons.location_on, color: Colors.green),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
        floatingActionButton: Column (
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'fab1',
              onPressed: () {
                setState(() {
                  if (isEditingPolygon) {
                    validatedPolygon = currentPolygonPoints;
                    validatedPoint = currentPoint;
                  }
                  isEditingPolygon = !isEditingPolygon;
                });
              },
              backgroundColor: isEditingPolygon ? Colors.green : Colors.blue,
              child: Icon(isEditingPolygon ? Icons.check : Icons.edit),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'fab2',
              onPressed: () {
                // Return the points or point
                widget.pickerType == 1 ? Navigator.pop(context, validatedPolygon) : Navigator.pop(context, currentPoint);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.save_rounded),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'fab3',
              onPressed: () {
                // Return the points or point
                widget.pickerType == 1 ? validatedPolygon.clear() : validatedPoint = const LatLng(0.0, 0.0);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.delete_rounded),
            ),
          ],
        )
    );
  }
}