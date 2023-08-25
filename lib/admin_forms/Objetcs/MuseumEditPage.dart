import 'package:flutter/material.dart';
import '../../dataModels/Museum.dart';

class MuseumEditPage extends StatefulWidget {
  final Museum museum;

  const MuseumEditPage({Key? key, required this.museum}) : super(key: key);

  @override
  _MuseumEditPageState createState() => _MuseumEditPageState();
}

class _MuseumEditPageState extends State<MuseumEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.museum.name);
    _addressController = TextEditingController(text: widget.museum.address);
    _websiteController = TextEditingController(text: widget.museum.website);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditer ${widget.museum.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom du musée'),
            TextFormField(controller: _nameController),
            SizedBox(height: 16),
            Text('Adresse'),
            TextFormField(controller: _addressController),
            SizedBox(height: 16),
            Text('Site web'),
            TextFormField(controller: _websiteController),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Sauvegarder les modifications et retourner à la page de détails du musée
              },
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
