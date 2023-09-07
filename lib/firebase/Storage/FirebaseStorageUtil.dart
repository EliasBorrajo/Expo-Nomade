import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CustomImage.dart';

// TODO : Constuire le FILE NAME pour eviter que 2 images ont le même nom
// TODO : Ajouter une fonction pour supprimer une image
// TODO : Ajouter une fonction pour chercher une image dans la gallery, et verifier la size de l'image

// Énumération pour les dossiers possibles
enum FirebaseStorageFolder {
  migrations,
  museums,
  objects,
  root
}

class FirebaseStorageUtil {
  // A T T R I B U T E S
  final FirebaseStorage _storage = FirebaseStorage.instance;


  // M E T H O D S
  /// Uploads an image to Firebase Storage.
  /// Parameters:
  /// - folder: the folder in which the image will be uploaded
  /// - fileName: the name of the image file
  /// - imageFile: the image file to upload
  /// - Returns: the name of the image file (useful to store the image in the database)
  Future<String?> uploadImage(FirebaseStorageFolder folder, String fileName, File imageFile) async {
    try {
      // 1) upload the image to Firebase Storage
      final Reference ref = _storage.ref().child(_folderToString(folder)).child(fileName);
      await ref.putFile(imageFile);

      // 2) return the name of the image file (useful to store the image in the database)
      return ref.name;

    } catch (e) {
      print('Erreur lors du téléversement de l\'image : $e');
      return null;
    }
  }

  /// Uploads an image to Firebase Storage.
  /// Parameters:
  /// - folder: the folder in which the image will be uploaded
  /// - fileName: the name of the image file
  /// - imageFile: the image file to upload
  /// - Returns: the URL of the image file (useful to store the image in the database).
  ///            With this URL, the image can be displayed with the widget CustomImage directly witout having to download it.
  Future<String?> uploadImageReturnURL(FirebaseStorageFolder folder, String fileName, File imageFile) async {
    try {
      // 1) upload the image to Firebase Storage
      final Reference ref = _storage.ref().child(_folderToString(folder)).child(fileName);
      await ref.putFile(imageFile);

      // 2) return the URL of the image file (useful to store the image in the database)
      final String url = await ref.getDownloadURL();
      return url;

    } catch (e) {
      print('Erreur lors du téléversement de l\'image : $e');
      return null;
    }
  }

  /// Downloads an image from Firebase Storage.
  /// Parameters:
  /// - folder: the folder in which the image is stored in Firebase Storage
  /// - fileName: the name of the image file
  /// - Returns: the URL of the image file (useful to display the image with the widget CustomImage)
  Future<String> downloadImage(FirebaseStorageFolder folder, String fileName) async {
    try {
      final Reference ref = _storage.ref().child(_folderToString(folder)).child(fileName);
      final String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return '';
    }
  }

  /// Translates a FirebaseStorageFolder enum value to a String.
  /// Useful to point to a specific folder in Firebase Storage.
  /// Parameters:
  /// - folder: the folder to translate to a String value (e.g. FirebaseStorageFolder.museums)
  String _folderToString(FirebaseStorageFolder folder) {
    switch (folder) {
      case FirebaseStorageFolder.migrations:
        return 'migrations';
      case FirebaseStorageFolder.museums:
        return 'museums';
      case FirebaseStorageFolder.objects:
        return 'objects';
      case FirebaseStorageFolder.root:
        return '';
      default:
        throw ArgumentError('Dossier invalide');
    }
  }

  // Build unique file name for image (to avoid having 2 images with the same name)
  String _buildFileName(String fileName) {
    // TODO : Build unique file name for image (to avoid having 2 images with the same name)


    return fileName;
  }

}



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
