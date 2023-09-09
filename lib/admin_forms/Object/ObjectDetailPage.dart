import 'package:expo_nomade/firebase/Storage/ImagesMedia.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../dataModels/MuseumObject.dart';
import '../../firebase/Storage/FirebaseStorageUtil.dart';

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


  // M E T H O D S
  @override
  void initState() {
    super.initState();

    // F I R E B A S E
  }

  @override
  void dispose() {
    super.dispose();
  }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de l'objet : ${widget.object.name}"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nom',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(
              widget.object.name,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 16), // Space between the object name and its description label



            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              widget.object.description,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),



            Expanded(child: ImageGallery(
                imageUrls: widget.object.images ?? [],
                isEditMode: false)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }




}
