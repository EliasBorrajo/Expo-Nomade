import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'MuseumMarkerPopup.dart';
import 'marker_popup.dart';

class MapMarker  {
  final LatLng position;
  final List<MapEntry<String, String>> markerPopupData;
  final bool isMuseum;


  MapMarker({required this.position, required this.markerPopupData, required this.isMuseum});

  Marker createMarker(BuildContext context, List<String>? images) { // Add images parameter here
    return Marker(
      point: position,
      builder: (ctx) => GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) {
              if (isMuseum) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: MuseumMarkerPopup(
                      data: markerPopupData,
                    ),
                  ),
                );
              } else {
                return Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: MarkerPopup(
                      data: markerPopupData,
                      images: images,  // Use images parameter here
                    ),
                  ),
                );
              }
            },
          );
        },
        behavior: HitTestBehavior.translucent,
        child: Icon(
          isMuseum ? Icons.museum : Icons.location_on,
          color: isMuseum ? Colors.black : Colors.red,
          size: 50.0,
        ),
      ),
    );
  }


}
