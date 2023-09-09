import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../map_point_picker.dart';

class ZoneAddPage extends StatefulWidget {

  const ZoneAddPage({super.key});

  @override
  _ZoneAddPageState createState() => _ZoneAddPageState();
}

class _ZoneAddPageState extends State<ZoneAddPage>{
  final TextEditingController zoneNameTextController = TextEditingController();
  late List<LatLng> polygon = [];
  late int nbPolyPoints = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    zoneNameTextController.dispose();
    super.dispose();
  }


  void updatePolyPoints(){
    if(mounted){
      setState(() {
        nbPolyPoints = polygon.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une zone au flux')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Nom de la zone:'),
            TextFormField(controller: zoneNameTextController, validator: validateName,),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  polygon = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 1)),
                  );

                  updatePolyPoints();
                },
                child: const Text('Choisir les points de la zone'),
              ),
            ),
            nbPolyPoints < 1 ? const Text('Aucune zone selectionnée.') : Text('Zone avec $nbPolyPoints points selectionnée.'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if(_formKey.currentState!.validate()){
                    if(polygon.isEmpty){
                      const snackBar = SnackBar(
                        content: Text('Veuillez choisir les points de la zone.'),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }else{
                      MigrationSource source = MigrationSource(
                        points: polygon,
                        name:  zoneNameTextController.text,
                      );
                      Navigator.pop(context, source);
                    }
                  }
                },
                child: const Text('Ajouter la zone'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String? validateName(String? value){
    if (value == null || value.isEmpty) {
      return 'Le nom de la zone ne peut pas être vide';
    }
    return null;
  }
}