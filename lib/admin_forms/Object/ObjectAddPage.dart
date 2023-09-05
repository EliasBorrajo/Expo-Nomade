import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../dataModels/Museum.dart';
import '../map_point_picker.dart';

// TODO : Verification que le nom n'est pas vide & qu'il n'existe pas déjà pour ce musée
// TODO : Ajouter images
// TODO : Ajouter tags
// TODO : PICKER LOCATION

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

    _loadMuseumsFromFirebaseAndListen()
        // .then((_) => _selectedMuseum = museumsList[0])
        .whenComplete(() => print('Museums loaded'));

    // // Si le musée source est non-null, mettre le musée source de la page précédente,
    // // sinon mettre le premier musée de la liste
    // widget.sourceMuseum != null ? _selectedMuseum = widget.sourceMuseum! : _selectedMuseum = museumsList[0];

    // TODO : Selectionner le musée de la page précedente
    // Todo : Soit récuperer en paramètre du widget, soit regarder depuis la DB

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
              museumsList = updatedMuseums;
              _selectedMuseum = museumsList[0];
              // Si le musée source est non-null, mettre le musée source de la page précédente,
              // sinon mettre le premier musée de la liste
              // widget.sourceMuseum != null ? _selectedMuseum = widget.sourceMuseum! : _selectedMuseum = museumsList[0];
            });
          }
        });
      }
    });

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

  // V A L I D A T I O N S
  // TODO : Verification que le nom n'est pas vide & qu'il n'existe pas déjà pour ce musée
  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Veuillez entrer un nom';
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

  // TODO : Vérification que le museumName existe bien dans la DB


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {
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
                    validator: _validateName),
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
                      _selectedMuseum = newValue!; // TODO : Source de BUG ?
                      _museumNameController.text = newValue?.name ?? 'No museum selected';
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
