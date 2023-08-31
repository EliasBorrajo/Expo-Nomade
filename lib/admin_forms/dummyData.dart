// Dummy data
import 'dart:ui';

import 'package:latlong2/latlong.dart';

import '../dataModels/Migration.dart';
import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject.dart';
import '../dataModels/Tag.dart';

final dummyMuseums = [
  Museum(
    id: '1',
    name: 'Museum 1',
    address: const LatLng(-12.34, 110.89),
    website: 'Website 1',
    objects: [
      MuseumObject(
        name: 'Object 1',
        description: 'Description of Object 1',
        point: const LatLng( 0, 0),
      ),
      MuseumObject(
        name: 'Object 2',
        description: 'Description of Object 2',
        point: const LatLng( 0, 0),
      ),
    ],
  ),
  Museum(
    id: '2',
    name: 'Museum 2',
    address:  const LatLng( 89,  100.89),
    website: 'Website 2',
    objects: [
      MuseumObject(
        name: 'Object 3',
        description: 'Description of Object 3',
        point: const LatLng( 0, 0),
      ),
    ],
  ),
  Museum(
    id: '3',
    name: 'Museum 3',
    address: const LatLng( -89,  170.89),
    website: 'Website 3',
    objects: null, // No objects for this museum
  ),
  Museum(
    id: '4',
    name: 'Museum 4',
    address: const LatLng( 77,  160.89),
    website: 'Website 4',
    objects:  const <MuseumObject>[], // Empty list of objects for this museum // TODO : supprimer ? Ne peut pas arriver je crois
  ),
];


final dummyMigrations = [
  Migration(
    name: 'Migration 1',
    description: 'Description of Migration 1',
    arrival: 'Arrival 1',
    polygons: [
      MigrationSource(
        [LatLng(0, 0), LatLng(0, 10), LatLng(10, 10)],
        Color(0xFF00FF00), 'source 1',
      ),
    ],
    images: ['image1.jpg', 'image2.jpg'],
  ),
  Migration(
    name: 'Migration 2',
    description: 'Description of Migration 2',
    arrival: 'Arrival 2',
    polygons: [
      MigrationSource(
        [LatLng(20, 20), LatLng(30, 20), LatLng(30, 30)],
        Color(0xFFFF0000), 'source 2',
      ),
      MigrationSource(
        [LatLng(40, 40), LatLng(40, 50), LatLng(50, 50)],
        Color(0xFF0000FF), 'source 2.1',
      ),
    ],
  ),
];