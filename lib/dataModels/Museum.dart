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

  // Factory constructor to create Museum instances from JSON
  factory Museum.fromJson(Map<String, dynamic> json) {
    return Museum(
      id: json['id'],
      name: json['name'],
      address: LatLng(
        json['address']['latitude'],
        json['address']['longitude'],
      ),
      website: json['website'],
      objects: json['objects'] != null
          ? List<MuseumObject>.from(
        json['objects'].map((objectJson) => MuseumObject.fromJson(objectJson)),
      )
          : null,
    );
  }
}