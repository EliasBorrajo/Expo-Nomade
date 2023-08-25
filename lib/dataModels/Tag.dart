class Tag {
  final String type;
  final List<TagOption> options;

  Tag({required this.type, required this.options});
}

// TAG OPTIONS
// Simplement une class bête car,
// Permet d'avoir une liste de cette classe dans l'objet MuseumObject
class TagOption {
  final String name;

  TagOption({required this.name});
}

