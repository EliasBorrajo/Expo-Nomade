import 'dart:async';

import 'package:expo_nomade/admin_forms/Object/ObjectAddPage.dart';
import 'package:expo_nomade/firebase/Storage/ImagesMedia.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../dataModels/MuseumObject.dart';
import '../../firebase/Storage/FirebaseStorageUtil.dart';
import '../Migrations/MigrationListPage.dart';

// TODO : Ajouter des Tags à l'objet
// TODO : Loader l'ojet depuis la DB et afficher l'image

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
  late StreamSubscription<DatabaseEvent> _objectSubscription;


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

  // Future<void> _loadImages() async
  // {
  //   print("Chargement des images");
  //   String? imageUrl1 = await FirebaseStorageUtil().downloadImage(
  //     FirebaseStorageFolder.root,
  //     "wallhaven-zmo9wg.png",
  //   );
  //   print("Image 1 chargée");
  //
  //   String? imageUrl2 = await FirebaseStorageUtil().downloadImage(
  //     FirebaseStorageFolder.root,
  //     "wallhaven-pkgkkp.png",
  //   );
  //   print("Image 2 chargée");
  //
  //
  //   if(mounted)
  //   {
  //     setState(() {
  //       URLS.add(imageUrl1 ?? ''); // Au cas ou le download echoue et renvoie null
  //       URLS.add(imageUrl2 ?? '');
  //     });
  //   }
  //
  //   print("Toutes Images chargées");
  //   print("URLS : ${URLS.toString()}");
  // }
  //
  // Future<String> _loadImage() async {
  //   // Utilisez la référence à Firebase Storage pour obtenir l'URL de l'image
  //   String fileName = "wallhaven-zmo9wg.png";
  //   final Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
  //
  //   try {
  //     print('Chargement de l\'image...');
  //     final String url = await storageReference.getDownloadURL();
  //     print('Download URL : $url');
  //
  //     print('Reference : ${storageReference}');
  //     return url;
  //
  //   } catch (e) {
  //     print('Erreur lors du chargement de l\'image : $e');
  //     return '';
  //   }
  // }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {

    final firebaseStorageUtil = FirebaseStorageUtil();

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



            Expanded(
                child: ImageGallery(
                imageUrls: widget.object.images ?? [],
                isEditMode: false)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }




}
