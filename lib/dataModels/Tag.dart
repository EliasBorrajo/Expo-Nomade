class Tag {
  final id;
  final String typeName;
  late List<String>? options;

  Tag({
    required this.id,
    required this.typeName,
    this.options,
  });

  // Factory constructor to create Tag instances from JSON
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      typeName: json['typeName'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
    );
  }
}



