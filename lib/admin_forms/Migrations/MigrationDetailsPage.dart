import 'package:expo_nomade/admin_forms/Migrations/zones/ZoneDetailsPage.dart';
import 'package:expo_nomade/dataModels/Migration.dart';
import 'package:expo_nomade/firebase/Storage/ImagesMedia.dart';
import 'package:flutter/material.dart';

class MigrationDetailsPage extends StatelessWidget {
  final Migration migration;

  const MigrationDetailsPage({super.key, required this.migration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Détails de la migration: ${migration.name}'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nom',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  migration.name,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  migration.description,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Arrivée',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  migration.arrival,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sources de la migration:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (migration.polygons != null)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: migration.polygons!.length,
                    itemBuilder: (context, index) {
                      final source = migration.polygons![index];
                      return ListTile(
                          title: Text(
                            '${source.name}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            'Nombre de zones: ${source.points?.length}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ZoneDetailsPage(
                                    migrationSource: source,
                                  ),
                                ));
                          });
                    },
                  ),
                const SizedBox(height: 16),


                ImageGallery(
                    imageUrls: migration.images ?? [],
                    isEditMode: false),
              ],
            ),
          ],
        ));
  }
}
