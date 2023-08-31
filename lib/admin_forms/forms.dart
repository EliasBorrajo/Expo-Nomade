// Form qui permet de faire du CRUD (Create, Read, Update, Delete) sur un objet stocké dans la firebase.
// Utiliser le fichier firebase_crud.dart pour faire le lien avec la firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expo_nomade/admin_forms/Objetcs/MuseumListPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_options.dart';
import 'dummyData.dart';

// TODO : REMOVE ONLY BY ELIAS
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( name: "exponomade-6452" ,options: DefaultFirebaseOptions.currentPlatform,);
  //Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // TODO : REMOVE

  runApp( const adminForms());
}


class adminForms extends StatelessWidget
{
  const adminForms({super.key}); // Constructeur

  static FirebaseFirestore db = FirebaseFirestore.instance; // Récupère l'instance de la firebase firestore
  static FirebaseDatabase database = FirebaseDatabase.instance; // Récupère l'instance de la firebase realtime database

  // R E N D E R I N G
  @override
  Widget build(BuildContext context)
  {
    const appTitle = 'Form Validation';

    return MaterialApp(
      title: appTitle,
      home: DefaultTabController(                             // 1. Create a TabController
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [                                         // 2. Create the tabs
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.account_balance)),
                Tab(icon: Icon(Icons.accessible_forward)),
                Tab(icon: Icon(Icons.ac_unit)),
              ],
            ),
            title: const Text('Admin data management'),
          ),
          body: /*ToDo const*/ TabBarView(                             // 3. Create content for each tab
            children: [
              MuseumListPage(
                  museums: dummyMuseums,
                  firestore: db ,
                  database: database),
              Icon(Icons.account_balance),          // Todo : supprimer, ici que exemple - MILENA AJOUTER QUIZZ ICI
              Icon(Icons.accessible_forward),       // Todo : supprimer, ici que exemple
              Icon(Icons.ac_unit)
              // TODO : FormObject et MUSEE(),
              // TODO : FormFiltres&Tag(),
              // TODO : FormQuizz(),
              // TODO : GEOGRAPHIE()

            ],
          ),
        ),
      ),
    );
  }
}



