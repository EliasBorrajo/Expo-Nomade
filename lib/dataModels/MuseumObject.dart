import 'package:expo_nomade/dataModels/Coordinate.dart';

import 'Tag.dart';

// OBJETS
class MuseumObject {
  final String name;
  final String description;
  final List<TagOption>? tags;            // optional
  final List<String>? images;             // optional
  final List<Localisation> discoveries;
  final List<Localisation> sources;

  MuseumObject({
    required this.name,
    required this.description,
    this.tags,
    this.images,
    required this.discoveries,
    required this.sources,
  });
}

// DECOUVERTES
class Localisation {
  final String date;
  final Coordinate location;


  Localisation({
    required this.date,
    required this.location,
  });
}