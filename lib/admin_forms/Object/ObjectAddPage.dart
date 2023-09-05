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

  const ObjectAddPage({Key? key, required this.database}) : super(key: key);

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

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // M E T H O D S
  @override
  void initState() {
    super.initState();
    _nameController        = TextEditingController(text: "");
    _museumNameController  = TextEditingController(text: "");
    _descriptionController = TextEditingController(text: "");

    // F I R E B A S E
    _objectsRef = widget.database.ref().child('museumObjects');

    loadMuseumList();

  }

  @override
  void dispose() {
    _nameController.dispose();
    _museumNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void loadMuseumList() async{
    // Get the list of museums
    DataSnapshot dataSnapshot = (await widget.database.ref().child('museums').once()) as DataSnapshot;
    Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic, dynamic>;
    values.forEach((key, values) {
      Museum museum = Museum.fromSnapshot(values);
      museumsList.add(museum);
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
