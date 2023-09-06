import 'dart:async';

import 'package:expo_nomade/admin_forms/Object/ObjectEditPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../dataModels/Museum.dart';
import '../../dataModels/MuseumObject.dart';
import '../Object/ObjectAddPage.dart';
import '../Object/ObjectDetailPage.dart';


/// Displays the details of a museum.
/// At the top of the page, the infos of the museum are displayed.
/// Then, the list of objects is displayed.
/// When an object is tapped, the [ObjectDetailPage] is displayed.
///
class MuseumDetailPage extends StatefulWidget {
  final Museum museum;
  final FirebaseDatabase database;

  const MuseumDetailPage({super.key, required this.museum, required this.database});

  @override
  State<StatefulWidget> createState() => _MuseumDetailPageState();
}

class _MuseumDetailPageState extends State<MuseumDetailPage> {
  // A T T R I B U T E S
  late Museum museum;
  late List<MuseumObject> objects = [];
  late StreamSubscription<DatabaseEvent> _museumSubscription;
  late StreamSubscription<DatabaseEvent> _objectsSubscription;


  // M E T H O D S
  @override
  void initState() {
    super.initState();

    // // Récupère le musée passé en paramètre
     museum = widget.museum;

    // Load the objects of the museum from firebase & override the local objects list
    _loadDataAndListen()
        .whenComplete(() => 'Data loaded successfully')
        .catchError((e) => print('Data load error $e'));
  }

  @override
  void dispose() {
    _museumSubscription?.cancel();
    _objectsSubscription?.cancel();
    objects?.clear();
    super.dispose();

  }


  void _showDeleteConfirmationDialog(BuildContext context, MuseumObject object)
  {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: const Text(
                'Êtes-vous sûr de vouloir supprimer cet objet ? Cette action est irreversible'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {


                  _deleteObject(object);

                  //mettre à jour l'interface utilisateur après la suppression de l'objet
                  setState(() {
                    objects?.remove(object);
                  });


                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        });
  }

  Future<void> _deleteObject(MuseumObject object) async{
    try{

      await widget.database.ref().child('museumObjects').child(object.id).remove()
                  .whenComplete(() => print("DELETE OBJECT SUCCESS"))
                  .catchError((e) => print("DELETE OBJECT ERROR while deleting : $e"));
      }
      catch(e){
        print("DELETE OBJECT ERROR: $e");
      }
  }

  Future<void> _loadDataAndListen() async
  {
    // 1) Récuperer de la DB le musée passé en paramètre, et écouter les changements
    await _loadMuseumAndListen()
            .whenComplete(() => print('Museum Loaded successfully : ${museum.toString()}'))
            .catchError((e) => print('Museum Load Error $e'));

    // 2) Récupérer de la DB les objets du musée passé en paramètre, et écouter les changements
    await _loadObjectsAndListen()
            .whenComplete(() => print('Objects Loaded successfully : ${objects.toString()}'))
            .catchError((e) => print('Objects Load Error $e'));

  }

  Future<void> _loadMuseumAndListen() async{
    DatabaseReference museumsRef = widget.database.ref().child('museums').child(museum.id);

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    _museumSubscription = museumsRef.onValue.listen((DatabaseEvent event)
    {
      if (event.snapshot.value != null)
      {
        Map<dynamic, dynamic> museumData = event.snapshot.value as Map<dynamic,dynamic>;

        Museum updatedMuseum = Museum(
          id: museum.id,
          name: museumData['name'] as String,
          address: LatLng(
            (museumData['address']['latitude'] as num).toDouble(),
            (museumData['address']['longitude'] as num).toDouble(),
          ),
          website: museumData['website'] as String,
        );


        // Vérifier le widget tree est toujours monté avant de mettre à jour l'état
        if (mounted)
        {
          print("UPDATE MUSEUM ${updatedMuseum.toString()}");
          setState(() {
            museum = updatedMuseum;
          });
        }

      }

    });
  }

  Future<void> _loadObjectsAndListen() async
  {
    DatabaseReference objectsRef = widget.database.ref().child('museumObjects');

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    _objectsSubscription = objectsRef.onValue.listen((DatabaseEvent event)
    {
      if (event.snapshot.value != null)
      {

        List<MuseumObject> updatedObjects = [];
        Map<dynamic, dynamic> objectsData = event.snapshot.value as Map<dynamic,dynamic>;

        objectsData.forEach((key, value)
        {
          MuseumObject updatedObject = MuseumObject(
              id: key,
              museumName: value['museumName'] as String,
              name: value['name'] as String,
              description: value['description'] as String,
              point: LatLng(
                (value['point']['latitude'] as num).toDouble(),
                (value['point']['longitude'] as num).toDouble(),
              ),
          );

          updatedObjects.add(updatedObject);


        });

        // Vérifier le widget tree est toujours monté avant de mettre à jour l'état
        if (mounted)
        {
          print("UPDATE OBJECTS ${updatedObjects.toString()}");
          setState(() {
            objects = updatedObjects;
          });
        }
      }
    });
  }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {

    // Filtrer les objets en fonction du nom du musée
    final filteredObjects = objects.where((object) => object.museumName == museum.name).toList();

    // Trier les objets par ordre alphabétique du nom d'objet
    filteredObjects.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.museum.name),
      ),
      body: museum != null
          ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adresse: latitude ${museum.address.latitude} & longitude ${museum.address.longitude} '),
              Text('Site web: ${museum.website}'),
              Text('Objets:'),

              // Display the list of objects
              filteredObjects.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredObjects.length,
                    // Coalecing operator : si museum.objects est null, alors on retourne 0, sinon on retourne la longueur de la liste
                    itemBuilder: (context, index) {
                      final object = filteredObjects?[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(object?.name ?? ''),
                            subtitle: Text(object?.description ?? ''),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ObjectDetailPage(
                                        object: object!,
                                        database: widget.database)), // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  // NAV MUSEUM EDIT PAGE
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ObjectEditPage(
                                              object: object!,
                                              database: widget.database)),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_rounded),
                                ),
                                IconButton(
                                  // DELETE MUSEUM
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                        context,
                                        object!);
                                  },
                                  icon: const Icon(Icons.delete_rounded),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 2),
                          // Add a divider between each ListTile
                        ],
                      );
                    },
                  )
              : const Text('Aucun objet disponible pour ce musée'),
        ],
      )
          : Center(
            child: CircularProgressIndicator(), // Show a loading indicator while data is loading
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ObjectAddPage(database: widget.database, sourceMuseum: museum)));
            },
            label: Text('Ajouter objet'),
            icon: Icon(Icons.add_rounded),
            heroTag: 'add_obect',
          ),
        ],
      ),
    );
  }
}
