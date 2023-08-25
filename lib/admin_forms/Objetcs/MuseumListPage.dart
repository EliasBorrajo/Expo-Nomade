import 'package:flutter/material.dart';

import '../../dataModels/Museum.dart';
import 'MuseumDetailPage.dart';

// TODO : Ajouter le BTN + pour ajouter un musée
// TODO : Supprimer un musée avec un long press sur le musée

/// Displays a list of museums.
/// When a museum is tapped, the [MuseumDetailPage] is displayed.
///
class MuseumListPage extends StatelessWidget {
  final List<Museum> museums;

  const MuseumListPage({required this.museums}); // Constructeur

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des musées',
      home: Scaffold(
        appBar: AppBar(title: Text('Liste des musées')),
        body: ListView.builder(
          itemCount: museums.length,
          itemBuilder: (context, index) {
            final museum = museums[index];
            return ListTile(
              title: Text(museum.name),
              subtitle: Text(museum.address),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MuseumDetailPage(museum: museum)),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Naviguer vers la page d'ajout de musée
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
