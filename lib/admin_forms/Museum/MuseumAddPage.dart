import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../map_point_picker.dart';

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
  late LatLng selectedAddressPoint = const LatLng(0.0, 0.0);
  late LatLng displayAddressPoint = const LatLng(0.0, 0.0);
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
        'address': {
          'latitude': selectedAddressPoint.latitude.toDouble(),
          'longitude': selectedAddressPoint.longitude.toDouble(),
        },

      };

      // Générez une nouvelle clé unique pour le musée
      await _museumsRef.push().set(museumData);

      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }

  }

  void updatePoint(){
    setState(() {
      displayAddressPoint = selectedAddressPoint; // Change this to your updated value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un musée'),
      ),
      body: Form(
        key: _formKey,  // Permet de valider le formulaire et de sauvegarder les données dans les champs du formulaire
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nom du musée'),
                TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Musée du louvre',
                    ),
                    validator: _validateName),
                const SizedBox(height: 16),
                const Text('Site web'),
                TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      hintText: 'https://www.musee.com',
                    ),
                    validator: _validateWebSite),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () async {
                      selectedAddressPoint = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 2)),
                      );
                      updatePoint();
                    },
                    child: const Text('Selectionner l\'adresse')
                ),
                Text('Point selectionné: ${displayAddressPoint.latitude.toStringAsFixed(2)}, ${displayAddressPoint.longitude.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Enregistrer'),
                ),
              ],
            )
          ],
        )
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

