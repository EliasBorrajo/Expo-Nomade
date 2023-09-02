import 'dart:ui';
import 'package:latlong2/latlong.dart';
import 'Tag.dart';

// OBJETS
class Migration {
  final String id;
  String name;
  String description;
  String arrival;
  late List<MigrationSource>? polygons;
  late List<Tag>? tags;                  // optional & initialized later
  List<String>? images;                  // optional

  Migration({
    required this.id,
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
  final String id;
  late List<LatLng>? points;
  late Color? color;
  late String? name;
  late VoidCallback? onTap;

  MigrationSource({
    required this.id,
    this.points,
    this.color,
    this.name,
    this.onTap,
  });
}

