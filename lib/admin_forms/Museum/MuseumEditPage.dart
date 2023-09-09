import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../dataModels/Museum.dart';
import '../map_point_picker.dart';

// Immutable state of the MuseumEditPage widget.
class MuseumEditPage extends StatefulWidget {
  final Museum museum;
  final FirebaseDatabase database;


  const MuseumEditPage({Key? key, required this.museum, required this.database}) : super(key: key);

  @override
  _MuseumEditPageState createState() => _MuseumEditPageState();
}


// Mutable state of the MuseumEditPage widget.
class _MuseumEditPageState extends State<MuseumEditPage> {
  // A T T R I B U T E S
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _websiteController;
  late DatabaseReference _museumsRef;
  late LatLng selectedAddressPoint = widget.museum.address;
  late LatLng displayAddressPoint = widget.museum.address;

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Called when the widget is first inserted in the widget tree
  @override
  void initState() {
    super.initState();
    _nameController       = TextEditingController(text: widget.museum.name);
    _latitudeController   = TextEditingController(text: widget.museum.address.latitude.toString());
    _longitudeController  = TextEditingController(text: widget.museum.address.longitude.toString());
    _websiteController    = TextEditingController(text: widget.museum.website);

    // F I R E B A S E
    _museumsRef = widget.database.ref().child('museums');
  }

  /// Called when the widget is removed from the widget tree permanently (e.g. when the user navigates back)
  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void updatePoint(){
    if(mounted){
      setState(() {
        displayAddressPoint = selectedAddressPoint; // Change this to your updated value
      });
    }
  }

  Future<void> _saveChanges() async{
    // Validation
    if (_formKey.currentState!.validate()) {

      // MAJ LOCAL - Mettre à jour les propriétés du musée avec les nouvelles valeurs en local
      widget.museum.name    = _nameController.text;
      widget.museum.website = _websiteController.text;
      widget.museum.address = LatLng(selectedAddressPoint.latitude.toDouble(), selectedAddressPoint.longitude.toDouble());


      // MAJ FIREBASE
      await _museumsRef.child(widget.museum.id).update({
        'name': widget.museum.name,
        'website': widget.museum.website,
        'address': {
          'latitude': widget.museum.address.latitude.toDouble(),
          'longitude': widget.museum.address.longitude.toDouble(),
        },
      });

      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }

  }

  // V A L I D A T I O N S
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom du musée ne peut pas être vide';
    }
    return null;
  }

  // TODO CLEAN ?
  String? _validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'La latitude ne peut pas être vide';
    }
    final double latitude = double.tryParse(value) ?? double.nan;
    if (latitude < -90 || latitude > 90) {
      return 'La latitude doit être comprise entre -90 et 90';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'La longitude ne peut pas être vide';
    }
    final double longitude = double.tryParse(value) ?? double.nan;
    if (longitude < -180 || longitude > 180) {
      return 'La longitude doit être comprise entre -180 et 180';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer ${widget.museum.name}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nom du musée'),
                TextFormField(controller: _nameController, validator: _validateName),
                SizedBox(height: 16),
                Text('Site web'),
                TextFormField(controller: _websiteController),
                SizedBox(height: 16),


                ElevatedButton(
                    onPressed: () async {
                      selectedAddressPoint = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 2)),
                      );
                      updatePoint();
                      print(selectedAddressPoint);
                    },
                    child: const Text('Modifier l\'adresse')
                ),
                selectedAddressPoint == const LatLng(0.0, 0.0) ?
                Text('Point selectionné: ${widget.museum.address.latitude.toStringAsFixed(2)}, ${widget.museum.address.longitude.toStringAsFixed(2)}') :
                Text('Point selectionné: ${displayAddressPoint.latitude.toStringAsFixed(2)}, ${displayAddressPoint.longitude.toStringAsFixed(2)}'),

                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }




}
