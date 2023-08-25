// Form qui permet de faire du CRUD (Create, Read, Update, Delete) sur un objet stocké dans la firebase.
// Utiliser le fichier firebase_crud.dart pour faire le lien avec la firebase.

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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
          body: const TabBarView(                             // 3. Create content for each tab
            children: [
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