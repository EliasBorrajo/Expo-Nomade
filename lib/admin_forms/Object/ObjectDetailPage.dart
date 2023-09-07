import 'package:expo_nomade/admin_forms/Object/ObjectAddPage.dart';
import 'package:expo_nomade/firebase/Storage/CustomImage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  // A T T R I B U T E S
  late Future<String> imageUrl; // Stockez l'URL de l'image ici
  late List<String> URLS = [];

  // M E T H O D S
  @override
  void initState() {
    super.initState();
    // Chargez l'URL de l'image depuis Firebase Storage
    // imageUrl = _loadImage()
    //     .whenComplete(() => print('Image chargée'));

    // F I R E B A S E
    _loadImages();


  }

  Future<void> _loadImages() async
  {
    print("Chargement des images");
    String? imageUrl1 = await FirebaseStorageUtil().downloadImage(
      FirebaseStorageFolder.root,
      "wallhaven-zmo9wg.png",
      );
    print("Image 1 chargée");

    String? imageUrl2 = await FirebaseStorageUtil().downloadImage(
      FirebaseStorageFolder.root,
      "wallhaven-pkgkkp.png",
    );
    print("Image 2 chargée");


    if(mounted)
      {
        setState(() {
          URLS.add(imageUrl1 ?? ''); // Au cas ou le download echoue et renvoie null
          URLS.add(imageUrl2 ?? '');
        });
      }

    print("Toutes Images chargées");
    print("URLS : ${URLS.toString()}");
  }

  Future<String> _loadImage() async {
    // Utilisez la référence à Firebase Storage pour obtenir l'URL de l'image
    String fileName = "wallhaven-zmo9wg.png";
    final Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    try {
      print('Chargement de l\'image...');
      final String url = await storageReference.getDownloadURL();
      print('Download URL : $url');

      print('Reference : ${storageReference}');
      return url;

    } catch (e) {
      print('Erreur lors du chargement de l\'image : $e');
      return '';
    }
  }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {

    final firebaseStorageUtil = FirebaseStorageUtil(); // Créez une instance de la classe FirebaseStorageUtil


    return Scaffold(
        appBar: AppBar(title: Text(widget.object.name)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${widget.object.description}'),
            // Expanded( // Utilisez Expanded pour que le PageView occupe tout l'espace disponible en hauteur
            //   child: ImageGallery2(imageUrls: URLS)),
            ImageGallery2(imageUrls: URLS)
          ],
        )
    );
  }
}
