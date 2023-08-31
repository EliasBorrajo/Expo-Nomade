import 'package:flutter/material.dart';
import '../../dataModels/MuseumObject.dart';
import 'ObjectEditPage.dart';

// TODO : Edit les informations de l'objet
// TODO : Ajouter des Tags à l'objet

/// Displays the details of an object.
///
class ObjectDetailPage extends StatelessWidget {
  final MuseumObject object;

  const ObjectDetailPage({super.key, required this.object});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
        (title: Text(object.name),
          actions: [
          IconButton(
          icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ObjectEditPage(object: object)),
        );
      },
    ),
    ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description: ${object.description}'),
          Text('Images: ${object.images ?? 'Aucune image'}'),
          // Ajoutez ici l'affichage des détails de découvertes et sources si nécessaire
        ],
      ),
    );
  }
}
