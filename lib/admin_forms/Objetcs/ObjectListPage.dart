import 'package:expo_nomade/admin_forms/quiz/question_add_page.dart';
import 'package:expo_nomade/admin_forms/quiz/question_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/MuseumObject.dart';
import '../../dataModels/Tag.dart';
import 'package:latlong2/latlong.dart';


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
}
