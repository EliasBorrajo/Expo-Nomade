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
  late List<MigrationSource> displayedMigrationSources = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    nameTextController.dispose();
    descriptionTextController.dispose();
    arrivalTextController.dispose();
    super.dispose();
  }

  void updateZones(){
    if(mounted){
      setState(() {
        displayedMigrationSources = migrationSources;
        //nbMigrationSources = migrationSources.length;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un flux migratoire')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Nom:'),
            TextFormField(controller: nameTextController, validator: validateName,),
            const SizedBox(height: 16),
            const Text('Description:'),
            TextFormField(controller: descriptionTextController, validator: validateDescription,),
            const SizedBox(height: 16),
            const Text('Arrivée:'),
            TextFormField(controller: arrivalTextController, validator: validateArrival,),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  migrationSource = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ZoneAddPage()),
                  );
                  print(migrationSource.toString());
                  updateZones();
                  migrationSources.add(migrationSource);
                },
                child: const Text('Ajouter une zone') ,
              ),
            ),
            const SizedBox(height: 16),
            displayedMigrationSources.length <= 1 ?  Text('${displayedMigrationSources.length} zone ajoutée.') : Text('${displayedMigrationSources.length} zones ajoutées.'),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if(displayedMigrationSources.isEmpty){
                    const snackBar = SnackBar(
                      content: Text('Veuillez ajouter au moins une zone.'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }else{
                    _addMigrationToDatabase();
                  }
                },
                child: const Text('Ajouter la migration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateName(String? value){
    if (value == null || value.isEmpty) {
      return 'Le nom de la migration ne peut pas être vide';
    }
    return null;
  }

  String? validateDescription(String? value){
    if (value == null || value.isEmpty) {
      return 'La description de la migration ne peut pas être vide';
    }
    return null;
  }

  String? validateArrival(String? value){
    if (value == null || value.isEmpty) {
      return 'L\' arrivée de la migration ne peut pas être vide';
    }
    return null;
  }

  void _addMigrationToDatabase() async {

    if(_formKey.currentState!.validate()){
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
              //'color': source.color.toString(),
              'name': source.name,
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
}
