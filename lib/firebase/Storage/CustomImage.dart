import 'package:flutter/material.dart';

import 'FirebaseStorageUtil.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width = 100, // Spécifiez la largeur souhaitée
    this.height = 100, // Spécifiez la hauteur souhaitée
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover, // Ajustez l'image pour couvrir la boîte définie
      errorBuilder: (context, error, stackTrace) {
        // Gérez les erreurs d'affichage ici, par exemple, affichez une icône par défaut
        return Icon(Icons.error);
      },
    );
  }
}


// EXAMPLE ON HOW TO IMPLEMENT THE WIDGET "CustomImage" WITH "FirebaseStorageUtil"
class example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseStorageUtil = FirebaseStorageUtil(); // Créez une instance de la classe FirebaseStorageUtil


    return FutureBuilder<String>(
      future: firebaseStorageUtil.downloadImage('votre_image.jpg'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affichez un indicateur de chargement pendant le téléchargement
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Gérez les erreurs ici
          return Text('Erreur de chargement de l\'image');
        } else {
          // Une fois l'URL de l'image disponible, utilisez CustomImage pour l'afficher
          return CustomImage(imageUrl: snapshot.data ?? '');
        }
      },
    );

  }
}
