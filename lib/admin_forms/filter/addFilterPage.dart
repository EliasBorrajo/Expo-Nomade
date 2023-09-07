import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddFilterPage extends StatefulWidget {
  final FirebaseDatabase database;

  const AddFilterPage({super.key, required this.database});

  @override
  _AddFilterPageState createState() => _AddFilterPageState();
}

class _AddFilterPageState extends State<AddFilterPage> {
  final TextEditingController nameTypeTextController = TextEditingController();
  final TextEditingController optionController = TextEditingController();
  List<String> optionsList = [];

  @override
  Widget build(BuildContext context) {
    void _addOptionToList() {
      final option = optionController.text.trim();
      if (option.isNotEmpty) {
        setState(() {
          optionsList.add(option);
          optionController.clear();
        });
      }
    }

    void _addFilterToDatabase() async {
      final typeNameText = nameTypeTextController.text.trim();

      if (typeNameText.isEmpty || optionsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout, un ou plusieurs champs invalides.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      try {
        DatabaseReference filtersRef = widget.database.ref().child('filters');
        DatabaseReference newFilterRef = filtersRef.push();
        Map<String, dynamic> filterToUpload = {
          'typeName': typeNameText,
          'options': Map.fromIterable(optionsList, key: (item) => optionsList.indexOf(item).toString(), value: (item) => item),
        };
        await newFilterRef.set(filterToUpload);

        if (!context.mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le filtre a été ajouté avec succès.'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        print('Error adding filter: $error');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de l\'ajout du filtre.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un filtre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nom du type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: nameTypeTextController),
            const SizedBox(height: 16),
            const Text(
              'Options:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: optionController),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _addOptionToList();
              },
              child: const Text('Ajouter une option'),
            ),
            const SizedBox(height: 16),
            Text(
              'Options ajoutées:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: optionsList.map((option) {
                return Text(option);
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addFilterToDatabase();
              },
              child: const Text('Ajouter le filtre'),
            ),
          ],
        ),
      ),
    );
  }
}
