import 'package:flutter/material.dart';
import '../../dataModels/MuseumObject.dart';

// Immutable state of the ObjectEditPage widget.
class ObjectEditPage extends StatefulWidget {
  final MuseumObject object;

  const ObjectEditPage({Key? key, required this.object}) : super(key: key);

  @override
  _ObjectEditPageState createState() => _ObjectEditPageState();
}

// Mutable state of the MuseumEditPage widget.
class _ObjectEditPageState extends State<ObjectEditPage> {
  // A T T R I B U T E S
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;


  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Called when the widget is first inserted in the widget tree
  @override
  void initState() {

    // Todo : Fetch data from firebase ?

    super.initState();
    _nameController       = TextEditingController(text: widget.object.name);
    _descriptionController   = TextEditingController(text: widget.object.description);

  }

  /// Called when the widget is removed from the widget tree permanently (e.g. when the user navigates back)
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Mettre à jour les propriétés dE L'objet avec les nouvelles valeurs
      widget.object.name = _nameController.text;
      widget.object.description = _descriptionController.text;

      // TODO: Sauvegarder les modifications (peut-être via une fonction dans votre modèle de données)

      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer ${widget.object.name}'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nom de l''objet'),
              TextFormField(controller: _nameController, validator: _validateName),
              SizedBox(height: 16),
              Text('Description'),
              TextFormField(controller: _descriptionController, validator: _validateDescription),
              SizedBox(height: 16),
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

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'La description ne peut pas être vide';
    }
    return null;
  }

}

