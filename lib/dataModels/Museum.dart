import 'package:latlong2/latlong.dart';

import 'MuseumObject.dart';

class Museum {
  final String id;
  String name;
  LatLng address;
  String website;
  late List<MuseumObject>? objects;   // late : permet de déclarer une variable sans l'initialiser (elle sera initialisée plus tard)

  Museum({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    this.objects,
  });

}