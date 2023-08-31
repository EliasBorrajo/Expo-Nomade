import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/Coordinate.dart';
import '../../dataModels/Museum.dart';
import 'MuseumDetailPage.dart';


// TODO : Ajouter le BTN + pour ajouter un musée
// TODO : Supprimer un musée avec un long press sur le musée

/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.

class MuseumListPage extends StatefulWidget {
  final FirebaseDatabase database;

  // Constructeur
  const MuseumListPage({super.key,  required this.database});

  // Gestion de l'état de la page
  @override
  _MuseumListPageState createState() => _MuseumListPageState(  );
}


class _MuseumListPageState extends State<MuseumListPage> {

  late List<Museum> museums = [];


  @override
  void initState() {
    super.initState();
    // Pas besoin de faire un async ou future,
    // car ne bloque pas le thread principal (pas de await)
    // et ne retourne rien (void) donc pas besoin de future
    //_loadMuseumsFromFirebase();
    _loadMuseumsFromFirebaseAndListen();

    // TODO : FAIRE UNE TERAIRE DU GRAPHIQUE ET VOIR QUAND LES DATA SONT CHARGEES

  }

  // void _loadMuseumsFromFirebase() async {
  //   // Charge les musées depuis la Firebase
  //   // Utilise la référence appropriée à ta structure de base de données
  //   // Par exemple : DatabaseReference museumRef = database.reference().child('museums');
  //   // Ensuite, utilise .once() pour obtenir une seule lecture initiale
  //   // Et .onValue pour configurer l'écouteur en temps réel
  //   // Mets à jour la liste 'museums' avec les données reçues
  //
  //   DatabaseReference museumsRef = database.ref().child('museums');
  //
  //   museumsRef.once().then((DatabaseEvent event) // Utilise .once() pour obtenir une seule lecture initiale
  //   {
  //     if (event.snapshot.value != null)
  //     {
  //       DataSnapshot snapshot = event.snapshot;   // snapshot : instantané de la base de données à un moment donné
  //       Map<dynamic, dynamic> museumsData = snapshot.value as Map<dynamic, dynamic> ;
  //           // value : valeur de l'instantané, ici les musées
  //           // snapshot.value est de type dynamic, donc on doit le caster en Map<dynamic, dynamic> pour pouvoir utiliser la méthode forEach dessus
  //           // Map<dynamic, dynamic> : Map<clé, valeur> où clé et valeur sont de type dynamic (donc on peut mettre n'importe quel type)
  //       List<Museum> loadedMuseums = [];
  //
  //       museumsData.forEach((key, value) {
  //         Museum museum = Museum(
  //           id: key,
  //           name: value['name'],
  //           address: Coordinate(
  //             latitude: value['address']['latitude'],
  //             longitude: value['address']['longitude'],
  //           ),
  //           website: value['website'],
  //         );
  //         loadedMuseums.add(museum);
  //       });
  //
  //       // Mets à jour la liste 'museums' local avec les données reçues
  //       setState(() {
  //         museums = loadedMuseums;
  //       });
  //
  //     }
  //   });
  //
  //   // Display the museums data in the console TODO : Remove
  //   _printMuseumsData(museums);
  //
  // }

  void _loadMuseumsFromFirebaseAndListen() {
    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    // Utilise .onValue pour écouter les changements et mettre à jour la liste 'museums'

    DatabaseReference museumsRef = widget.database.ref().child('museums');

    museumsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null)
      {
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic, dynamic>;
        // value : valeur de l'instantané, ici les musées
        // snapshot.value est de type dynamic, donc on doit le caster en Map<dynamic, dynamic> pour pouvoir utiliser la méthode forEach dessus
        // Map<dynamic, dynamic> : Map<clé, valeur> où clé et valeur sont de type dynamic (donc on peut mettre n'importe quel type)

        museumsData.forEach((key, value) {
          Museum museum = Museum(
            id: key,
            name: value['name'],
            address: Coordinate(
              latitude: value['address']['latitude'],
              longitude: value['address']['longitude'],
            ),
            website: value['website'],
          );
          updatedMuseums.add(museum);
        });

        setState(() {
          museums = updatedMuseums;

        });
      }
    });

    // Display the museums data in the console TODO : Remove
    _printMuseumsData(museums);
  }


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
    // Get a reference to your Firebase database
    DatabaseReference databaseReference = widget.database.ref();

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

  void _readDatabase() async {
    DatabaseReference databaseReference = widget.database.ref().child('museums');

    DataSnapshot snapshot = await databaseReference.get();

    if (snapshot.value != null) {
      print('Museum data:');
      Map<dynamic, dynamic> museumsData = snapshot.value as Map<dynamic, dynamic> ;
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
              onPressed: _seedDatabase,
              label: Text('Seed Database'),
              icon: Icon(Icons.cloud_upload),
              heroTag: 'seed_database',
            ),
            SizedBox(height: 10),
            FloatingActionButton.extended(
              onPressed: _readDatabase,  // Utilise la méthode de lecture
              label: Text('Read Database'),  // Libellé du bouton
              icon: Icon(Icons.cloud_download),  // Icône du bouton
              heroTag: 'read_database',  // Tag héros unique
            ),
          ],
        ),
      ),
    );
  }
}
