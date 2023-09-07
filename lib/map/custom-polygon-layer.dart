import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../dataModels/Migration.dart';
import 'marker_popup.dart';

class CustomPolygonLayer extends StatelessWidget {
  late List<Migration> migrations = [];

  CustomPolygonLayer({super.key, required this.migrations});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolygonLayer(
          polygons: [
            for (var migration in migrations)
              for(var polygon in migration.polygons!)
                Polygon(
                  points: polygon.points!,
                  color: Colors.blueAccent.withOpacity(0.3),
                  borderColor: Colors.blueAccent,
                  borderStrokeWidth: 2.0,
                  isFilled: true,
                ),
          ],
        ),
        MarkerLayer(
          key: const Key('Polygon marker'),
          markers: [
            for (var migration in migrations)
              for(var polygon in migration.polygons!)
              Marker(
                point: _calculateCentroid(polygon.points!),
                builder: (ctx) => GestureDetector(
                  onTap: (){
                    // Call the popup
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MarkerPopup(
                          data: [
                            MapEntry("Name", migration.name),
                            MapEntry("Description", migration.description),
                            MapEntry("Arrival", migration.arrival),
                          ],
                        ),
                      ),
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: const Icon(
                    Icons.touch_app_outlined,
                    color: Colors.black,
                    size: 35.0,
                  ),
                ),
              ),
          ],
        ),
      ],
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

class TappablePolygon {
  final List<LatLng> points;
  final VoidCallback onTap;

  TappablePolygon(this.points, this.onTap);
}
