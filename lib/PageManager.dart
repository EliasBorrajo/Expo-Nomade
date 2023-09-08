import 'package:expo_nomade/admin_forms/forms.dart';
import 'package:expo_nomade/quiz/quiz_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dataModels/Museum.dart';
import 'map/map_screen.dart';


class PageManager extends StatefulWidget {

  final FirebaseDatabase database;

  const PageManager({super.key, required this.database});
  @override
  _PageManagerState createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  Timer? inactivityTimer;
  int inactivityDuration = 60;
  bool _showMap = true;

  List<Museum> museums = [];

  @override
  void initState() {
    super.initState();
    _loadMuseumsFromFirebaseAndListen();
  }

  void _loadMuseumsFromFirebaseAndListen() {
    DatabaseReference museumsRef = widget.database.ref().child('museums');
    museumsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic, dynamic>;
        museumsData.forEach((key, value) {
          // Check if the values are non-zero
          double latitude = (value['address']['latitude'] as num).toDouble();
          double longitude = (value['address']['longitude'] as num).toDouble();
          if (latitude != 0.0 && longitude != 0.0) {
            Museum museum = Museum(
              id: key,
              name: value['name'] as String,
              address: LatLng(latitude, longitude),
              website: value['website'] as String,
            );
            updatedMuseums.add(museum);
          }
        });

        setState(() {
          museums = updatedMuseums;
        });
      }
    });
  }

  void _switchPages() {
    setState(() {
      _showMap = !_showMap;
    });
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {

    if (inactivityTimer != null || _showMap == true) {
      print("TIMER CANCEL _________________________________");
      inactivityTimer!.cancel();
    }

    if(!_showMap) {
      print("TIMER START ///////////////////////////////////////////////");
      inactivityTimer = Timer(Duration(seconds: inactivityDuration), () {
        _switchPages();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: _showMap
              ? MapScreen(points: _getLatLngPoints(), database: widget.database)
              : QuizScreen(database: widget.database, resetInactivityTimer: _resetInactivityTimer),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'switchPage',
                onPressed: _switchPages,
                tooltip: _showMap ? 'Go to Questionnaire' : 'Go to Map',
                elevation: 8, // Add a slight elevation
                label: Text(_showMap ? 'Quiz' : 'Map'), // Utilisation de label pour le texte
                icon: Icon(_showMap ? Icons.question_answer_rounded : Icons.map_rounded), // Change button color
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: 'signInAdmin',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => /*SignInPage()*/const AdminForms()),
                  );
                },
                label: const Text('Admin'),
                icon: const Icon(Icons.admin_panel_settings_rounded),
              ),
            ],
          ),
    );
  }

  List<LatLng> _getLatLngPoints() {
    return museums
        .map((museum) => LatLng(
      museum.address.latitude,
      museum.address.longitude,
    ))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}