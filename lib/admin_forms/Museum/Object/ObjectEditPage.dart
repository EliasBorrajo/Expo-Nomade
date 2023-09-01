import 'package:expo_nomade/dataModels/MuseumObject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ObjectEditPage extends StatefulWidget{
  const ObjectEditPage( {Key? key, required MuseumObject object, required FirebaseDatabase database}) : super(key: key);

  @override
  _ObjectEditPageState createState() => _ObjectEditPageState();
}

class _ObjectEditPageState extends State<ObjectEditPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('EDIT OBJECT PAGE'),
    );
  }
}
