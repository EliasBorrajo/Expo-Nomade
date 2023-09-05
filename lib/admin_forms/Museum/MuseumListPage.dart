
import 'dart:async';
import 'package:expo_nomade/admin_forms/dummyData.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../../dataModels/Museum.dart';
import '../../dataModels/MuseumObject.dart';
import 'MuseumAddPage.dart';
import 'MuseumDetailPage.dart';
import 'MuseumEditPage.dart';


/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.
class MuseumListPage extends StatefulWidget {
  final FirebaseDatabase database;

  // Constructeur
  const MuseumListPage({Key? key, required this.database}) : super(key: key);

  // Gestion de l'état de la page
  @override
  _MuseumListPageState createState() => _MuseumListPageState();
}


class _MuseumListPageState extends State<MuseumListPage> {
  // A T T R I B U T E S
  late List<Museum> museums = []; // List to be filled by Firebase DB
  late StreamSubscription<DatabaseEvent> _museumsSubscription; // Subscription to Firebase DB updates (when data changes)

  // M E T H O D S
  @override
  void initState() {
    super.initState();
    _loadMuseumsFromFirebaseAndListen();
  }

  @override
  void dispose() {
    _museumsSubscription?.cancel(); // Cancel the Firebase DB subscription when the widget is removed from the widget tree. Prevents memory leaks.
    super.dispose();
  }

  @override
  void stateChanged() {
    if (mounted) {
      _loadMuseumsFromFirebaseAndListen();
    }
  }


  void _loadMuseumsFromFirebaseAndListen() async
  {
    DatabaseReference museumsRef = widget.database.ref().child('museums');

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    _museumsSubscription = museumsRef.onValue.listen((DatabaseEvent event)
    {
      if (event.snapshot.value != null)
      {
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic,dynamic>;

        museumsData.forEach((key, value)
        {
          // M U S E U M S
          // 1) Récupérer les musées et y ajouter les objets de l'étape 1
          Museum museum = Museum(
            id: key,
            name: value['name'] as String,
            address: LatLng(
              // Vériier que les valeurs sont bien des doubles, firebase peut les convertir en int parfois
              (value['address']['latitude'] as num).toDouble(),
              (value['address']['longitude'] as num).toDouble(),
            ),
            website: value['website'] as String,
          );

          // 2) Ajouter le musée à la liste des musées
          updatedMuseums.add(museum);


          // 3) Vérifier le widget tree est toujours monté avant de mettre à jour l'état
          if (mounted)
          {
            setState(() {
              museums = updatedMuseums;
            });
          }
        });
      }
    });

  }


  void _seedDatabase() async {
    print("Seed database");

    // Get a reference to your Firebase database
    DatabaseReference databaseReference = widget.database.ref();

    try {
      await seedMuseums(databaseReference);

      // SEED OBJECTS
      await seedMuseumObjects(databaseReference);

      print('Database seeding completed.');
    }
    catch (error) {
      print('Error seeding database: $error');
    }
  }

  Future<void> seedMuseumObjects(DatabaseReference databaseReference) async {

    for(var object in dummyObjects)
    {
      // Convert the object to a Map<String, dynamic> object that can be stored in the database
      Map<String, dynamic> objectData =
      {
        'name': object.name,
        'museumName': object.museumName,
        'description': object.description,
        'point': {
          'latitude': object.point.latitude.toDouble(),
          'longitude': object.point.longitude.toDouble(),
        },
      };

      await databaseReference.child('museumObjects').push().set(objectData);
      print('Object seeded successfully: ${object.name}');
    }
  }

  Future<void> seedMuseums(DatabaseReference databaseReference) async {
    for (var museum in dummyMuseums)
    {
      // Convert the museum object to a Map<String, dynamic> object that can be stored in the database
      Map<String, dynamic> museumData =
      {
        'name': museum.name,
        'address': {
          'latitude': museum.address.latitude.toDouble(),
          'longitude': museum.address.longitude.toDouble(),
        },
        'website': museum.website,
      };


      await databaseReference.child('museums').push().set(museumData);
      print('Museum seeded successfully: ${museum.name}');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Museum museum) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Êtes-vous sûr de vouloir supprimer ce musée ? Cette action est irreversible'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  widget.database.ref().child('museums').child(museum.id).remove();
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    // Sort the museums list alphabetically by name
    museums.sort((a, b) => a.name.compareTo(b.name));

    return MaterialApp(
      title: 'Liste des musées',
      home: Scaffold(
        appBar: AppBar(title: Text('Liste des musées')),
        body: ListView.builder(
          itemCount: museums.length,
          itemBuilder: (context, index) {
            final museum = museums[index];
            return Column(
                children: [
                  ListTile(
                    title: Text(museum.name),
                    subtitle: Text(museum.website),
                    onTap: ()
                    {
                      // NAV MUSEUM DETAIL PAGE
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MuseumDetailPage(museum: museum, database: widget.database,)),
                        );},

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          // NAV MUSEUM EDIT PAGE
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => MuseumEditPage(museum: museum, database: widget.database)),
                            );                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          // DELETE MUSEUM
                          onPressed: () {
                            //_showDeleteConfirmationDialog(context);
                            _showDeleteConfirmationDialog(context, museum!);    // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),


                  ),
                  const Divider(height: 2), // Add a divider between each ListTile
                ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      MuseumAddPage(database: widget.database)),
                );
              },
              label: Text('Add museum'),
              icon: Icon(Icons.add),
              heroTag: 'add_museum',
            ),
            SizedBox(height: 10), // Add some spacing between the FABs
            FloatingActionButton.extended(
              onPressed: _seedDatabase,
              label: Text('Seed Database'),
              icon: Icon(Icons.cloud_upload),
              heroTag: 'seed_database',
            ),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}


