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
// Factory constructor to create MuseumObject instances
  factory MuseumObject.fromJson(Map<String, dynamic> json) {
    return MuseumObject(
      name: json['name'],
      description: json['description'],
      point: LatLng(
        json['point']['latitude'],
        json['point']['longitude'],
      ),
      tags: json['tags'] != null
          ? List<Tag>.from(json['tags'].map((tagJson) => Tag.fromJson(tagJson)))
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
    );
  }
}

