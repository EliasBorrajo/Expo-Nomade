// Dummy data
import 'package:latlong2/latlong.dart';

import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject.dart';

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