// Form qui permet de faire du CRUD (Create, Read, Update, Delete) sur un objet stocké dans la firebase.
// Utiliser le fichier firebase_crud.dart pour faire le lien avec la firebase.

import 'package:expo_nomade/admin_forms/Migrations/MigrationListPage.dart';
import 'package:expo_nomade/admin_forms/Objetcs/MuseumListPage.dart';
import 'package:expo_nomade/admin_forms/quiz/quiz_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_options.dart';
import 'dummyData.dart';

// TODO : REMOVE ONLY BY ELIAS
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( name: "exponomade-6452" ,options: DefaultFirebaseOptions.currentPlatform,);

  runApp( const AdminForms());
}


class AdminForms extends StatelessWidget
{
  const AdminForms({super.key}); // Constructeur

  // F I R E B A S E
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.account_balance)),
                Tab(icon: Icon(Icons.accessible_forward)),
                Tab(icon: Icon(Icons.ac_unit)),
              ],
            ),
            title: const Text('Admin data management'),
          ),
          body: TabBarView(
            children: [
              MuseumListPage(
                  museums: dummyMuseums,
                  database: database),
            QuizListPage(questions: dummyQuiz, database: database),          // Todo : supprimer, ici que exemple - MILENA AJOUTER QUIZZ ICI
              Icon(Icons.accessible_forward),       // Todo : supprimer, ici que exemple
              MigrationListPage(
                  migrations: dummyMigrations,
                  database: database)
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



