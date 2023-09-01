import 'package:expo_nomade/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'admin_forms/forms.dart';
import 'map/map_screen.dart';


class PageManager extends StatefulWidget {
  const PageManager({super.key});

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
      /*appBar: AppBar( // TODO : REMOVE ?
        // title: Text(_showMap ? 'Map Page' : 'Questionnaire Page'),
      ),*/
      body: _showMap ? MapScreen(points: test,) : QuizScreen(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _switchPages,
            tooltip: _showMap ? 'Go to Questionnaire' : 'Go to Map',
            child: Icon(_showMap ? Icons.question_answer : Icons.map),
            elevation: 8, // Add a slight elevation
            backgroundColor: Colors.blue, // Change button color
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminForms()),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 8, // Add a slight elevation
            ),
            child: const Text(
              'Admin Login',
              style: TextStyle(fontSize: 16),
            ),
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