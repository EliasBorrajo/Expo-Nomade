class FilterTag {
  final id;
  final String typeName;
  List<String> options;
  bool isSelected;

  FilterTag({
    required this.id,
    required this.typeName,
    required this.options,
    this.isSelected = false,
  });
}



