
import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/Museum.dart';
import 'MigrationDetailsPage.dart';


// TODO : Ajouter le BTN + pour ajouter un musée
// TODO : Supprimer un musée avec un long press sur le musée

/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.
///
class MigrationListPage extends StatelessWidget {
  final List<Migration> migrations;
  final FirebaseDatabase database;

  const MigrationListPage({super.key, required this.migrations ,  required this.database}); // Constructeur
/*
  // void _seedDatabase() async {
  //   // Get a reference to your Firebase database
  //   DatabaseReference databaseReference = database.ref();
  //
  //   // Loop through the dummyMuseums and add them to the database
  //   for (var museum in migrations) {
  //     await databaseReference.child('museums').push().set({
  //       'name': museum.name,
  //       'address': {
  //         'latitude': museum.address.latitude,
  //         'longitude': museum.address.longitude,
  //       },
  //       'website': museum.website,
  //       // Add other fields as needed
  //     });
  //   }
  // }
  //
  // void _readDatabase() async {
  //   DatabaseReference databaseReference = database.ref().child('museums');
  //
  //   DataSnapshot snapshot = await databaseReference.get();
  //
  //   if (snapshot.value != null) {
  //     print('Museum data:');
  //     Map<dynamic, dynamic> museumsData = snapshot.value as Map<dynamic, dynamic> ;
  //     museumsData.forEach((key, value) {
  //       print('Museum ID: $key');
  //       print('Name: ${value['name']}');
  //       print('Address:');
  //       print('  Latitude: ${value['address']['latitude']}');
  //       print('  Longitude: ${value['address']['longitude']}');
  //       print('Website: ${value['website']}');
  //       print('---');
  //     });
  //   } else {
  //     print('No museums found in the database.');
  //   }
  // }
*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des musées',
      home: Scaffold(
        body: ListView.builder(
          itemCount: migrations.length,
          itemBuilder: (context, index) {
            final migration = migrations[index];
            return ListTile(
              title: Text(migration.name),
              subtitle: Text('Zones : ${migration.polygons?.length.toString() ?? '0'}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MigrationDetailsPage(migration: migration)),
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
            // FloatingActionButton.extended(
            //   onPressed: _seedDatabase,
            //   label: Text('Seed Database'),
            //   icon: Icon(Icons.cloud_upload),
            //   heroTag: 'seed_database',
            // ),
            // SizedBox(height: 10),
            // FloatingActionButton.extended(
            //   onPressed: _readDatabase,  // Utilise la méthode de lecture
            //   label: Text('Read Database'),  // Libellé du bouton
            //   icon: Icon(Icons.cloud_download),  // Icône du bouton
            //   heroTag: 'read_database',  // Tag héros unique
            // ),
          ],
        ),
      ),
    );
  }
}
