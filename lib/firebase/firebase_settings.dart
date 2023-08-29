import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

// TODO : REMOVE -- GARDER LES LIGNES 16 à 21 POUR SEPARER LES API KEY ETC...

class DefaultFirebaseOptions {
  static Future<FirebaseOptions> get currentPlatform async
  {
    await Firebase.initializeApp(); // Await will wait for the firebase to be initialized before continuing

    // Load the config file (api keys, etc.)
    final String configString = await rootBundle.loadString('firebase/firebase_config.json');
    final Map<String, dynamic> config = json.decode(configString);

    return FirebaseOptions(
      apiKey:             config['apiKey'],
      appId:              config['appId'],
      messagingSenderId:  config['messagingSenderId'],
      projectId:          config['projectId'],
      storageBucket:      config['storageBucket'],
    );
  }
}
