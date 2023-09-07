import 'dart:async';

import 'package:expo_nomade/admin_forms/Migrations/MigrationEditPage.dart';
import 'package:expo_nomade/admin_forms/dummyData.dart';
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


  //TODO: Delete this method.
  void _seedDatabase() async {
    // Get a reference to your Firebase database
    DatabaseReference databaseReference = widget.database.ref();

    try{
      for (var migration in dummyMigrations) {
        Map<String, dynamic> migrationData = {
          'name': migration.name,
          'description': migration.description,
          'arrival': migration.arrival,
        };
        if (migration.polygons != null) {
          migrationData['polygons'] = [];
          for (var polygon in migration.polygons!) {
            Map<String, dynamic> polygonData = {
              //'color': polygon.color.toString(),
              'name': polygon.name,
              //'id': polygon.id,
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
            migrationData['polygons'].add(polygonData);
          }
        }
        await databaseReference.child('migrations').push().set(migrationData);
        print('Museum seeded successfully: ${migration.name}');
      }
      print('Database seeding completed.');
    }
    catch (error) {
      print('Error seeding database: $error');
    }
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MigrationAddPage(database: widget.database),
                  ),
                );
              },
              label: Text('Add migration'),
              icon: Icon(Icons.add_rounded),
              heroTag: 'add_migration',
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              onPressed: _seedDatabase,
              label: Text('Seed Database'),
              icon: Icon(Icons.cloud_upload_rounded),
              heroTag: 'seed_database_migration',
            ),
          ],
        ),
      ),
    );
  }
}