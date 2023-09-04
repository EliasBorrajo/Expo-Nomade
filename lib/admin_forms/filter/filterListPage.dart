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

  void _navigateToAddFilterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFilterPage(database: widget.database),
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
    return Scaffold(
      appBar: AppBar(
          title: const Text('Liste des filtres')
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
                    return filter.typeName.toLowerCase().contains(query);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddFilterPage,
        label: const Text('Ajouter un filtre'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
/*
  void _seedDatabase() async {
    DatabaseReference databaseReference = widget.database.ref();

    // Loop through the dummyQuiz and add them to the database
    for (var question in dummyQuiz) {
      await databaseReference.child('quiz').push().set({
        'questionText': question.questionText,
        'answers': question.answers.map((answer) => answer).toList(),
        'correctAnswer': question.correctAnswer,
      });
    }
  }
}*/

/*
class ObjectListPage extends StatefulWidget {
  final FirebaseDatabase database;

  // TODO changer
  const ObjectListPage({super.key, required this.database});

  @override
  _ObjectListPage createState() => _ObjectListPage();
}

class _ObjectListPage extends State<ObjectListPage> {
  List<Object> objects = [];

  @override
  void initState() {
    super.initState();
    fetchObjects();
  }

  void fetchObjects() async {
    //try {
    DatabaseReference objectRef = widget.database.ref().child('museumObjects');
    objectRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Object> fetchedObjects = data.entries.map((entry) {
          Map<String, dynamic> objectData =
          Map<String, dynamic>.from(entry.value);
          return MuseumObject(
            name: objectData['name'] ?? '',
            description: objectData['descripton'] ?? '',
              point: LatLng(
              (objectData['point']['latitude'] as num).toDouble(),
              (objectData['point']['longitude'] as num).toDouble(),
              ),
              tags: List<Tag>.from(objectData['tags'] ?? []),
            //images
          );
        }).toList();

        setState(() {
          objects = fetchedObjects;
        });
      }
    });
  }

  void _deleteMuseumObject(String name) async {
    try {
      await widget.database.ref().child('museumObjects').child(name).remove();
      fetchObjects(); // Rafraîchir la liste des questions après la suppression

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cet objet a été supprimé avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting object: $error');

      // Afficher un message d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la suppression de cet objet.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
/*
  void _navigateToAddQuestionPage() async {
    // Naviguer vers la page d'ajout de question et attendre un éventuel retour
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(database: widget.database),
      ),
    );
  }

  void _navigateToEditQuestionPage(Question question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditQuestionPage(database: widget.database, question: question),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Objets')),
      body: objects.isEmpty
          ? const Center(
        child: Text(
          'Aucun objet trouvé dans la base de données.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return Column(
            /*children: [
              QuestionListItem(
                  question: questions[index],
                  onDeletePressed: _deleteQuestion),
              Divider(height: 1), // Ajoute une ligne de séparation
            ],*/
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //_navigateToAddQuestionPage();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}*/
