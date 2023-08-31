// Dummy data
import '../dataModels/Coordinate.dart';
import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject .dart';

final dummyMuseums = [
  Museum(
    id: '1',
    name: 'Museum 1',
    address: Coordinate(latitude: -12.34, longitude: 110.89),
    website: 'Website 1',
    objects: [
      MuseumObject(
        name: 'Object 1',
        description: 'Description of Object 1',
        discoveries: [],
        sources: [],
      ),
      MuseumObject(
        name: 'Object 2',
        description: 'Description of Object 2',
        discoveries: [],
        sources: [],
      ),
    ],
  ),
  Museum(
    id: '2',
    name: 'Museum 2',
    address: Coordinate(latitude: 89, longitude: 100.89),
    website: 'Website 2',
    objects: [
      MuseumObject(
        name: 'Object 3',
        description: 'Description of Object 3',
        discoveries: [],
        sources: [],
      ),
    ],
  ),
  Museum(
    id: '3',
    name: 'Museum 3',
    address: Coordinate(latitude: -89, longitude: 170.89),
    website: 'Website 3',
    objects: null, // No objects for this museum
  ),
  Museum(
    id: '4',
    name: 'Museum 4',
    address: Coordinate(latitude: 77, longitude: 160.89),
    website: 'Website 4',
    objects:  const <MuseumObject>[], // Empty list of objects for this museum // TODO : supprimer ? Ne peut pas arriver je crois
  ),
];