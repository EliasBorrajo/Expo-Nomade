import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../dataModels/Museum.dart';

class MuseumAddPage extends StatefulWidget {

  final FirebaseDatabase database;

  const MuseumAddPage({Key? key, required this.database}) : super(key: key);

  @override
  _MuseumAddPageState createState() => _MuseumAddPageState();

}

class _MuseumAddPageState extends State<MuseumAddPage> {
  // A T T R I B U T E S
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _websiteController;
  late DatabaseReference _museumsRef;

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController       = TextEditingController(text: "");
    _latitudeController   = TextEditingController(text: "");
    _longitudeController  = TextEditingController(text: "");
    _websiteController    = TextEditingController(text: "");

    // F I R E B A S E
    _museumsRef = widget.database.ref().child('museums');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Validation
    if (_formKey.currentState!.validate()) {

      // Créez un objet Museum à partir des données du formulaire
      Map<String, dynamic> museumData =
      {
        'name': _nameController.text,
        'website': _websiteController.text,
        'address': {  // TODO : Remplacer par les coordonnées GPS du PICKER
          'latitude': 88.5.toDouble(),
          'longitude': 160.6.toDouble(),
        },

      };

      // Générez une nouvelle clé unique pour le musée
      await _museumsRef.push().set(museumData);

      print('Museum added successfully: ${museumData['name']}');


      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter un musée'),
        ),
        body: Form(
          key: _formKey,  // Permet de valider le formulaire et de sauvegarder les données dans les champs du formulaire
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nom du musée'),
                TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Musée du louvre',
                    ),
                    validator: _validateName),
                SizedBox(height: 16),
                Text('Site web'),
                TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      hintText: 'https://www.musee.com',
                    ),
                    validator: _validateWebSite),
                SizedBox(height: 16),
                // TODO : Ajouter un LOCATION PICKER
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('Enregistrer'),
                ),
              ],
            )
          ),


        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom du musée ne peut pas être vide';
    }
    return null;
  }

  String? _validateWebSite(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le site web ne peut pas être vide';
    }
    return null;
  }
}

