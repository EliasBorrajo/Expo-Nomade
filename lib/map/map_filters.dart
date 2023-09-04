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

  @override
  void initState() {
    super.initState();
    fetchFilters();
  }

  void fetchFilters() async {
    try {
      DatabaseEvent event = await _database.once();
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            List<FilterTag> fetchedFilters = data.entries
                .map((entry) {
              String filterId = entry.key;
              Map<String, dynamic> filterData = Map<String, dynamic>.from(entry.value);
              return FilterTag(
                id: filterId,
                typeName: filterData['typeName'] ?? '',
                options: List<String>.from(filterData['options'] ?? []),
              );
            })
                .toList();

            setState(() {
              filters = fetchedFilters;
            });
          }
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft, // Alignement en bas à gauche
      child: AlertDialog(
        title: const Text('Filtres'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (var filter in filters)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${filter.typeName}'),
                    for (var option in filter.options)
                      CheckboxListTile(
                        title: Text(option),
                        value: true, // Remplacez par la logique de sélection appropriée
                        onChanged: (value) {
                          setState(() {
                            // Mettez à jour la sélection ici
                          });
                        },
                      ),
                    Divider(), // Ajoutez un séparateur entre les filtres
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la fenêtre de filtre
            },
            child: const Text('Fermer'),
          ),
          TextButton(onPressed: _seedDatabase, child: const Text('Seed'))
        ],
      ),
    );
  }

/*  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtres'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (var filter in filters)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${filter.typeName}'),
                  for (var option in filter.options)
                    CheckboxListTile(
                      title: Text(option),
                      value: true, // Remplacez par la logique de sélection appropriée
                      onChanged: (value) {
                        setState(() {
                          // Mettez à jour la sélection ici
                        });
                      },
                    ),
                  Divider(), // Ajoutez un séparateur entre les filtres
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermer la fenêtre de filtre
          },
          child: const Text('Fermer'),
        ),
        TextButton(onPressed: _seedDatabase, child: const Text('Seed'))
      ],
    );
  }*/

  void _seedDatabase() async {
    DatabaseReference databaseReference = widget.database.ref();

    // Loop through the dummyFilters and add them to the database
    for (var filter in dummyFilters) {
      await databaseReference.child('filters').push().set({
        'typeName': filter.typeName,
        'options': filter.options.map((option) => option).toList(),
      });
    }
  }
}