// Form qui permet de faire du CRUD (Create, Read, Update, Delete) sur un objet stocké dans la firebase.
// Utiliser le fichier firebase_crud.dart pour faire le lien avec la firebase.

import 'package:expo_nomade/admin_forms/Migrations/MigrationListPage.dart';
import 'package:expo_nomade/admin_forms/Objetcs/MuseumListPage.dart';
import 'package:expo_nomade/admin_forms/quiz/quiz_list_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dummyData.dart';

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
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.question_answer)),
                Tab(icon: Icon(Icons.accessible_forward)),
                Tab(icon: Icon(Icons.ac_unit)),
              ],
            ),
            title: const Text('Admin data management'),
          ),
          body: TabBarView(
            children: [
              MuseumListPage(database: database),
              QuizListPage(database: database),
              Icon(Icons.accessible_forward), // TODO : TAGS PAGE
              MigrationListPage(
                  //migrations: dummyMigrations,
                  database: database)


            ],
          ),
        ),
      ),
    );
  }
}