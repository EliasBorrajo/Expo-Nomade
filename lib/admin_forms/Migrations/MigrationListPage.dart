import 'package:expo_nomade/admin_forms/dummyData.dart';
import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'MigrationDetailsPage.dart';


// TODO : Ajouter le BTN + pour ajouter un musée
// TODO : Supprimer un musée avec un long press sur le musée

/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.
///
class MigrationListPage extends StatefulWidget {
  //final List<Migration> migrations;
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
    _loadMigrationsFromFirebaseAndListen();
  }

  
  void _loadMigrationsFromFirebaseAndListen() async {
    DatabaseReference migrationsRef = widget.database.ref().child('migrations');
    
    migrationsRef.onValue.listen((DatabaseEvent event) { 
      if(event.snapshot.value != null){
        List<Migration> updatedMigrations = [];
        Map<dynamic, dynamic> migrationsData = event.snapshot.value as Map<dynamic, dynamic>;
        
        migrationsData.forEach((key, value) {
          List<MigrationSource>? polygons = [];

          if(value['polygons'] != null){
            List<dynamic> polygonsData = value['polygons'] as List<dynamic>;

            for (var polyValue in polygonsData) {
              List<dynamic> pointsData = polyValue['points'] as List<dynamic>;
              List<LatLng> points = [];

              for(var point in pointsData){
                points.add(
                  LatLng(
                    point['latitude'] as double,
                    point['longitude'] as double,
                  )
                );
              }

              MigrationSource source = MigrationSource(
                  points: points,
                  //color: polyValue['color']! as Color,
                  name: polyValue['name']! as String ,
              );

              polygons.add(source);

              Migration migration = Migration(
                name: value['name'] as String,
                description: value['description'] as String,
                arrival: value['arrival'] as String,
                polygons: polygons
              );

              updatedMigrations.add(migration);

              setState(() {
                migrations = updatedMigrations;
              });

            }
          }
        });
      }
    });
  }

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
              'color': polygon.color.toString(),
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


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des musées',
      home: Scaffold(
        body: ListView.builder(
          itemCount: migrations.length,
          itemBuilder: (context, index) {
            final migration = migrations[index];
            return ListTile(
              title: Text(migration.name),
              subtitle: Text('Zones : ${migration.polygons?.length.toString() ?? '0'}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MigrationDetailsPage(migration: migration)),
                );
              },
            );
          },
        ),

        // Add a FAB to the bottom right
        // FAB : Floating Action Button
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                // ToDo : Naviguer vers la page d'ajout de musée
              },
              label: Text('Add migration'),
              icon: Icon(Icons.add),
              heroTag: 'add_migration',
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              onPressed: _seedDatabase,
              label: Text('Seed Database'),
              icon: Icon(Icons.cloud_upload),
              heroTag: 'seed_database',
            ),
          ],
        ),
      ),
    );
  }
}
