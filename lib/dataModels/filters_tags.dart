class FilterTag {
  final id;
  String typeName;
  List<String> options; // Liste d'options
  bool isSelected;

  FilterTag({
    required this.id,
    required this.typeName,
    required this.options,
    this.isSelected = false,
  });
}
