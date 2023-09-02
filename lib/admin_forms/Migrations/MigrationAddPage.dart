import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../map_point_picker.dart';

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
  final TextEditingController migrationSourceColorTextController = TextEditingController();
  final TextEditingController migrationSourceNameTextController = TextEditingController();
  late List<LatLng> polygonPoints = [];
  late List<List<LatLng>> validatedPolygons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un flux migratoire')),
      body: ListView( // Use ListView to make content scrollable
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Name:',
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
                validatedPolygons = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 1)),
                );
                print(validatedPolygons);
              },
              child: Text('Choisir les points de la zone'),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Color of the zone:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: migrationSourceColorTextController),
          const SizedBox(height: 16),
          const Text(
            'Name of the zone:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: migrationSourceNameTextController),
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
      if (validatedPolygons != null) {
        migrationToUpload['polygons'] = [];
        for (var polygon in validatedPolygons) {
          Map<String, dynamic> polygonData = {
            'color': migrationSourceColorTextController.text,
            'name': migrationSourceNameTextController.text,
          };
          if (polygon != null) {
            polygonData['points'] = [];
            for (var point in polygon) {
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
