import 'MuseumObject .dart';

class Museum {
  final String id;
  final String name;
  final String address;
  final String website;
  final List<MuseumObject> objects;

  Museum({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    required this.objects,
  });
}