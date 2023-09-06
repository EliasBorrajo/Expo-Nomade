import 'package:expo_nomade/PageManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase/firebase_options.dart';

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
      title: 'ExpoNomade',
      theme: ThemeData(
        useMaterial3: true,
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          titleLarge: GoogleFonts.oswald( // Appbar Text
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.cabin( // Body Text
            fontSize: 30,
          ),
        ),
        listTileTheme: ListTileThemeData(
            titleTextStyle: GoogleFonts.cabin(
                fontSize: 25
            ),
            textColor: Colors.black
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.jost(
                  fontSize: 25,
                )
            )
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            extendedTextStyle:  GoogleFonts.cabin(
              fontSize: 30
            )
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.cabin(
              fontSize: 25,
            )
          )
        )
      ),
      home: PageManager(database: database,), // Set MapScreen as the initial screen
    );
  }
}
