class FilterTag {
  final id;
  String typeName;
  List<String> options;
  bool isSelected;

  FilterTag({
    required this.id,
    required this.typeName,
    required this.options,
    this.isSelected = false,
  });
}



