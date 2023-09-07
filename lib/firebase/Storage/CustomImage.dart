import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../dataModels/MuseumObject.dart';
import 'FirebaseStorageUtil.dart';

// Utiliser JPEG par défaut, PNG si on a besoin de transparence
const String defaultImageFormat = 'jpg';

// Taille par défaut des images en petit de 800x600
const double defaultImageWidth = 800;
const double defaultImageHeight = 600;

// Taille des images sur le click en grand de 2560 x 1440
const double defaultImageWidthLarge = 2560;
const double defaultImageHeightLarge = 1440;




class ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  // final List<Future<Uint8List>> imageBytes;

  ImageGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return CustomImage(
          imageUrl: imageUrls[index],
        );
      },
    );
  }
}




class CustomImage extends StatelessWidget {
  // A T T R I B U T E S
  final String imageUrl;
  //final Future<Uint8List> imageBytes; // Stockez les octets de l'image ici
  final double width;
  final double height;

  // C O N S T R U C T O R
  const CustomImage({
    Key? key,                         // Clé pour identifier le widget dans l'arbre des widgets
    required this.imageUrl,
    //required this.imageBytes,
    this.width = defaultImageWidth,
    this.height = defaultImageHeight,
  }) : super(key: key);

  // M E T H O D S
  // Méthode pour afficher l'image en grand dans un dialogue
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: CustomImage(
              imageUrl: imageUrl,
              width: defaultImageWidthLarge,
              height: defaultImageHeightLarge,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showImageDialog(context); // Ouvre le dialogue avec l'image en grand
      },
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red);
        },
      ),
    );
  }
}















//
// // EXAMPLE ON HOW TO IMPLEMENT THE WIDGET "CustomImage" WITH "FirebaseStorageUtil"
// class example extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final firebaseStorageUtil = FirebaseStorageUtil(); // Créez une instance de la classe FirebaseStorageUtil
//
//
//     return FutureBuilder<String>(
//       future: firebaseStorageUtil.downloadImage('votre_image.jpg'),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Affichez un indicateur de chargement pendant le téléchargement
//           return CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           // Gérez les erreurs ici
//           return Text('Erreur de chargement de l\'image');
//         } else {
//           // Une fois l'URL de l'image disponible, utilisez CustomImage pour l'afficher
//           return CustomImage(imageUrl: snapshot.data ?? '');
//         }
//       },
//     );
//
//   }
// }






// // OTHER EXAMPLE HOW TO IMPLEMENT GALERY
// class MyScreen extends StatelessWidget {
//   final List<String> imageUrls = [
//     'url_image_1.jpg',
//     'url_image_2.jpg',
//     'url_image_3.jpg',
//     // Ajoutez d'autres URL d'images ici
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Galerie d\'images')),
//       body: ImageGallery(imageUrls: imageUrls),
//     );
//   }
// }








// MERGIN ABOVE EXAMPLES TOGETHER
class MyScreen2 extends StatelessWidget {
  final List<String> imageUrls = [
    'url_image_1.jpg',
    'url_image_2.jpg',
    'url_image_3.jpg',
    // Ajoutez d'autres URL d'images ici
  ];

  @override
  Widget build(BuildContext context) {

    final firebaseStorageUtil = FirebaseStorageUtil(); // Créez une instance de la classe FirebaseStorageUtil


    return Scaffold(
      appBar: AppBar(title: Text('Galerie d\'images')),
      body: FutureBuilder<List<String>>(
        // Utilisez Future.wait pour télécharger toutes les images en parallèle
        future: Future.wait(imageUrls.map((url) => firebaseStorageUtil.downloadImage(url))),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Affichez un indicateur de chargement pendant le téléchargement
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Gérez les erreurs ici
            return Text('Erreur de chargement des images');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Aucune image disponible
            return Text('Aucune image à afficher');
          } else {
            // Affichez les images une fois qu'elles sont téléchargées
            return ListView.builder( // TODO :Remplacer par ImageGalry ICI, OU PageView.builder
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return CustomImage(imageUrl: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}





// // Final Look on the example
// class MyScreen3 extends StatelessWidget {
//   // A T T R I B U T E S
//   final MuseumObject museumObject = MuseumObject(
//     id: '1',
//     museumId: 'museum1',
//     name: 'Objet 1',
//     description: 'Description de l\'objet 1',
//     point: LatLng(0.0, 0.0),
//     images: ['url_image_1.jpg', 'url_image_2.jpg', 'url_image_3.jpg'],
//   );
//
//   MyScreen3({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Galerie d\'images')),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Nom: ${museumObject.name}'),
//           Text('Description: ${museumObject.description}'),
//           // Afficher les images à partir de la liste d'URL
//           if (museumObject.images != null)
//             Column(
//               children: museumObject.images!.map((imageUrl) {
//                 // return CustomImage(imageUrl: imageUrl);
//                 return ImageGallery(imageUrls: imageUrl);
//               }).toList(),
//             )
//           else
//             Text('Aucune image'),
//         ],
//       ),
//     );
//   }
// }

