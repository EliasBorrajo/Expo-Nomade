import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseStorageUtil {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Méthode pour télécharger une image depuis Firebase Storage
  Future<String> downloadImage(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return '';
    }
  }

  // Méthode pour télécharger une image sous forme de fichier depuis Firebase Storage
  Future<File?> downloadImageToFile(String path, String localFilePath) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final File file = File(localFilePath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return null;
    }
  }

  // Méthode pour téléverser une image vers Firebase Storage
  Future<String?> uploadImage(String path, File imageFile) async {
    try {
      final Reference ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      final String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Erreur lors du téléversement de l\'image : $e');
      return null;
    }
  }
}
