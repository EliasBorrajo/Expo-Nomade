import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/filters_tags.dart';

class EditFilterPage extends StatefulWidget {
  final FirebaseDatabase database;
  final FilterTag filter;

  const EditFilterPage({super.key, required this.database, required this.filter});

  @override
  _EditFilterPageState createState() => _EditFilterPageState();
}

class _EditFilterPageState extends State<EditFilterPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}