import 'package:latlong2/latlong.dart';

import 'Tag.dart';

// OBJETS
class MuseumObject {
  String name;
  String description;
  LatLng point;
  List<Tag>? tags;                  // optional & initialized later
  List<String>? images;                  // optional


  MuseumObject({
    required this.name,
    required this.description,
    required this.point,
    this.tags,
    this.images,
  });

}

