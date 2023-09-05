import 'package:latlong2/latlong.dart';

import 'filters_tags.dart';

// OBJETS
class MuseumObject {
  final String id;
  String museumName;
  String name;
  String description;
  LatLng point;
  late List<FilterTag>? tags;                  // optional & initialized later
  List<String>? images;                  // optional


  MuseumObject({
    required this.id,
    required this.museumName,
    required this.name,
    required this.description,
    required this.point,
    this.tags,
    this.images,
  });
}

