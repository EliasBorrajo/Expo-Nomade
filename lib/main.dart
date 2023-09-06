import 'package:expo_nomade/PageManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase/firebase_options.dart';
import 'dart:math' as math;

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

  double calculateFontSize(BuildContext context, double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = math.min(1.5, screenWidth / 400); // Ajustez 400 à la largeur souhaitée.

    return baseFontSize * scaleFactor;
  }


  @override
  Widget build(BuildContext context) {
    double largeFontSize = 20;
    double baseFontSize = 15;
    double dynamicLargeFontSize = calculateFontSize(context, largeFontSize);
    double dynamicBaseFontSize = calculateFontSize(context, baseFontSize);

    return MaterialApp(
      title: 'ExpoNomade',
      theme: ThemeData(
        useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.oswald( // Appbar Text
            fontSize: dynamicLargeFontSize,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.cabin( // Body Text
            fontSize: dynamicLargeFontSize,
          ),
        ),
        listTileTheme: ListTileThemeData(
            titleTextStyle: GoogleFonts.cabin(
                fontSize: dynamicBaseFontSize
            ),
            textColor: Colors.black
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.jost(
                  fontSize: dynamicBaseFontSize,
                )
            )
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            extendedTextStyle:  GoogleFonts.cabin(
              fontSize: dynamicLargeFontSize
            )
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.cabin(
              fontSize: dynamicBaseFontSize,
            )
          )
        )
      ),
      home: PageManager(database: database,), // Set MapScreen as the initial screen
    );
  }
}
