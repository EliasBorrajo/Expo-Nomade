import 'package:flutter/material.dart';
import '../../dataModels/Museum.dart';
import '../../dataModels/MuseumObject.dart';
import 'MuseumEditPage.dart';
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
      appBar: AppBar(
        title: Text(museum.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MuseumEditPage(museum: museum)),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adresse: latitude ${museum.address.latitude} & longitude ${museum.address.longitude} ' ),
          Text('Site web: ${museum.website}'),
          Text('Objets:'),

          // Display the list of objects
          museum.objects != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: museum.objects?.length ?? 0,   // Coalecing operator : si museum.objects est null, alors on retourne 0, sinon on retourne la longueur de la liste
                  itemBuilder: (context, index) {
                    final object = museum.objects?[index];
                    return ListTile(
                      title: Text(object?.name ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ObjectDetailPage(object: object!)), // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                        );
                      },
                      onLongPress: () {
                        _showDeleteConfirmationDialog(context, object!);    // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                      },
                    );
                  },
                )
              : const Text('Aucun objet disponible'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Naviguer vers la page d'ajout d'objet
      },
      child: Icon(Icons.add),
    ),
    );
  }


// M E T H O D E S
  void _showDeleteConfirmationDialog(BuildContext context, MuseumObject object) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Êtes-vous sûr de vouloir supprimer cet objet ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Supprimer l'objet et mettre à jour la liste d'objets
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        }
    );
  }

}
