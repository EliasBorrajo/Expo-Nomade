import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/cupertino.dart';
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
  final TextEditingController zoneColorTextController = TextEditingController();
  late List<LatLng> polygon = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une zone au flux')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Nom de la zone:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: zoneNameTextController),
          const SizedBox(height: 16),
          const Text(
            'Couleur de la zone:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(controller: zoneColorTextController),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                polygon = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 1)),
                );
                print(polygon);
              },
              child: const Text('Choisir les points de la zone'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              /*onPressed: () async {
                polygon = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 1)),
                );
                print(polygon);
              },*/
              onPressed: () {
                MigrationSource source = MigrationSource(
                  points: polygon,
                  //color: zoneColorTextController.,
                  name:  zoneNameTextController.text,
                );
                Navigator.pop(context, source);
              },
              child: const Text('Ajouter la zone'),
            ),
          ),
          const SizedBox(height: 16),

        ],
      ),
    );
  }
}