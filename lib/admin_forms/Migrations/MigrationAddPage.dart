import 'package:expo_nomade/admin_forms/Migrations/zones/ZoneAddPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../dataModels/Migration.dart';

class MigrationAddPage extends StatefulWidget {
  final FirebaseDatabase database;

  const MigrationAddPage({super.key, required this.database});

  @override
  _MigrationAddPageState createState() => _MigrationAddPageState();
}

class _MigrationAddPageState extends State<MigrationAddPage> {
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController descriptionTextController = TextEditingController();
  final TextEditingController arrivalTextController = TextEditingController();
  final TextEditingController tagTextController = TextEditingController();
  late MigrationSource migrationSource;
  late List<MigrationSource> migrationSources = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un flux migratoire')),
      body: ListView( // Use ListView to make content scrollable
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Nom:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: nameTextController),
          const SizedBox(height: 16),
          const Text(
            'Description:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: descriptionTextController),
          const SizedBox(height: 16),
          const Text(
            'Arrivée:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: arrivalTextController),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                migrationSource = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ZoneAddPage()),
                );
                print(migrationSource.toString());
                migrationSources.add(migrationSource);
              },
              child: const Text('Ajouter une zone') ,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _addMigrationToDatabase();
              },
              child: Text('Ajouter la migration'),
            ),
          ),
        ],
      ),
    );
  }

  void _addMigrationToDatabase() async {
    try {
      DatabaseReference migrationRef = widget.database.ref().child('migrations');
      DatabaseReference newMigrationRef = migrationRef.push();

      Map<String, dynamic> migrationToUpload = {
        'name': nameTextController.text,
        'description': descriptionTextController.text,
        'arrival': arrivalTextController.text,
      };

      if(migrationSources != null){
        migrationToUpload['polygons'] = [];
        for (var source in migrationSources){
          Map<String, dynamic> polygonData = {
            'color': source.color,
            'name': source.name,
            'id': source.id
          };
          if (source.points != null) {
            polygonData['points'] = [];
            for (var point in source.points!) {
              Map<String, double> pointData = {
                'latitude': point.latitude.toDouble(),
                'longitude': point.longitude.toDouble(),
              };
              polygonData['points'].add(pointData);
            }
          }
          migrationToUpload['polygons'].add(polygonData);
        }
      }
      await newMigrationRef.set(migrationToUpload);
      Navigator.pop(context);
    } catch (error) {
      print('Error adding migration: $error');
    }
  }
}
