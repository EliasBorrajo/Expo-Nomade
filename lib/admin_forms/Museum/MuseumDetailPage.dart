import 'package:expo_nomade/admin_forms/Museum/Object/ObjectEditPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../dataModels/Museum.dart';
import '../../dataModels/MuseumObject.dart';
import 'Object/ObjectAddPage.dart';
import 'Object/ObjectDetailPage.dart';

// TODO : ajout de la fonctionnalité de recherche d'objet par nom

/// Displays the details of a museum.
/// At the top of the page, the infos of the museum are displayed.
/// Then, the list of objects is displayed.
/// When an object is tapped, the [ObjectDetailPage] is displayed.
///
class MuseumDetailPage extends StatefulWidget {
  final Museum museum;
  final FirebaseDatabase database;

  const MuseumDetailPage({super.key, required this.museum, required this.database});

  @override
  State<StatefulWidget> createState() => _MuseumDetailPageState();
}

class _MuseumDetailPageState extends State<MuseumDetailPage> {

  // M E T H O D S
  void _showDeleteConfirmationDialog(
      BuildContext context, Museum museum, MuseumObject object) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text(
                'Êtes-vous sûr de vouloir supprimer cet objet ? Cette action est irreversible'),
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
                  widget.database.ref().child('museums').child(museum.id)
                      //.child("objects")
                      .child(object.id)
                      .remove();
                  Navigator.pop(context); // Ferme la boîte de dialogue
                },
                child: Text('Supprimer'),
              ),
            ],
          );
        });
  }

  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.museum.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Adresse: latitude ${widget.museum.address.latitude} & longitude ${widget.museum.address.longitude} '),
          Text('Site web: ${widget.museum.website}'),
          Text('Objets:'),

          // Display the list of objects
          widget.museum.objects != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.museum.objects?.length ?? 0,
                  // Coalecing operator : si museum.objects est null, alors on retourne 0, sinon on retourne la longueur de la liste
                  itemBuilder: (context, index) {
                    final object = widget.museum.objects?[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(object?.name ?? ''),
                          subtitle: Text(object?.description ?? ''),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ObjectDetailPage(
                                      object: object!,
                                      database: widget
                                          .database)), // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                // NAV MUSEUM EDIT PAGE
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ObjectEditPage(
                                            object: object!,
                                            database: widget.database)),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                // DELETE MUSEUM
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context,
                                      widget.museum!,
                                      object!); // Utilisation de ! car nous savons que l'objet ne sera pas nul ici
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 2),
                        // Add a divider between each ListTile
                      ],
                    );
                  },
                )
              : const Text('Aucun objet disponible pour ce musée'),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ObjectAddPage(database: widget.database)));
            },
            label: Text('Ajouter objet'),
            icon: Icon(Icons.add),
            heroTag: 'add_obect',
          ),
        ],
      ),
    );
  }
}
