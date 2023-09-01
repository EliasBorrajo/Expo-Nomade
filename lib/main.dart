import 'package:expo_nomade/PageManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';
import 'firebase/firebase_options.dart';
import 'map/map_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "exponomade-6452",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // F I R E B A S E
  static FirebaseDatabase database = FirebaseDatabase.instance; // Récupère l'instance de la firebase realtime database
  // TODO : Donner cet attribut à CRUD_FICHIER et toutes les methodes la bas dedans


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Example',
      home: PageManager(), // Set MapScreen as the initial screen
    );
  }
}
