import 'package:expo_nomade/admin_forms/Migrations/MigrationEditPage.dart';
import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../map_point_picker.dart';

class MigrationDetailsPage extends StatelessWidget {
  final Migration migration;

  const MigrationDetailsPage({super.key, required this.migration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(migration.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MigrationEditpage(migration: migration)),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Desciption: ${migration.description}' ),

          // Display the list of zones
          migration.polygons != null
              ? ListView.builder(
            shrinkWrap: true,
            itemCount: migration.polygons?.length ?? 0,   // Coalecing operator : si museum.objects est null, alors on retourne 0, sinon on retourne la longueur de la liste
            itemBuilder: (context, index) {
              final flowMigration = migration.polygons?[index];
              return ListTile(
                title: Text(flowMigration?.name ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 1,)), // Here redirect to the map
                  );
                },
                onLongPress: () {
                  _showDeleteConfirmationDialog(context, flowMigration!);    // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                },
              );
            },
          )
              : const Text('Aucun objet disponible'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers la page d'ajout d'objet
        },
        child: Icon(Icons.add),
      ),
    );
  }


// M E T H O D E S
  void _showDeleteConfirmationDialog(BuildContext context, MigrationSource migrationSource) {
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
                  // TODO: Supprimer l'objet et mettre à jour la liste d'objets
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        }
    );
  }
}