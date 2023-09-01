import 'package:expo_nomade/admin_forms/Museum/Object/ObjectAddPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../dataModels/MuseumObject.dart';

// TODO : Edit les informations de l'objet
// TODO : Ajouter des Tags à l'objet

class ObjectDetailPage extends StatefulWidget {

  final MuseumObject object;
  final FirebaseDatabase database;

  const ObjectDetailPage(
      {super.key, required this.object, required this.database});

  @override
  State<StatefulWidget> createState() => _ObjectDetailPageState();

}

class _ObjectDetailPageState extends State<ObjectDetailPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.object.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description: ${widget.object.description}'),
          Text('Images: ${widget.object.images ?? 'Aucune image'}'),
          // Ajoutez ici l'affichage des détails de découvertes et sources si nécessaire
        ],
      )

      );

  }
}
