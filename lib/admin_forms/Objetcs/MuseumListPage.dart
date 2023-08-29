import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/Museum.dart';
import 'MuseumDetailPage.dart';


// TODO : Ajouter le BTN + pour ajouter un musée
// TODO : Supprimer un musée avec un long press sur le musée

/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.
///
class MuseumListPage extends StatelessWidget {
  final List<Museum> museums;
  final FirebaseFirestore firestore;
  final FirebaseDatabase database;

  const MuseumListPage({required this.museums, required this.firestore, required this.database}); // Constructeur

  void _seedDatabase_OLD() async {
    // Get a reference to your Firebase database
    DatabaseReference databaseReference = database.ref();

    // Loop through the dummyMuseums and add them to the database
    for (var museum in museums) {
      await databaseReference.child('museums').push().set({
        'name': museum.name,
        'address': {
          'latitude': museum.address.latitude,
          'longitude': museum.address.longitude,
        },
        'website': museum.website,
        // Add other fields as needed
      });
    }
  }

  void _seedDatabase() async {
    // Get a reference to your Firestore instance
    FirebaseFirestore firestore = this.firestore;

    // Reference to the 'museums' collection in Firestore
    CollectionReference museumsCollection = firestore.collection('museums');

    // Loop through the dummyMuseums and add them to the Firestore collection
    for (var museum in museums) {
      await museumsCollection.add({
        'name': museum.name,
        'address': {
          'latitude': museum.address.latitude,
          'longitude': museum.address.longitude,
        },
        'website': museum.website,
        // Add other fields as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des musées',
      home: Scaffold(
        appBar: AppBar(title: Text('Liste des musées')),
        body: ListView.builder(
          itemCount: museums.length,
          itemBuilder: (context, index) {
            final museum = museums[index];
            return ListTile(
              title: Text(museum.name),
              subtitle: Text('Objects : ${museum.objects?.length.toString() ?? '0'}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MuseumDetailPage(museum: museum)),
                );
              },
            );
          },
        ),

        // Add a FAB to the bottom right
        // FAB : Floating Action Button
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // ToDo : Naviguer vers la page d'ajout de musée
              },
              label: Text('Add museum'),
              icon: Icon(Icons.add),
              heroTag: 'add_museum',
            ),
            SizedBox(height: 10), // Add some spacing between the FABs
            FloatingActionButton.extended(
              onPressed: _seedDatabase_OLD,
              label: Text('Seed Database'),
              icon: Icon(Icons.cloud_upload),
              heroTag: 'seed_database',
            ),
          ],
        ),
      ),
    );
  }
}
