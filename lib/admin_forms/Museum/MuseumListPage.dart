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
  const MuseumListPage({super.key, required this.database});

  // Gestion de l'état de la page
  @override
  _MuseumListPageState createState() => _MuseumListPageState();
}


class _MuseumListPageState extends State<MuseumListPage> {
  // A T T R I B U T E S
  late List<Museum> museums = []; // List to be filled by Firebase DB


  // M E T H O D S
  @override
  void initState() {
    super.initState();
    _loadMuseumsFromFirebaseAndListen();
  }

  /// Loads the museums from Firebase and listens for updates.
  /// Updates the local list of museums when the data changes.
  /// All museums are loaded at once.
  /// All objects for each museum are loaded at once.
  void _loadMuseumsFromFirebaseAndListen() async {
    DatabaseReference museumsRef = widget.database.ref().child('museums');

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    museumsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<
            dynamic,
            dynamic>;
        // value : valeur de l'instantané, ici les musées
        // snapshot.value est de type dynamic, donc on doit le caster en Map<dynamic, dynamic> pour pouvoir utiliser la méthode forEach dessus
        // Map<dynamic, dynamic> : Map<clé, valeur> où clé et valeur sont de type dynamic (donc on peut mettre n'importe quel type)

        museumsData.forEach((key, value) {
          // M U S E U M S  O B J E C T S
          List<MuseumObject>? objects = [];
          if (value['objects'] !=
              null) // Si le musée a des objets associés dans la firebase
              {
            List<dynamic> objectsData = value['objects'] as List<dynamic>;

            objectsData.forEach((objValue) {
              MuseumObject object = MuseumObject(
                name: objValue['name'] as String,
                description: objValue['description'] as String,
                point: LatLng(
                  // Vériier que les valeurs sont bien des doubles, firebase peut les convertir en int parfois
                  (objValue['point']['latitude'] as num).toDouble(),
                  (objValue['point']['longitude'] as num).toDouble(),
                ),
              );
              objects.add(object);
            });
          }

          // M U S E U M S
          Museum museum = Museum(
            id: key,
            name: value['name'] as String,
            address: LatLng(
              // Vériier que les valeurs sont bien des doubles, firebase peut les convertir en int parfois
              (value['address']['latitude'] as num).toDouble(),
              (value['address']['longitude'] as num).toDouble(),
            ),
            website: value['website'] as String,
            objects: objects.isEmpty
                ? null
                : objects, // Ajouter les objets du dessus au musée
          );

          updatedMuseums.add(museum);

          setState(() {
            museums = updatedMuseums;
          });
        });
      }
    });

    // Display the museums data in the console TODO : Remove
    _printMuseumsData(museums);
  }

  /// Displays the museums data in the console.
  void _printMuseumsData(List<Museum> museums) {
    // vérifier si la liste est vide
    if (museums.isEmpty) {
      print('No museums found in the list / database.');
      return;
    }

    print('Museums data:');
    for (Museum museum in museums) {
      print('Museum ID: ${museum.id}');
      print('Name: ${museum.name}');
      print('Address:');
      print('  Latitude: ${museum.address.latitude}');
      print('  Longitude: ${museum.address.longitude}');
      print('Website: ${museum.website}');
      print('---');
    }
  }

  void _seedDatabase() async {
    print("Seed database");

    // Get a reference to your Firebase database
    DatabaseReference databaseReference = widget.database.ref();


    try {
      for (var museum in dummyMuseums) {
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

        if (museum.objects != null) {
          museumData['objects'] = [
          ]; // Crée une liste vide d'objets pour le musée dans la firebase (sinon erreur)
          for (var object in museum.objects!) {
            // Ajoute chaque objet du musée dans la firebase (dans la liste d'objets du musée)
            museumData['objects'].add(
                {
                  'name': object.name,
                  'description': object.description,
                  'point': {
                    'latitude': object.point.latitude.toDouble(),
                    'longitude': object.point.longitude.toDouble(),
                  },
                });
          }
        }

        await databaseReference.child('museums').push().set(museumData);
        print('Museum seeded successfully: ${museum.name}');
      }
      print('Database seeding completed.');
    }
    catch (error) {
      print('Error seeding database: $error');
    }
  }

  void _readDatabase() async {
    DatabaseReference databaseReference = widget.database.ref().child(
        'museums');

    DataSnapshot snapshot = await databaseReference.get();

    if (snapshot.value != null) {
      print('Museum data:');
      Map<dynamic, dynamic> museumsData = snapshot.value as Map<dynamic,
          dynamic>;
      museumsData.forEach((key, value) {
        print('Museum ID: $key');
        print('Name: ${value['name']}');
        print('Address:');
        print('  Latitude: ${value['address']['latitude']}');
        print('  Longitude: ${value['address']['longitude']}');
        print('Website: ${value['website']}');
        print('---');
      });
    } else {
      print('No museums found in the database.');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Museum museum) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Êtes-vous sûr de vouloir supprimer cet objet ? Cette action est irreversible'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Supprimer l'objet et mettre à jour la liste d'objets
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
                    subtitle: Text('Objects : ${museum.objects?.length.toString() ?? '0'}'),
                    onTap: ()
                    {
                      // NAV MUSEUM DETAIL PAGE
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MuseumDetailPage(museum: museum)),
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
            FloatingActionButton.extended(
              onPressed: _readDatabase, // Utilise la méthode de lecture
              label: Text('Read Database'), // Libellé du bouton
              icon: Icon(Icons.cloud_download), // Icône du bouton
              heroTag: 'read_database', // Tag héros unique
            ),
          ],
        ),
      ),
    );
  }
}


