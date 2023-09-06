import 'package:latlong2/latlong.dart';

import 'MuseumObject.dart';

class Museum {
  final String id;
  String name;
  LatLng address;
  String website;

  Museum({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
  });

}