import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/Museum.dart';
import 'MuseumDetailPage.dart';


// TODO : Ajouter le BTN + pour ajouter un musée
// TODO : Supprimer un musée avec un long press sur le musée

/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.
///
class MuseumListPage extends StatefulWidget {
  final FirebaseDatabase database;

  const MuseumListPage({super.key, required this.database}); // Constructeur

  @override
  _MuseumListPageState createState() => _MuseumListPageState();
}

class _MuseumListPageState extends State<MuseumListPage> {
  List<Museum> museums = [];

  @override
  void initState() {
    super.initState();
    fetchMuseums();
  }

  void fetchMuseums() async {
    try {
      DatabaseEvent event = await widget.database.ref().child('museums').once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          museums = data.entries
              .map((entry) => Museum.fromMap(Map<String, dynamic>.from(entry.value)))
              .toList();
        });
      }
    } catch (error) {
      print('Error fetching museums: $error');
      // Gérer l'erreur en conséquence, par exemple, afficher un message d'erreur à l'utilisateur.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Musées')),
      body: ListView.builder(
        itemCount: museums.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(museums[index].name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Editer le musée
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Supprimer le musée
                  },
                  icon: Icon(Icons.delete),
                )
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MuseumDetailPage(museum: museums[index])),
              );            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Naviguer vers la page de création du musée
        },
        child: Icon(Icons.add),
      ),
    );
  }
}