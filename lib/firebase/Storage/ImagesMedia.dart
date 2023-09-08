import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

/// Widget that displays a gallery of images, used for the whole app.
class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final bool isEditMode;
  final Function(int indexImage)? onDeleteOfImage;


  ImageGallery({
    Key? key,
    required this.imageUrls,
    this.isEditMode = false,
    this.onDeleteOfImage,
  }) : super(key: key);

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int itemCount = 0; // Nombre d'éléments dans la galerie d'images

  @override
  void initState() {
    super.initState();
    itemCount = widget.imageUrls.length;
  }

  void handleItemDelete(int indexImage) {
    if(mounted)
      {
        setState(() {
          itemCount--; // Diminue le nombre d'éléments lorsqu'un élément est supprimé.
        });
      }

    // Call the callback to notify the parent widget that the image should be deleted in the DB
    if(widget.onDeleteOfImage != null) {
      widget.onDeleteOfImage!(indexImage);
    }

  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        // Variables for the gallery
        double galleryHeight = defaultImageHeight;
        Widget galleryContent;

        if (widget.imageUrls.isEmpty)
        {
          galleryHeight = 16.0;
          galleryContent = Text('Aucune image à afficher');
        }
        else
        {
          galleryContent = FutureBuilder<List<String>>(
            future: Future.value(widget.imageUrls),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
              {
                return const Center(
                  child: SpinKitCircle(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                );
              }
              else if (snapshot.hasError) {
                return const Text('Erreur de chargement des images');
              }
              else {
                // int itemCount = snapshot.data!.length;  // TODO : MODIFIER ICI ??
                return PageView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ImageDialog(imageUrl: snapshot.data![index]);
                          },
                        );
                      },
                      child: CustomImageStateful(
                        imageUrl: snapshot.data![index],
                        imageList: snapshot.data!,
                        itemCount: itemCount,
                        isEditMode: widget.isEditMode,
                        indexImage: index,
                        onDelete: (int indexImage) {
                          // Mettez ici la logique de suppression, si nécessaire
                          // Par exemple, vous pouvez appeler un gestionnaire de suppression
                          // qui effectue la suppression côté serveur ou met à jour la liste d'URLs.
                          handleItemDelete(indexImage);
                        },
                      ),
                    );
                  },
                );
              }
            },
          );
        }

        // Return the gallery content in a container
        return Container(
          height: galleryHeight,
          child: galleryContent,
        );
      },
    );
  }
}

// class ImageGallery extends StatelessWidget {
//   final List<String> imageUrls;
//   final bool isEditMode;
//
//   ImageGallery({
//     super.key,
//     required this.imageUrls,
//     this.isEditMode = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double galleryHeight = defaultImageHeight;
//         Widget galleryContent;
//
//         if (imageUrls.isEmpty)
//         {
//           galleryHeight = 16.0;
//           galleryContent = Text('Aucune image à afficher');
//         }
//         else
//         {
//           galleryContent = FutureBuilder<List<String>>(
//             future: Future.value(imageUrls),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting)
//               {
//                 return const Center(
//                   child: SpinKitCircle(
//                     color: Colors.blue,
//                     size: 50.0,
//                   ),
//                 );
//               }
//               else if (snapshot.hasError) {
//                 return Text('Erreur de chargement des images');
//               }
//               else {
//                 int itemCount = snapshot.data!.length;
//                 return PageView.builder(
//                   itemCount: itemCount,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             return ImageDialog(imageUrl: snapshot.data![index]);
//                           },
//                         );
//                       },
//                       child: CustomImageStateful(
//                         imageUrl: snapshot.data![index],
//                         imageList: snapshot.data!,
//                         itemCount: itemCount,
//                         isEditMode: isEditMode,
//                       ),
//                     );
//                   },
//                 );
//               }
//             },
//           );
//         }
//
//         return Container(
//           height: galleryHeight,
//           child: galleryContent,
//         );
//       },
//     );
//   }
// }



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
  final Function(int indexImage) onDelete;
  late int indexImage;

  CustomImageStateful({
    Key? key,
    required this.imageUrl,
    this.imageList,
    this.width = defaultImageWidth,
    this.height = defaultImageHeight,
    required this.itemCount,
    required this.isEditMode,
    required this.onDelete,
    required int indexImage,
  }) : super(key: key) {
    this.indexImage = indexImage;
  }



  @override
  _CustomImageState createState() => _CustomImageState();
}
class _CustomImageState extends State<CustomImageStateful> {
  // A T T R I B U T E S
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
                            // 1) Supprimer l'image de Firebase Storage
                            final deletionIsSuccess = await FirebaseStorageUtil().deleteImageByUrl(widget.imageUrl);

                            // 2) Supprimer l'image de la liste d'URLs
                            if (deletionIsSuccess) {
                              print('Image supprimée avec succès');

                              // 2.1) En local dans le widget
                              widget.imageList?.remove(widget.imageUrl);

                              // 2.2) Dans le realtime database de Firebase
                              // SE FERA DANS LE CALLBACK ?

                              // 2.2) Dans le realtime database de Firebase
                              // Vous pouvez gérer cela dans le callback onDeleteOfImage
                              // 3) Mettre à jour le nombre d'éléments dans la galerie d'images dans le parent widget

                                widget.onDelete(widget.indexImage); // Passer l'index de l'image au callback
                                // Call the callback to notify the parent widget that the image should be deleted

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
