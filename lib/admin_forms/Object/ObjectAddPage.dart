import 'dart:async';

import 'package:expo_nomade/dataModels/MuseumObject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../dataModels/Museum.dart';
import '../map_point_picker.dart';

// TODO : Ajouter images
// TODO : Ajouter tags
// TODO : Voir si je peux supprimer certains appel à _loadAllObjectsFromAMuseum() qui sont inutiles

class ObjectAddPage extends StatefulWidget{

  final FirebaseDatabase database;
  final Museum? sourceMuseum;

  const ObjectAddPage({Key? key, required this.database, this.sourceMuseum}) : super(key: key);

  @override
  _ObjectAddPageState createState() => _ObjectAddPageState();
}

class _ObjectAddPageState extends State<ObjectAddPage> {
  // A T T R I B U T E S
  late TextEditingController _nameController;
  late TextEditingController _museumNameController;
  late TextEditingController _descriptionController;
  late LatLng selectedAddressPoint = const LatLng(0.0, 0.0);
  late LatLng displayAddressPoint = const LatLng(0.0, 0.0);
  late DatabaseReference _objectsRef;
  late List<Museum> museumsList = [];
  late Museum _selectedMuseum = Museum(id: '0', name: 'No museum selected',website: 'No website', address: const LatLng(0.0, 0.0));
  late List<MuseumObject>   museumObjectsFromSelectedMuseum = [];
  late StreamSubscription<DatabaseEvent> _museumsSubscription;

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // M E T H O D S
  @override
  void initState() {
    super.initState();
    _nameController        = TextEditingController(text: "");
    _descriptionController = TextEditingController(text: "");
    _museumNameController  = TextEditingController(text: widget.sourceMuseum?.name ?? ""); // Si le musée source est null, mettre une chaine vide


    // F I R E B A S E
    _objectsRef = widget.database.ref().child('museumObjects');

    print('MUSEUM SOURCE IS : ${widget.sourceMuseum?.name}');
    _loadMuseumsFromFirebaseAndListen()
        .then((_) => { _loadAllObjectsFromAMuseum(_selectedMuseum) }) // Permet de précharger la liste,
        .whenComplete(() => print('Museums loaded'));

  }

  @override
  void dispose() {
    _nameController.dispose();
    _museumNameController.dispose();
    _descriptionController.dispose();
    _museumsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMuseumsFromFirebaseAndListen() async
  {
    DatabaseReference museumsRef = widget.database.ref().child('museums');

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    _museumsSubscription = museumsRef.onValue.listen((DatabaseEvent event)
    {
      if (event.snapshot.value != null)
      {
        // 1) Get museums from firebase and add them to the list
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic,dynamic>;

        // 2) Create a sorted list of museums and fill it with the museums from firebase
        readDataMuseumToSortedList(museumsData, updatedMuseums);

        // 3) Update the museums list in the widget tree, and autmaticaly update the dropdown list of museums with the precedent museum if it exists
        // Vérifier le widget tree est toujours monté avant de mettre à jour l'état
        setStateAndDropDownList(updatedMuseums);

      }
    });

  }

  void readDataMuseumToSortedList(Map<dynamic, dynamic> museumsData, List<Museum> updatedMuseums) {
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


    });

