import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../dataModels/MuseumObject.dart';
import '../firebase_auth.dart';
import 'FirebaseStorageUtil.dart';

// Taille par défaut des images en petit de 800x600
const double defaultImageWidth = 800;
const double defaultImageHeight = 400;

// Taille des images sur le click en grand de 2560 x 1440
const double defaultImageWidthLarge = 2560;
const double defaultImageHeightLarge = 1440;

class ImageGallery extends StatelessWidget {
  // A T T R I B U T E S
  final List<String> imageUrls;
  final bool isEditMode;

  // C O N S T R U C T O R
  ImageGallery({
    super.key,
    required this.imageUrls,
    this.isEditMode = false,
  });

  /// Displays a gallery of images.
  /// FutureBuilder wraps the PageView to display a loading indicator while the images are being downloaded.
  /// Once the images are downloaded, they are displayed in a PageView.
  /// If an error occurs, an error message is displayed.
  /// If no image is available, a message is displayed.
  @override
  Widget build(BuildContext context) {
    return Container(
        height: defaultImageHeight,
        child: FutureBuilder<List<String>>(
          // Utilisez Future.wait pour télécharger toutes les images en parallèle
          future: Future.value(imageUrls),

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

              int itemCount = snapshot.data!.length;
              return PageView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ImageDialog(
                            imageUrl: snapshot.data![index],
                          );
                        },
                      );
                    },
                    child: CustomImageStateful(
                      imageUrl: snapshot.data![index],
                      imageList: snapshot.data!,
                      itemCount: itemCount,
                      isEditMode: isEditMode,
                    ),
                  );
                },
              );
            }
          },
        ));
  }
}

/// Displays an image.
class CustomImage extends StatelessWidget {
  // A T T R I B U T E S
  final String imageUrl;
  final double width;
  final double height;

  // C O N S T R U C T O R
  const CustomImage({
    Key? key, // Clé pour identifier le widget dans l'arbre des widgets
    required this.imageUrl,
    this.width = defaultImageWidth,
    this.height = defaultImageHeight,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: width / height,
          child: Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}


/// Displays an image.
/// This widget is stateful because it displays a delete icon on the image.
class CustomImageStateful extends StatefulWidget {
  final String imageUrl;
  final List<String>? imageList;
  final double width;
  final double height;
  late  int itemCount;
  final bool isEditMode;


  CustomImageStateful({
    Key? key,
    required this.imageUrl,
    this.imageList,
    this.width = defaultImageWidth,
    this.height = defaultImageHeight,
    required this.itemCount,
    required this.isEditMode,
  }) : super(key: key);

  @override
  _CustomImageState createState() => _CustomImageState();
}
class _CustomImageState extends State<CustomImageStateful> {
  // A T T R I B U T E S
  // bool isUserAuthenticated = true; // TODO : PUT BACK TO FALSE AFTER TESTING

  @override
  void initState() {
    super.initState();

    // checkUserAuthentication();
  }

  // Future<void> checkUserAuthentication() async {
  //   // Votre logique pour vérifier l'authentification ici
  //   await AuthService().checkUserAuthentication()
  //           .then((value)
  //           {
  //             // Verify if the widget is mounted before calling setState
  //             // If the user is authenticated, the value is not null
  //             if(mounted && value != null)
  //             {
  //               setState(() {
  //                 isUserAuthenticated = true;
  //               });
  //             }
  //           });
  // }

  @override
  void dispose() {
    // Effectuez le nettoyage nécessaire ici avant de détruire le widget.
    // Par exemple, si vous avez des abonnements Firebase, fermez-les ici.
    // isUserAuthenticated = false;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container( // Enveloppez l'ensemble dans un Container
      child: Stack(
        children: [
          // IMAGE DISPLAY
          Align(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: widget.width / widget.height,
              child: Image.network(
                widget.imageUrl,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // DELETE ICON ON IMAGE
          if (widget.isEditMode)
            Positioned(
            top: 200,
            right: 100,
            child: GestureDetector(
              onTap: () {
                // Afficher un dialogue de confirmation
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirmez la suppression'),
                      content: Text('Êtes-vous sûr de vouloir supprimer cette image ?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer le dialogue
                          },
                          child: Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Supprimer l'image ici
                            final deletionIsSuccess = await FirebaseStorageUtil().deleteImageByUrl(widget.imageUrl);

                            if (deletionIsSuccess) {
                              // Appeler la fonction onDelete avec l'index actuel pour mettre à jour la liste d'URLs
                              if(mounted)
                              {
                                setState(() {
                                  widget.imageList?.remove(widget.imageUrl);
                                  widget.itemCount = widget.imageList!.length;
                                  // TODO : RE-LOAD DATA FROM DB & dans appel DB SET STATE AUSSI
                                });
                              }
                            } else {
                              // Afficher un message d'erreur en cas d'échec de la suppression
                            }

                            Navigator.of(context).pop(); // Fermer le dialogue de confirmation
                          },
                          child: Text('Supprimer'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// Widget that displays an image in a dialog when tapped, to show it in full screen.
class ImageDialog extends StatelessWidget {
  final String imageUrl;

  ImageDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(); // Fermer le Dialog au tap
        },
        child: CustomImage(
          imageUrl: imageUrl,
          width: defaultImageWidthLarge,
          height: defaultImageHeightLarge,
        ),
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

//
// // MERGIN ABOVE EXAMPLES TOGETHER
// class MyScreen2 extends StatelessWidget {
//   final List<String> imageUrls = [
//     'url_image_1.jpg',
//     'url_image_2.jpg',
//     'url_image_3.jpg',
//     // Ajoutez d'autres URL d'images ici
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//
//     final firebaseStorageUtil = FirebaseStorageUtil(); // Créez une instance de la classe FirebaseStorageUtil
//
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Galerie d\'images')),
//       body: FutureBuilder<List<String>>(
//         // Utilisez Future.wait pour télécharger toutes les images en parallèle
//         future: Future.wait(imageUrls.map((url) => firebaseStorageUtil.downloadImage(url))),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Affichez un indicateur de chargement pendant le téléchargement
//             return CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             // Gérez les erreurs ici
//             return Text('Erreur de chargement des images');
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             // Aucune image disponible
//             return Text('Aucune image à afficher');
//           } else {
//             // Affichez les images une fois qu'elles sont téléchargées
//             return ListView.builder( // TODO :Remplacer par ImageGalry ICI, OU PageView.builder
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 return CustomImage(imageUrl: snapshot.data![index]);
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

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
