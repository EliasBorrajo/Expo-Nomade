import 'package:latlong2/latlong.dart';

import 'filters_tags.dart';

// OBJETS
class MuseumObject {
  final String id;
  String museumId;
  String name;
  String description;
  LatLng point;
  late List<FilterTag>? tags;                  // optional & initialized later
  List<String>? images;                  // optional


  MuseumObject({
    required this.id,
    required this.museumId,
    required this.name,
    required this.description,
    required this.point,
    this.tags,
    this.images,
  });
}

