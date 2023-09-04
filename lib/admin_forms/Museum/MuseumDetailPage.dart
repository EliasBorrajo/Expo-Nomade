import 'dart:async';

import 'package:expo_nomade/admin_forms/Museum/Object/ObjectEditPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../dataModels/Museum.dart';
import '../../dataModels/MuseumObject.dart';
import 'Object/ObjectAddPage.dart';
import 'Object/ObjectDetailPage.dart';

// TODO : ajout de la fonctionnalité de recherche d'objet par nom

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

    // Récupère le musée passé en paramètre
    museum = widget.museum;
    if(widget.museum.objects != null)
      {
        // Recupere la liste des objets du musée
        objects = widget.museum.objects!;
      }

    // Load the objects of the museum from firebase & override the local objects list
    _loadDataAndListen();

  }

  // List all life cycle methods here for reference
  // https://api.flutter.dev/flutter/widgets/State-class.html
  // void initState() { super.initState(); }
  // void didChangeDependencies() { super.didChangeDependencies(); }
  // void didUpdateWidget(covariant MuseumDetailPage oldWidget) { super.didUpdateWidget(oldWidget); }
  // void deactivate() { super.deactivate(); }
  // void dispose() { super.dispose(); }
  // void reassemble() { super.reassemble(); }
  // void setState(VoidCallback fn) { super.setState(fn); }
  // void didChangeAccessibilityFeatures() { super.didChangeAccessibilityFeatures(); }

  @override
  void dispose() {
    _museumSubscription?.cancel();
    _objectsSubscription?.cancel();
    super.dispose();

  }


  void _showDeleteConfirmationDialog(BuildContext context, Museum museum, MuseumObject object)
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


                  _deleteObject(museum, object);

                  // Réactivez cette partie pour mettre à jour l'interface utilisateur après la suppression de l'objet
                  setState(() {
                    // Mettez à jour la liste des objets dans l'état du widget
                    widget.museum.objects?.remove(object);
                  });


                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        });
  }

  Future<void> _deleteObject(Museum museum, MuseumObject object) async{
    try{
      // stocker la ref du musée dans une variable
      final museumRef = widget.database.ref().child('museums').child(museum.id);

      // afficher dans la console la ref du musée, son nom et son id, puis sa liste d'objets
      print('Museum ref:  ${museumRef.key}');
      print('Museum id:   ${museum.id}');
      print('Museum name: ${museum.name}');
      print('Museum objects: ${museum.objects.toString()}');

      // stocker la ref de l'objet voulu dans une variable
      // final objectRef = museumRef.child('objects').child(object.id);
      final objectRef = museumRef.child('objects').child(object.id);


      // afficher dans la console la ref de l'objet, son nom et son id
      print('Object ref:  ${objectRef.key}');
      print('Object id:   ${object.id}');
      print('Object name: ${object.name}');

      try{
        // supprimer l'objet
        await objectRef.remove()
            .whenComplete(() => print("DELETE OBJECT SUCCESS"))
            .catchError((e) => print("DELETE OBJECT ERROR while deleting : $e"));

        //await objectRef.set(null);
      }
      catch(e){
        print("DELETE OBJECT ERROR specific : $e");
      }

    }
    catch(e){
      print("DELETE OBJECT ERROR : $e");
    }


  }

  void _loadDataAndListen() async
  {
    // 1) Récuperer de la DB le musée passé en paramètre, et écouter les changements
    _loadMuseumAndListen()
        .whenComplete(() => print('Museum Loaded successfully : ${museum.toString()}'))
        .catchError((e) => print('Museum Load Error $e'));

    // 2) Récupérer de la DB les objets du musée passé en paramètre, et écouter les changements
    _loadObjectsAndListen()
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
        // value : valeur de l'instantané, ici les musées
        // snapshot.value est de type dynamic, donc on doit le caster en Map<dynamic, dynamic> pour pouvoir utiliser la méthode forEach dessus
        // Map<dynamic, dynamic> : Map<clé, valeur> où clé et valeur sont de type dynamic (donc on peut mettre n'importe quel type)
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
          setState(() {
            museum = updatedMuseum;
          });
        }

      }

    });
  }

  Future<void> _loadObjectsAndListen() async
  {
    DatabaseReference objectsRef = widget.database.ref().child('museums').child(museum.id).child('objects');

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    _objectsSubscription = objectsRef.onValue.listen((DatabaseEvent event)
    {
      if (event.snapshot.value != null)
      {
        List<MuseumObject> updatedObjects = [];
        Map<dynamic, dynamic> objectsData = event.snapshot.value as Map<dynamic,dynamic>;
        // value : valeur de l'instantané, ici les musées
        // snapshot.value est de type dynamic, donc on doit le caster en Map<dynamic, dynamic> pour pouvoir utiliser la méthode forEach dessus
        // Map<dynamic, dynamic> : Map<clé, valeur> où clé et valeur sont de type dynamic (donc on peut mettre n'importe quel type)

        // For each object in the DB
        objectsData.forEach((key, value)
        {
          // 1) Create a new MuseumObject from the data
          MuseumObject object = MuseumObject(
            id: key as String,
            name: value['name'] as String,
            description: value['description'] as String,
            point: LatLng(
              (value['point']['latitude'] as num).toDouble(),
              (value['point']['longitude'] as num).toDouble(),
            ),
          );

          // 2) Add the new MuseumObject to the list
          updatedObjects.add(object);
        });


        // Vérifier le widget tree est toujours monté avant de mettre à jour l'état
        if (mounted)
        {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(museum.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Adresse: latitude ${museum.address.latitude} & longitude ${museum.address.longitude} '),
          Text('Site web: ${museum.website}'),
          Text('Objets:'),

          // Display the list of objects
          objects != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: objects?.length ?? 0,
                  // Coalecing operator : si museum.objects est null, alors on retourne 0, sinon on retourne la longueur de la liste
                  itemBuilder: (context, index) {
                    final object = objects?[index];
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
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                // DELETE MUSEUM
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context,
                                      museum,
                                      object!); // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                                },
                                icon: const Icon(Icons.delete),
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
                          ObjectAddPage(database: widget.database)));
            },
            label: Text('Ajouter objet'),
            icon: Icon(Icons.add),
            heroTag: 'add_obect',
          ),
        ],
      ),
    );
  }
}
