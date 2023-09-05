import 'package:expo_nomade/admin_forms/dummyData.dart';
import 'package:expo_nomade/dataModels/filters_tags.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FiltersWindow extends StatefulWidget {
  final FirebaseDatabase database;

  const FiltersWindow({super.key, required this.database});

  @override
  _FiltersWindowState createState() => _FiltersWindowState();
}

class _FiltersWindowState extends State<FiltersWindow> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('filters');
  List<FilterTag> filters = [];
  Map<String, List<bool>> selectedOptionsMap = {};
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchFilters();
  }

  void fetchFilters() async {
    try {
      DatabaseEvent event = await _database.once();
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic,
          dynamic>?;

      if (data != null) {
        List<FilterTag> fetchedFilters = data.entries
            .map((entry) {
          String filterId = entry.key;
          Map<String, dynamic> filterData = Map<String, dynamic>.from(
              entry.value);
          return FilterTag(
            id: filterId,
            typeName: filterData['typeName'] ?? '',
            options: List<String>.from(filterData['options'] ?? []),
          );
        })
            .toList();

        for (var filter in fetchedFilters) {
          selectedOptionsMap[filter.typeName] = List.filled(filter.options.length, false);
        }

        setState(() {
          filters = fetchedFilters;
        });
      }
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  Widget _buildSelectedIcon(String typeName) {
    final isSelected = selectedOptionsMap[typeName]?.any((selected) => selected) ?? false;

    return isSelected
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.radio_button_unchecked, color: Colors.grey);
  }

  void resetFilters() {
    for (var typeName in selectedOptionsMap.keys) {
      selectedOptionsMap[typeName]?.fillRange(0, selectedOptionsMap[typeName]?.length ?? 0, false);
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 500),
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            ElevatedButton(
              onPressed: resetFilters,
              child: const Icon(Icons.restart_alt),
            ),
            for (var filter in filters)
              Card(
                child: ExpansionTile(
                  title: Row(
                    children: [
                      _buildSelectedIcon(filter.typeName),
                      Text(filter.typeName),
                    ],
                  ),
                  trailing: Icon(
                    isExpanded
                        ? Icons.arrow_drop_down_circle
                        : Icons.arrow_drop_down,
                  ),
                  children: [
                    for (var i = 0; i < filter.options.length; i++)
                      CheckboxListTile(
                        title: Text(filter.options[i]),
                        value: selectedOptionsMap[filter.typeName]?[i],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedOptionsMap[filter.typeName]?[i] = value ?? true;
                          });
                        },
                      ),
                  ],
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      isExpanded = expanded;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*  void _seedDatabase() async {
    DatabaseReference databaseReference = widget.database.ref();

    // Loop through the dummyFilters and add them to the database
    for (var filter in dummyFilters) {
      await databaseReference.child('filters').push().set({
        'typeName': filter.typeName,
        'options': filter.options.map((option) => option).toList(),
      });
    }
  }*/