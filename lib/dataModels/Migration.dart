import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'filters_tags.dart';

// OBJETS
class Migration {
  final String id;
  String name;
  String description;
  String arrival;
  late List<MigrationSource>? polygons;
  late List<FilterTag>? tags;                  // optional & initialized later
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
  late List<LatLng>? points;
  late String? name;
  late VoidCallback? onTap;

  MigrationSource({
    this.points,
    this.name,
    this.onTap,
  });
}

