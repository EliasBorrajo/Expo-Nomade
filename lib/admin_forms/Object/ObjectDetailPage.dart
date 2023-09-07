import 'package:expo_nomade/admin_forms/Object/ObjectAddPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../dataModels/MuseumObject.dart';

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
  // A T T R I B U T E S
  late Future<String> imageUrl; // Stockez l'URL de l'image ici


  // M E T H O D S
  @override
  void initState() {
    super.initState();
    // Chargez l'URL de l'image depuis Firebase Storage
    imageUrl = _loadImage()
                  .whenComplete(() => print('Image chargée'));
  }

  Future<String> _loadImage() async {
    // Utilisez la référence à Firebase Storage pour obtenir l'URL de l'image
    String fileName = "wallhaven-zmo9wg.png";
    final Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    try {
      print('Chargement de l\'image...');
      final String url = await storageReference.getDownloadURL();
      return url;

    } catch (e) {
      print('Erreur lors du chargement de l\'image : $e');
      return '';
    }
  }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.object.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description: ${widget.object.description}'),
          FutureBuilder<String>(
              future: imageUrl,
              builder: (context, snapshot)
              {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Indication de chargement
                } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                  return Text('Aucune image');
                } else {
                  return Image.network(snapshot.data!);
                }
              }
          )

        ],
      )
    );

  }
}
