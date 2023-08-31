import 'dart:ffi';

import 'Coordinate.dart';
import 'MuseumObject.dart';

class Museum {
  String id;
  String name;
  Coordinate address;
  String website;
  late List<MuseumObject>? objects;   // late : permet de déclarer une variable sans l'initialiser (elle sera initialisée plus tard)

  Museum({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    this.objects,
  });

  factory Museum.fromMap(Map<String, dynamic> map) {
    return Museum(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: Coordinate.fromMap(Map<String, dynamic>.from(map['address'] ?? {})),
      website: map['website'] ?? '',
      objects: (map['objects'] as List<dynamic>?)
         ?.map((objectMap) => MuseumObject.fromMap(Map<String, dynamic>.from(objectMap)))
          .toList(),
    );
  }
}