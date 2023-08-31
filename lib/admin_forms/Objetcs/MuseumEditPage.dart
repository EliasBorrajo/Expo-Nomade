import 'package:flutter/material.dart';
import '../../dataModels/Coordinate.dart';
import '../../dataModels/Museum.dart';

// Immutable state of the MuseumEditPage widget.
class MuseumEditPage extends StatefulWidget {
  final Museum museum;

  const MuseumEditPage({Key? key, required this.museum}) : super(key: key);

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

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Called when the widget is first inserted in the widget tree
  @override
  void initState() {

    // Todo : Fetch data from firebase ?

    super.initState();
    _nameController       = TextEditingController(text: widget.museum.name);
    _latitudeController   = TextEditingController(text: widget.museum.address.latitude.toString());
    _longitudeController  = TextEditingController(text: widget.museum.address.longitude.toString());
    _websiteController    = TextEditingController(text: widget.museum.website);
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Mettre à jour les propriétés du musée avec les nouvelles valeurs
      widget.museum.name = _nameController.text;
      widget.museum.website = _websiteController.text;
      widget.museum.address = Coordinate(
        latitude:  _latitudeController.text,
        longitude: _longitudeController.text,
      );

      // TODO: Sauvegarder les modifications (peut-être via une fonction dans votre modèle de données)

      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer ${widget.museum.name}'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nom du musée'),
              TextFormField(controller: _nameController, validator: _validateName),
              SizedBox(height: 16),
              Text('Latitude'),
              TextFormField(controller: _latitudeController, validator: _validateLatitude),
              SizedBox(height: 16),
              Text('Longitude'),
              TextFormField(controller: _longitudeController, validator: _validateLongitude),
              SizedBox(height: 16),
              Text('Site web'),
              TextFormField(controller: _websiteController),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void setState(VoidCallback fn) {
    // Useless, because the variables are not displayed in the UI (no rebuild needed)
    throw UnimplementedError();

    // implement setState
    super.setState(fn);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom du musée ne peut pas être vide';
    }
    return null;
  }

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

}
