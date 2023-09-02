import 'dart:ui';
import 'package:latlong2/latlong.dart';
import 'Tag.dart';

// OBJETS
class Migration {
  String name;
  String description;
  String arrival;
  late List<MigrationSource>? polygons;
  late List<Tag>? tags;                  // optional & initialized later
  List<String>? images;                  // optional

  Migration({
    required this.name,
    required this.description,
    required this.arrival,
    this.tags,
    this.images,
    this.polygons,
  });
}

// Represents a migration source with a color and a zone on the map
class MigrationSource {
  late List<LatLng>? points;
  late Color? color;
  late String? name;
  late VoidCallback? onTap;

  MigrationSource({
    this.points,
    this.color,
    this.name,
    this.onTap,
  });
}

