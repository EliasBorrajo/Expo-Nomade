import 'package:expo_nomade/dataModels/MuseumObject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// TODO : Verification que le nom n'est pas vide & qu'il n'existe pas déjà pour ce musée
// TODO : Editer images
// TODO : Editer tags
// TODO : PICKER LOCATION

class ObjectEditPage extends StatefulWidget{
  final MuseumObject object;
  final FirebaseDatabase database;

  const ObjectEditPage( {Key? key, required this.object, required this.database}) : super(key: key);

  @override
  _ObjectEditPageState createState() => _ObjectEditPageState();
}

class _ObjectEditPageState extends State<ObjectEditPage> {
  // A T T R I B U T E S
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DatabaseReference _objectsRef;

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // M E T H O D S
  void initState() {
    super.initState();
    _nameController        = TextEditingController(text: widget.object.name);
    _descriptionController = TextEditingController(text: widget.object.description);

    // F I R E B A S E
    _objectsRef = widget.database.ref().child('museumObjects');
  }


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async{
    // Validation
    if (_formKey.currentState!.validate()) {

      // MAJ LOCAL - Mettre à jour les propriétés du musée avec les nouvelles valeurs en local
      widget.object.name        = _nameController.text;
      widget.object.description = _descriptionController.text;


      // MAJ FIREBASE
      await _objectsRef.child(widget.object.id).update({
        'name': widget.object.name,
        'description': widget.object.description,
      }
      ).whenComplete(() => print('Object updated : ${widget.object.name}'));

      setState(() {
        widget.object.name        = _nameController.text;
        widget.object.description = _descriptionController.text;
      });

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

  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editer l\'objet ${widget.object.name}')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nom du de l\'objet'),
              TextFormField(controller: _nameController, validator: _validateName),
              const SizedBox(height: 16),
              const Text('Description'),
              TextFormField(controller: _descriptionController, validator: _validateDescription),

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
}
