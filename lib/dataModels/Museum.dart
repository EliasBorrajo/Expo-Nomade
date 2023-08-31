import 'Coordinate.dart';
import 'MuseumObject.dart';

class Museum {
  String id;
  String name;
  Coordinate address;
  String website;
  late List<MuseumObject>? objects;   // late : permet de déclarer une variable sans l'initialiser (elle sera initialisée plus tard)

  Museum({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    this.objects,
  });
}