import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:flutter/material.dart';

class ZoneDetailsPage extends StatelessWidget{

  final MigrationSource migrationSource;

  const ZoneDetailsPage({super.key, required this.migrationSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la zone de migration: ${migrationSource.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nom',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                migrationSource.name!,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nombre de points',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                migrationSource.points!.length.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
            ],
          )
        ],
      ),
    );
  }


}