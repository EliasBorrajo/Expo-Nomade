import 'MuseumObject .dart';

class Museum {
  final String id;
  final String name;
  final String address;
  final String website;
  final List<MuseumObject> objects;   // TODO: Rendre optionnel ? Car créer un musée, puis ENSUITE ajouter des objets

  Museum({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    required this.objects,
  });
}