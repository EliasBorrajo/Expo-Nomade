import 'package:flutter/material.dart';

class FiltersWindow extends StatefulWidget {
  const FiltersWindow({super.key});

  @override
  _FiltersWindowState createState() => _FiltersWindowState();
}

class _FiltersWindowState extends State<FiltersWindow> {
  //Filters filters = Filters();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtres'),
      content: const SingleChildScrollView(
        child: Column(
          children: [
            // Exemple pour les filtres Chronology Tags Labels
            Text('Chronologie - Étiquettes'),
            /*for (var label in filters.chronologyTagsLabels)
              CheckboxListTile(
                title: Text(label),
                value: true, // Remplacez par la logique de sélection appropriée
                onChanged: (value) {
                  setState(() {
                    // Mettez à jour la sélection ici
                  });
                },
              ),*/

            // Exemple pour les filtres Migration Reason
            Text('Raison de la migration'),
            /*for (var reason in filters.migrationReason)
              CheckboxListTile(
                title: Text(reason),
                value: true, // Remplacez par la logique de sélection appropriée
                onChanged: (value) {
                  setState(() {
                    // Mettez à jour la sélection ici
                  });
                },
              ),*/

            // Ajoutez d'autres filtres de la même manière
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermer la fenêtre de filtre
          },
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}