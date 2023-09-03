import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'marker_popup.dart';

class MapMarker  {
  final LatLng position;
  final List<MapEntry<String, String>> markerPopupData;

  MapMarker({required this.position, required this.markerPopupData});

  Marker createMarker(BuildContext context) {
    return Marker(
      point: position,
      builder: (ctx) => GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) => Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: MarkerPopup(
                  data: markerPopupData,
                ),
              ),
            ),
          );
        },
        behavior: HitTestBehavior.translucent,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 50.0,
        ),
      ),
    );
  }
}
