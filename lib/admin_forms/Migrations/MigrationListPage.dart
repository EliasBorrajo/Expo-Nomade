import 'package:expo_nomade/admin_forms/Migrations/MigrationEditPage.dart';
import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../firebase/firebase_crud.dart';
import 'MigrationAddPage.dart';
import 'MigrationDetailsPage.dart';

class MigrationListPage extends StatefulWidget {
  final FirebaseDatabase database;

  const MigrationListPage({super.key, required this.database});

  @override
  _MigrationListPageState createState() => _MigrationListPageState();
}

class _MigrationListPageState extends State<MigrationListPage>{

  late List<Migration> migrations = [];

  @override
  void initState() {
    super.initState();
    final firebaseUtils = FirebaseUtils(widget.database);
    firebaseUtils.loadMigrationsAndListen((updatedMigrations) {
      if(mounted){
        setState(() {
          migrations = updatedMigrations;
        });
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, Migration migration) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Êtes-vous sûr de vouloir supprimer cette migration ? Cette action est irreversible'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  widget.database.ref().child('migrations').child(migration.id).remove();
                  setState(() {
                    migrations?.remove(migration);
                  });
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: const Text('Supprimer'),
              ),
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des flux',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liste des migrations'),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MigrationAddPage(database: widget.database),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: migrations.length,
          itemBuilder: (context, index) {
            final migration = migrations[index];
            return Column(
              children: [
                ListTile(
                  title: Text(migration.name),
                  subtitle: Text('Zones : ${migration.polygons?.length.toString() ?? '0'}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MigrationDetailsPage(migration: migration)),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => MigrationEditpage(migration: migration, database: widget.database)),
                          );                          },
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, migration!);
                        },
                        icon: const Icon(Icons.delete_rounded),
                      ),
                    ],
                  ),

                ),
                const Divider(height: 2),
              ],
            );
          },
        ),
      ),
    );
  }
}