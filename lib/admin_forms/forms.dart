import 'package:expo_nomade/admin_forms/Migrations/MigrationListPage.dart';
import 'package:expo_nomade/admin_forms/Museum/MuseumListPage.dart';
import 'package:expo_nomade/admin_forms/quiz/quiz_list_page.dart';
import 'package:expo_nomade/admin_forms/quiz/quiz_list_players.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'filter/filterListPage.dart';

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
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.museum_rounded), text: 'Musées'),
                Tab(icon: Icon(Icons.tag_rounded), text: 'Tags'),
                Tab(icon: Icon(Icons.share_location_rounded), text: 'Migrations'),
                Tab(icon: Icon(Icons.question_answer_rounded), text: 'Quizz'),
                Tab(icon: Icon(Icons.accessibility_rounded), text: 'Joueurs'),
              ],
            ),
            title: const Text('Console d\'administration'),
          ),
          body: TabBarView(
            children: [
              MuseumListPage(database: database),
              FilterListPage(database: database),
              MigrationListPage(database: database),
              QuizListPage(database: database),
              QuizListPlayers(database: database),
            ],
          ),
        ),
      ),
    );
  }
}