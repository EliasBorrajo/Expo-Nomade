import 'package:flutter/material.dart';
import '../../dataModels/Museum.dart';
import 'ObjectDetailPage.dart';

// TODO : Ajouter le BTN + pour ajouter un objet
// TODO : Editer les informations du musée
// TODO : Supprimer un objet avec un long press sur l'objet
// TODO : ajout de la fonctionnalité de recherche d'objet par nom


/// Displays the details of a museum.
/// At the top of the page, the infos of the museum are displayed.
/// Then, the list of objects is displayed.
/// When an object is tapped, the [ObjectDetailPage] is displayed.
///
class MuseumDetailPage extends StatelessWidget {
  final Museum museum;

  const MuseumDetailPage({super.key, required this.museum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(museum.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adresse: ${museum.address}'),
          Text('Site web: ${museum.website}'),
          Text('Objets:'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: museum.objects.length,
            itemBuilder: (context, index) {
              final object = museum.objects[index];
              return ListTile(
                title: Text(object.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ObjectDetailPage(object: object)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
