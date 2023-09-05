import 'package:expo_nomade/quiz/quiz_screen.dart';
import 'package:expo_nomade/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'admin_forms/forms.dart';
import 'map/map_screen.dart';


class PageManager extends StatefulWidget {

  final FirebaseDatabase database;

  const PageManager({super.key, required this.database});
  @override
  _PageManagerState createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {

  static const List<LatLng> test = [
    LatLng(46.23133558251062, 7.275204265601556),
    LatLng(46.23954129676883, 7.287402512905699),
    LatLng(46.216446100834, 7.295343971067559),
    LatLng(46.2152203011698, 7.279190562209763)
  ];

  Timer? _inactivityTimer;
  bool _showMap = true;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    const inactivityDuration = Duration(minutes: 1);

    // Cancel any existing timer before starting a new one
    _cancelInactivityTimer();

    _inactivityTimer = Timer(inactivityDuration, () {
      if (!_showMap) {
        setState(() {
          _showMap = true;
        });
      }
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
  }

  void _switchPages() {
    setState(() {
      _showMap = !_showMap;
    });
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _cancelInactivityTimer();
    _startInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showMap ? MapScreen(points: test, database: widget.database) : QuizScreen(database: widget.database),
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
            icon: Icon(_showMap ? Icons.question_answer : Icons.map), // Change button color
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'adminForms',
            onPressed: () {
              Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => SignInPage()),
                 MaterialPageRoute(builder: (context) => const AdminForms()),
              );
            },
            label: const Text('Admin'),
            icon: const Icon(Icons.admin_panel_settings),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cancelInactivityTimer();
    super.dispose();
  }
}