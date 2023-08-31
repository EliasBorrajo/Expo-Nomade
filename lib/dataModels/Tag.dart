class Tag {
  final String type;
  final List<TagOption> options;

  Tag({required this.type, required this.options});

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      type: map['type'] ?? '',
      options: List<TagOption>.from((map['options'] ?? []).map((option) => TagOption.fromMap(option))),
    );
  }
}

// TAG OPTIONS
// Simplement une class bête car,
// Permet d'avoir une liste de cette classe dans l'objet MuseumObject
class TagOption {
  final String name;

  TagOption({required this.name});

  factory TagOption.fromMap(Map<String, dynamic> map) {
    return TagOption(
      name: map['name'] ?? '',
    );
  }
}

