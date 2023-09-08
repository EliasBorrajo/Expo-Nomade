import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


// TODO : Ajouter une fonction pour supprimer une image

/// Énumération pour les dossiers possibles dans Firebase Storage
enum FirebaseStorageFolder {
  migrations,
  museums,
  objects,
  root
}

enum extensionsAllowed {
  jpg,
  jpeg,
  png
}

class FirebaseStorageUtil {
  // A T T R I B U T E S
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final maxImageSizeInBytes = 1000 * 1024 * 1024; // 1000 * 1024 * 1024 = 1 Go

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
      String uniqueName = _buildUniqueFileName(fileName);
      final Reference ref = _storage.ref().child(_folderToString(folder)).child(uniqueName);
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
      String uniqueName = _buildUniqueFileName(fileName);
      final Reference ref = _storage.ref().child(_folderToString(folder)).child(uniqueName);
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
  /// - fileName: the name of the image file. This name is the name of the file in Firebase Storage.
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

  /// Build unique file name for image (to avoid having 2 images with the same name)
  /// Parameters:
  /// - fileName: the name of the image file
  /// - Returns: the unique file name for the image to be stored in Firebase Storage
  String _buildUniqueFileName(String fileName) {
  // Obtenez un horodatage actuel ou un identifiant unique généré par Firebase
    final String uniqueSuffix = DateTime.now().millisecondsSinceEpoch.toString(); // Utilisez l'horodatage actuel

    // Séparez l'extension du nom de fichier (si elle existe)
    final List<String> nameParts = fileName.split('.');
    final String fileExtension = nameParts.length > 1 ? '.${nameParts.last}' : '';
    // Si le nom de fichier n'a pas d'extension, ajoutez une chaîne vide à la fin,
    // sinon ajoutez l'extension à la fin, y compris le point

    // Combinez le nom de fichier original, le suffixe unique et l'extension
    final String uniqueFileName = '${nameParts.first}_$uniqueSuffix$fileExtension';

    print('Nom de fichier unique : $uniqueFileName');

    return uniqueFileName;

  }

  /// Opens the image picker to select an image from the gallery.
  /// Returns: the image file selected by the user (null if the user cancelled the selection)
  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {

      // EXTENSION - Vérifier le type de fichier (extension)
      final String extension = pickedFile.name.split('.').last.toLowerCase();
      if (extension == 'jpeg' || extension == 'jpg')
      {

        // FILE SIZE - Vérifier la taille du fichier
        final File imageFile = File(pickedFile.path);
        final int fileSize = await imageFile.length();
        if (fileSize <= maxImageSizeInBytes) {

          // Le fichier a été sélectionné avec succès depuis la galerie,
          // il est du bon type et de la bonne taille.
          return imageFile;
        }
        else {
          // Le fichier est trop volumineux, affichez un message d'erreur.
          print('Le fichier sélectionné est trop volumineux. La taille maximale autorisée est de ${maxImageSizeInBytes} Go .');
        }
      }
      else {
        // Le fichier n'a pas l'extension requise, affichez un message d'erreur.
        print('Le fichier sélectionné n\'est pas du type ${extensionsAllowed.jpg} / ${extensionsAllowed.jpeg} / ${extensionsAllowed.png}.');
      }
    }
    else {
      // L'utilisateur a annulé la sélection de l'image depuis la galerie.
      return null;
    }

    return null;

  }

  /// Opens the image picker to select an image from the camera.
  /// Returns: the image file selected by the user (null if the user cancelled the selection)
  Future<String?> uploadImageFromGallery(FirebaseStorageFolder folder) async
  {
    try
    {
      // 1) Ouvrez le sélecteur d'image pour sélectionner une image depuis la galerie
      final pickedImage = await pickImageFromGallery();

      if (pickedImage != null)
      {
        // 2) Téléversez l'image sélectionnée dans Firebase Storage et obtenez l'URL de l'image téléversée
        // Obtenez le nom du fichier à partir du chemin (path) du fichier, ex: /images/image1.jpg -> image1.jpg
        final fileName = pickedImage.path.split('/').last;
        final uploadedImageUrl = await uploadImageReturnURL( folder,
                                                             fileName,
                                                             pickedImage,
                                                          );

        if (uploadedImageUrl != null)
        {
          // L'image a été téléversée avec succès, vous pouvez utiliser l'URL ici.
          // TODO : Sauvegarder l'URL dans la base de données ici & son instance
          return uploadedImageUrl;
        }
        else
        {
          // Une erreur s'est produite lors du téléversement de l'image.
          // Afficher un message d'erreur à l'utilisateur dans un toast ou une boîte de dialogue.

        }
      }
      else
      {
        // L'utilisateur a annulé la sélection de l'image depuis la galerie.
        // Afficher un toast d'opération annulée à l'utilisateur.

      }
    }
    catch (e)
    {
      // Une erreur s'est produite lors du téléversement de l'image.
      // Afficher un message d'erreur à l'utilisateur dans un toast ou une boîte de dialogue.
    }


    return null;

  }


  /// Deletes an image from Firebase Storage using its URL.
  /// Parameters:
  /// - imageUrl: the URL of the image to delete (e.g. https://firebasestorage.googleapis.com/v0/b/.../o/images%2Fimage1.jpg?alt=media&token=...)
  /// - Returns: true if the image was successfully deleted, false otherwise
  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      final Reference ref = await _storage.refFromURL(imageUrl);
      await ref.delete();
      return true; // L'image a été supprimée avec succès
    } catch (e) {
      print('Erreur lors de la suppression de l\'image : $e');
      return false; // Une erreur s'est produite lors de la suppression de l'image
    }
  }



}