    museumsList.sort((a, b) => a.name.compareTo(b.name));

  }

  void setStateAndDropDownList(List<Museum> updatedMuseums) {
     if (mounted)
    {
      setState(()
      {
        // 1) Affection de la liste des musées à la liste des musées de la page en local
        museumsList = updatedMuseums;

        // 2) Si le musée source est non-null, mettre le musée source dans la dropdown list comme musée sélectionné
        if(widget.sourceMuseum != null)
        {
          print('Museum source is not null');
          // Verifier si un des musées de la liste est le musée source
          // Si oui, mettre ce musée de la liste comme musée sélectionné
          // Sinon, mettre le premier musée de la liste comme musée sélectionné
          bool museumFound = false;

          for (var museum in museumsList)
          {
            if (museum.id == widget.sourceMuseum?.id)
            {
              print('Museum source found in list');
              _selectedMuseum = museum;
              museumFound = true;
              break;
            }
          }

          if (!museumFound) {
            print('Museum source not found in list');
            _selectedMuseum = museumsList[0]; // first museum from list by default
          }

        print('Museums list updated and selected museum is: ${_selectedMuseum.name}');

      }
      else
      {
          print('Museum source is null');
          _selectedMuseum = museumsList[0]; // first museum from list by default
      }

      // 3) Charger la liste des objets du musée sélectionné
      _loadAllObjectsFromAMuseum(_selectedMuseum);

      });
    }
  }


  void updatePoint(){
    setState(() {
      displayAddressPoint = selectedAddressPoint; // Change this to your updated value
    });
  }

  Future<void> _saveChanges() async {
    // Validation
    if (_formKey.currentState!.validate()) {

      // Créez un objet Museum à partir des données du formulaire
      Map<String, dynamic> objectData =
      {
        'name': _nameController.text,
        'museumName': _museumNameController.text,
        'description': _descriptionController.text,
        'point': {
          'latitude': selectedAddressPoint.latitude.toDouble(),
          'longitude': selectedAddressPoint.longitude.toDouble(),
        },

      };

      // Générez une nouvelle clé unique pour le musée
      await _objectsRef.push().set(objectData);

      print('Object added successfully: ${objectData['name']}');


      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }

  }

  Future<List<MuseumObject>> _loadAllObjectsFromAMuseum(Museum museum) async
  {
    final DatabaseReference objectsRef = widget.database.ref().child('museumObjects');
    final List<MuseumObject> fetchedObjects = [];

    // Utilisez une requête pour obtenir les objets du musée ayant le même nom que museum.name
    final Query query = objectsRef.orderByChild('museumName').equalTo(museum.name);
    final DataSnapshot snapshot = await query.get();

    print('SNAPOSHOT : $snapshot AND ${snapshot.value}');

    // Parcourez les résultats et supprimez les objets correspondants
    if (snapshot.exists) {
      final Map<dynamic, dynamic> objectsData = snapshot.value as Map<dynamic, dynamic>;

      objectsData.forEach((key, value)
      {
        final MuseumObject object = MuseumObject(
          // Remplacez ces champs par les champs réels de votre objet
          id: key,
          museumName: value['museumName'] as String,
          name: value['name'] as String,
          description: value['description'] as String,
          point: LatLng(
            // Vériier que les valeurs sont bien des doubles, firebase peut les convertir en int parfois
            (value['point']['latitude'] as num).toDouble(),
            (value['point']['longitude'] as num).toDouble(),
          ),
        );

        fetchedObjects.add(object);
      });
    }

    if (mounted)
    {
      setState(() {
        museumObjectsFromSelectedMuseum = fetchedObjects;
      });
    }

    return fetchedObjects;
  }

  // V A L I D A T I O N S
  // Validation : Vérifier que le nom de l'objet n'existe pas déjà pour ce musée
  String? _validateObjectName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Veuillez entrer un nom';
    }

    // Vérifier si le musée sélectionné (dans _selectedMuseum) existe
    if (_selectedMuseum != null) {

      _loadAllObjectsFromAMuseum(_selectedMuseum) ;
      print('Museum Objects from selected museum : ${museumObjectsFromSelectedMuseum.toString()} ');

      // Parcourir la liste des objets du musée sélectionné
      for (var object in museumObjectsFromSelectedMuseum) {
        if (object.name.toLowerCase() == name.toLowerCase()) {
          print('Object name already exists in this museum');
          return 'Ce nom d\'objet existe déjà dans ce musée';
        }
      }
    }

    return null;
  }

  // Verification que la description n'est pas vide
  String? _validateDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Veuillez entrer une description';
    }

    return null;
  }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {

    // Triez la liste des musées par ordre alphabétique en utilisant le nom du musée
    // museumsList.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un objet')),
      body: Form(
        key: _formKey,  // Permet de valider le formulaire et de sauvegarder les données dans les champs du formulaire
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text('Nom de l\'objet'),
                TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Epée de Charlemagne',
                    ),
                    validator: _validateObjectName),
                const SizedBox(height: 16),

                const Text('Description'),
                TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Cette épée a été utilisée par Charlemagne lors de la bataille de Poitiers',
                    ),
                    validator: _validateDescription),
                const SizedBox(height: 16),


                // DropdownButtonFormField pour sélectionner un musée
                DropdownButtonFormField<Museum>(
                  value: _selectedMuseum ?? null,
                  onChanged: (Museum? newValue)
                  {
                    setState(() {
                      _selectedMuseum = newValue!;
                      _museumNameController.text = newValue?.name ?? 'No museum selected';
                      _loadAllObjectsFromAMuseum(newValue); // Chaque fois que on change de musée, on recharge la liste des objets du musée
                    });
                  },
                  items: museumsList.map((Museum museum)
                  {
                    return DropdownMenuItem<Museum>(
                      value: museum,
                      child: Text(museum.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner un musée auquel attribuer l\'objet',
                  ),
                ),
                const SizedBox(height: 16),


                ElevatedButton(
                    child: const Text('Selectionner l\'adresse'),
                    onPressed: () async {
                      selectedAddressPoint = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 2)),
                      );
                      updatePoint();
                    },

                ),
                Text('Point selectionné: ${displayAddressPoint.latitude.toStringAsFixed(2)}, ${displayAddressPoint.longitude.toStringAsFixed(2)}'),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Enregistrer'),
                ),
              ],
            )
        ),


      ),


    );
  }


}
