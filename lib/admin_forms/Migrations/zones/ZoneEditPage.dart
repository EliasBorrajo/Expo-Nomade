import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ZoneEditPage extends StatefulWidget{
  final FirebaseDatabase database;
  final Migration migration;
  final int index;

  const ZoneEditPage({super.key, required this.migration, required this.database, required this.index});

  @override
  _ZoneEditPageState createState() => _ZoneEditPageState();
}

class _ZoneEditPageState extends State<ZoneEditPage>{
  late TextEditingController _nameController;
  late DatabaseReference _migrationsRef;

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.migration.polygons?[widget.index].name);
    _migrationsRef = widget.database.ref().child('migrations');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {

    // Local update
    if (_formKey.currentState!.validate()) {
      widget.migration.polygons?[widget.index].name = _nameController.text;
    }
    // Firebase update
    await _migrationsRef.child(widget.migration.id).child('polygons').child(widget.index.toString()).update({
      'name': widget.migration.polygons?[widget.index].name,
    });

    Navigator.pop(context);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom de la zone ne peut pas être vide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer ${widget.migration.polygons?[widget.index].name}'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nom de la zone'),
              TextFormField(controller: _nameController, validator: _validateName),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}