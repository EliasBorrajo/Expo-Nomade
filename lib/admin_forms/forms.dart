// Form qui permet de faire du CRUD (Create, Read, Update, Delete) sur un objet stocké dans la firebase.
// Utiliser le fichier firebase_crud.dart pour faire le lien avec la firebase.

import 'package:expo_nomade/admin_forms/Objetcs/MuseumListPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_settings.dart';
import 'dummyData.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();  // Permet d'initialiser les plugins avant d'initialiser Firebase
  final FirebaseOptions options = await DefaultFirebaseOptions.currentPlatform; // Récupère les options de la firebase
  await Firebase.initializeApp(options: options); // Initialise la firebase avec les options récupérées

  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key}); // Constructeur

  // R E N D E R I N G
  @override
  Widget build(BuildContext context)
  {
    const appTitle = 'Form Validation';

    return MaterialApp(
      title: appTitle,
      home: DefaultTabController(                             // 1. Create a TabController
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [                                         // 2. Create the tabs
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.account_balance)),
                Tab(icon: Icon(Icons.accessible_forward)),
              ],
            ),
            title: const Text('Tabs'),
          ),
          body: /*ToDo const*/ TabBarView(                             // 3. Create content for each tab
            children: [
              MuseumListPage(museums: dummyMuseums),
              Icon(Icons.account_balance),          // Todo : supprimer, ici que exemple - MILENA AJOUTER QUIZZ ICI
              Icon(Icons.accessible_forward),       // Todo : supprimer, ici que exemple
              // FormObject(),
              // FormFiltres(),
              // FormQuizz(),
            ],
          ),
        ),
      ),
    );
  }
}



