import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddFilterPage extends StatefulWidget {
  final FirebaseDatabase database;

  const AddFilterPage({super.key, required this.database});

  @override
  _AddFilterPageState createState() => _AddFilterPageState();
}

class _AddFilterPageState extends State<AddFilterPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}