import 'package:expo_nomade/map/map_filters.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dataModels/filters_tags.dart';

class ElementFilterPage extends StatefulWidget{

  final FirebaseDatabase database;
  final Map<String, List<bool>> selectedFilterState;

  const ElementFilterPage({super.key, required this.database, required this.selectedFilterState});


  @override
  _ElementFilterPageState createState() => _ElementFilterPageState();
  
}

class _ElementFilterPageState extends State<ElementFilterPage>{
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('filters');
  late List<FilterTag> selectedFilters = [];
  late List<FilterTag> filters = [];

  @override
  void initState() {
    super.initState();
    fetchFilters();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FiltersWindow(database: widget.database, selectedFilterState: widget.selectedFilterState),
              const SizedBox(height: 16),
              FloatingActionButton( // Add FloatingActionButton here
                onPressed: () {
                  selectedFilters = getSelectedFilters(filters, widget.selectedFilterState);
                  // for(var filter in selectedFilters) {
                  //   print(filter);
                  // }
                  Navigator.pop(context, selectedFilters);
                  // Add the functionality you want when the FAB is pressed
                },
                child: const Icon(Icons.save), // Change the icon as per your requirement
              ),

            ],
          )
        ],
      ),
    );
  }

  // List<FilterTag> getSelectedFilters(List<FilterTag> filterTags, Map<String, List<bool>> selectedFilterState) {
  //   List<FilterTag> selectedFilters = [];
  //
  //   for (var filter in filterTags) {
  //     var typeName = filter.typeName;
  //     var selections = selectedFilterState[typeName];
  //
  //     if (selections != null) {
  //       for (var i = 0; i < selections.length; i++) {
  //         if (selections[i]) {
  //           var option = filter.options[i];
  //
  //           var selectedFilter = FilterTag(
  //             id: filter.id, // Assuming FilterTag has an id property
  //             typeName: typeName,
  //             options: [option],
  //             isSelected: true,
  //           );
  //           selectedFilters.add(selectedFilter);
  //         }
  //       }
  //     }
  //   }
  //   return selectedFilters;
  // }

  List<FilterTag> getSelectedFilters(List<FilterTag> filterTags, Map<String, List<bool>> selectedFilterState) {
    Map<String, FilterTag> groupedFilters = {};

    for (var filter in filterTags) {
      var typeName = filter.typeName;
      var selections = selectedFilterState[typeName];

      if (selections != null) {
        for (var i = 0; i < selections.length; i++) {
          if (selections[i]) {
            var option = filter.options[i];

            if (groupedFilters.containsKey(typeName)) {
              groupedFilters[typeName]!.options.add(option);
            } else {
              var selectedFilter = FilterTag(
                id: filter.id, // Assuming FilterTag has an id property
                typeName: typeName,
                options: [option],
              );
              groupedFilters[typeName] = selectedFilter;
            }
          }
        }
      }
    }

    return groupedFilters.values.toList();
  }




  void fetchFilters() async {
    try {
      DatabaseEvent event = await _database.once();
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic,dynamic>?;

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


        if(widget.selectedFilterState.isEmpty) {
          for (var filter in fetchedFilters) {
            widget.selectedFilterState[filter.typeName] = List.filled(filter.options.length, false);
          }
        }

        setState(() {
          filters = fetchedFilters;
        });
      }
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }
}