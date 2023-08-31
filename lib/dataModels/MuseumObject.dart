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
}

// DECOUVERTES & SOURCES
class Localisation {
  String date;
  Coordinate location;


  Localisation({
    required this.date,
    required this.location,
  });
}