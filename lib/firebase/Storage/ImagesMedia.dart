import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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


  const ImageGallery({
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
          galleryContent = const Text('Aucune image à afficher');
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
                      title: const Text('Confirmez la suppression'),
                      content: const Text('Êtes-vous sûr de vouloir supprimer cette image ?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer le dialogue
                          },
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // 1) Supprimer l'image de Firebase Storage
                            final deletionIsSuccess = await FirebaseStorageUtil().deleteImageByUrl(widget.imageUrl);

                            // 2) Supprimer l'image de la liste d'URLs
                            if (deletionIsSuccess) {

                              // 2.1) En local dans le widget
                              widget.imageList?.remove(widget.imageUrl);

                              // 2.2) & (3) Dans le realtime database de Firebase
                              // Mettre à jour le nombre d'éléments dans la galerie d'images dans le parent widget
                                widget.onDelete(widget.indexImage); // Passer l'index de l'image au callback
                                // Call the callback to notify the parent widget that the image should be deleted

                            } else {
                              // Afficher un message d'erreur en cas d'échec de la suppression
                            }

                            Navigator.of(context).pop(); // Fermer le dialogue de confirmation
                          },
                          child: const Text('Supprimer'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(
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

  const ImageDialog({super.key, required this.imageUrl});

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


