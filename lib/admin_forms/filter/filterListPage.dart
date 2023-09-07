import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/filters_tags.dart';
import 'editFilterPage.dart';
import 'addFilterPage.dart';
import 'optionListItem.dart';


class FilterListPage extends StatefulWidget {
  final FirebaseDatabase database;

  const FilterListPage({super.key, required this.database});

  @override
  _FilterListPageState createState() => _FilterListPageState();
}

class _FilterListPageState extends State<FilterListPage> {
  List<FilterTag> filters = [];
  StreamSubscription<DatabaseEvent>? _subscription;
  final TextEditingController _searchController = TextEditingController();
  List<FilterTag> filteredFilters = [];

  @override
  void initState() {
    super.initState();
    fetchFilters();
  }

  void fetchFilters() async {
    try {
      DatabaseReference filterRef = widget.database.ref().child('filters');

      _subscription = filterRef.onValue.listen((DatabaseEvent event) {
        if (mounted) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<
              dynamic,
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

            setState(() {
              filters = fetchedFilters;
              filteredFilters = fetchedFilters;
            });
          }
        }
      });
    } catch (error) {
      print('Error fetching filters: $error');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // TODO si je delete filter je dois delete aussi dans la liste des objets
  void _deleteFilter(String filterId) async {
    try {
      await widget.database.ref().child('filters').child(filterId).remove();

      if (!context.mounted) return;

      setState(() {
        filters.removeWhere((filter) => filter.id == filterId);
        _searchController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le filtre a été supprimé avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting filter: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la suppression du filtre.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditFilterPage(FilterTag filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditFilterPage(database: widget.database, filter: filter),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredFilters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Liste des filtres',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Liste des filtres'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        AddFilterPage(database: widget.database),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? ElevatedButton(
                      onPressed: _clearSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Icon(Icons.clear),
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredFilters = filters.where((filter) {
                        final query = value.toLowerCase();
                        return filter.options.any((option) =>
                            option.toLowerCase().contains(query));
                      }).toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredFilters.isEmpty
                    ? const Center(
                  child: Text(
                    'Aucun filtre trouvé dans la base de données.',
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredFilters.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        OptionListItem(
                          filter: filteredFilters[index],
                          onDeletePressed: _deleteFilter,
                          onEditPressed: _navigateToEditFilterPage,
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}