import 'package:expo_nomade/quiz/quiz_screen.dart';
import 'package:expo_nomade/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dataModels/Museum.dart';
import 'map/map_screen.dart';

class PageManager extends StatefulWidget {
  final FirebaseDatabase database;

  const PageManager({Key? key, required this.database}) : super(key: key);

  @override
  _PageManagerState createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  Timer? _inactivityTimer;
  bool _showMap = true;

  List<Museum> museums = [];

  @override
  void initState() {
    super.initState();
    _loadMuseumsFromFirebaseAndListen();
    _startInactivityTimer();
  }

  void _loadMuseumsFromFirebaseAndListen() {
    DatabaseReference museumsRef = widget.database.reference().child('museums');
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
      body: _showMap
          ? MapScreen(points: _getLatLngPoints(), database: widget.database)
          : QuizScreen(database: widget.database),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'switchPage',
            onPressed: _switchPages,
            tooltip: _showMap ? 'Go to Questionnaire' : 'Go to Map',
            elevation: 8,
            label: Text(_showMap ? 'Quiz' : 'Map', style: const TextStyle(fontSize: 25)),
            icon: Icon(_showMap ? Icons.question_answer : Icons.map),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'adminForms',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
            label: const Text('Admin', style: TextStyle(fontSize: 15)),
            icon: const Icon(Icons.admin_panel_settings),
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
    _cancelInactivityTimer();
    super.dispose();
  }
}
