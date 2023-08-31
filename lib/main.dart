import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';
import 'firebase/firebase_options.dart';
import 'map/map_screen.dart';
import 'map/map_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<LatLng> test = [
    LatLng(46.23133558251062, 7.275204265601556),
    LatLng(46.23954129676883, 7.287402512905699),
    LatLng(46.216446100834, 7.295343971067559),
    LatLng(46.2152203011698, 7.279190562209763)
  ];

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Map Example',
      home: MapScreen(points: test,), // Set MapScreen as the initial screen
    );
  }
}
