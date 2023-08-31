import 'package:expo_nomade/dataModels/Coordinate.dart';

import 'Tag.dart';

// OBJETS
class MuseumObject {
  String name;
  String description;
  late List<TagOption>? tags;            // optional & initialized later
  List<String>? images;                  // optional
  List<Localisation> discoveries;
  List<Localisation> sources;

  MuseumObject({
    required this.name,
    required this.description,
    this.tags,
    this.images,
    required this.discoveries,
    required this.sources,
  });

  factory MuseumObject.fromMap(Map<String, dynamic> map) {
    return MuseumObject(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      tags: List<TagOption>.from((map['tags'] ?? []).map((tag) => TagOption.fromMap(tag))),
      images: List<String>.from(map['images'] ?? []),
      discoveries: List<Localisation>.from((map['discoveries'] ?? []).map((discovery) => Localisation.fromMap(discovery))),
      sources: List<Localisation>.from((map['sources'] ?? []).map((source) => Localisation.fromMap(source))),
    );
  }
}

// DECOUVERTES & SOURCES
class Localisation {
  String date;
  Coordinate location;


  Localisation({
    required this.date,
    required this.location,
  });

  factory Localisation.fromMap(Map<String, dynamic> map) {
    return Localisation(
      date: map['date'] ?? '',
      location: Coordinate.fromMap(map['location'] ?? {}),
    );
  }
}