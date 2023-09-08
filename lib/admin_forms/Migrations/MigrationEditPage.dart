import 'package:expo_nomade/admin_forms/Migrations/zones/ZoneAddPage.dart';
import 'package:expo_nomade/admin_forms/Migrations/zones/ZoneEditPage.dart';
import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MigrationEditpage extends StatefulWidget {
  final Migration migration;
  final FirebaseDatabase database;

  const MigrationEditpage({super.key, required this.migration, required this.database});

  @override
  _MigrationEditpageState createState() => _MigrationEditpageState();


}

class _MigrationEditpageState extends State<MigrationEditpage>{
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _arrivalController;
  late DatabaseReference _migrationsRef;

  late MigrationSource addedSource;

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.migration.name);
    _descriptionController = TextEditingController(text: widget.migration.description);
    _arrivalController = TextEditingController(text: widget.migration.arrival);
    _migrationsRef = widget.database.ref().child('migrations');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  void updateDisplayedSources(){
    if(mounted){
      setState(() {
        widget.migration.polygons = widget.migration.polygons;
      });
    }
  }

  Future<void> _saveChanges() async {
    // Local update
    if (_formKey.currentState!.validate()) {
      widget.migration.name = _nameController.text;
      widget.migration.description = _descriptionController.text;
      widget.migration.arrival = _arrivalController.text;
    }

    try{
      Map<String, dynamic> migrationToUpdate = {
        'name': widget.migration.name,
        'description': widget.migration.description,
        'arrival': widget.migration.arrival,
      };
      if(addedSource != null){
        migrationToUpdate['polygons'] = [];
        for (var polygon in widget.migration.polygons!){
          Map<String, dynamic> polygonData = {
            'name': polygon.name,
          };
          if (polygon.points != null) {
            polygonData['points'] = [];
            for (var point in polygon.points!) {
              Map<String, double> pointData = {
                'latitude': point.latitude.toDouble(),
                'longitude': point.longitude.toDouble(),
              };
              polygonData['points'].add(pointData);
            }
          }
          migrationToUpdate['polygons'].add(polygonData);
        }
      }
      await _migrationsRef.child(widget.migration.id).update(migrationToUpdate);

    }catch (error) {
      print('Error editing migration: $error');
    }

    Navigator.pop(context);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom de la migration ne peut pas être vide';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'La description de la migration ne peut pas être vide';
    }
    return null;
  }

  String? _validateArrival(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\' arrivée de la migration ne peut pas être vide';
    }
    return null;
  }

  void _showDeleteConfirmationDialog(BuildContext context, int migrationIndex) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Êtes-vous sûr de vouloir supprimer cet objet ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  _migrationsRef.child(widget.migration.id).child('polygons').child(migrationIndex.toString()).remove();
                  widget.migration.polygons?.remove(widget.migration.polygons?[migrationIndex]);
                  updateDisplayedSources();
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer ${widget.migration.name}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView( // Wrap the entire content in a SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nom de la migration'),
                TextFormField(controller: _nameController, validator: _validateName),
                const SizedBox(height: 16),
                const Text('Description'),
                TextFormField(controller: _descriptionController, validator: _validateDescription),
                const SizedBox(height: 16),
                const Text('Arrivée'),
                TextFormField(controller: _arrivalController, validator: _validateArrival),
                const SizedBox(height: 16),
                const Text('Zones'),
                // Display the list of zones
                widget.migration.polygons != null
                    ?
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.migration.polygons?.length ?? 0,   // Coalecing operator : si museum.objects est null, alors on retourne 0, sinon on retourne la longueur de la liste
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the ListView
                  itemBuilder: (context, index) {
                    final flowMigration = widget.migration.polygons?[index];
                    return ListTile(
                      title: Text(flowMigration?.name ?? ''),
                      subtitle: Text('Points: ${flowMigration?.points?.length}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            // NAV MUSEUM EDIT PAGE
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => ZoneEditPage(migration: widget.migration, index: index, database: widget.database)),
                              );
                            },
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            // DELETE MUSEUM
                            onPressed: () {
                              if(widget.migration.polygons?.length == 1){
                                const snackBar = SnackBar(
                                  content: Text('Impossible de supprimer la zone.'),
                                  backgroundColor: Colors.red,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }else{
                                _showDeleteConfirmationDialog(context, index);    // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                              }
                            },
                            icon: const Icon(Icons.delete_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : const Text('Aucune zone'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              addedSource = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ZoneAddPage()),
              );
              widget.migration.polygons?.add(addedSource);
              updateDisplayedSources();
            },
            label: const Text('Ajouter une zone'),
            icon: const Icon(Icons.add_rounded),
            heroTag: 'add_migration',
          ),
        ],
      ),
    );
  }
}