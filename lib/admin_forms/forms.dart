// Form qui permet de faire du CRUD (Create, Read, Update, Delete) sur un objet stocké dans la firebase.
// Utiliser le fichier firebase_crud.dart pour faire le lien avec la firebase.

import 'package:expo_nomade/admin_forms/Objetcs/MuseumListPage.dart';
import 'package:flutter/material.dart';

import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject.dart';

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
          body: /*ToDo const*/ TabBarView(                             // 3. Create content for each tab
            children: [
              MuseumListPage(museums: dummyMuseums),
              Icon(Icons.directions_transit),   // Todo : supprimer, ici que exemple
              Icon(Icons.directions_bike),      // Todo : supprimer, ici que exemple
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


// Dummy data
final dummyMuseums = [
  Museum(
    id: '1',
    name: 'Museum 1',
    address: 'Address 1',
    website: 'Website 1',
    objects: [
      MuseumObject(
        name: 'Object 1',
        description: 'Description of Object 1',
        discoveries: [],
        sources: [],
      ),
      MuseumObject(
        name: 'Object 2',
        description: 'Description of Object 2',
        discoveries: [],
        sources: [],
      ),
    ],
  ),
  Museum(
    id: '2',
    name: 'Museum 2',
    address: 'Address 2',
    website: 'Website 2',
    objects: [
      MuseumObject(
        name: 'Object 3',
        description: 'Description of Object 3',
        discoveries: [],
        sources: [],
      ),
    ],
  ),
];