import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'editFilterPage.dart';

class AddFilterPage extends StatefulWidget {
  final FirebaseDatabase database;

  const AddFilterPage({super.key, required this.database});

  @override
  _AddFilterPageState createState() => _AddFilterPageState();
}

class _AddFilterPageState extends State<AddFilterPage> {
  final TextEditingController typeNameTextController = TextEditingController();
  List<OptionModel> optionControllers = [];
  final TextEditingController newOptionController = TextEditingController();

  void _removeOption(int index) {
    setState(() {
      optionControllers.removeAt(index);
    });
  }

  void _addNewOption() {
    setState(() {
      optionControllers.add(OptionModel(TextEditingController(text: newOptionController.text), DateTime.now().toString()));
      newOptionController.clear();
    });
  }

  void _addFilterToDatabase() async {
    final typeNameText = typeNameTextController.text.trim();

    if (typeNameText.isEmpty || optionControllers.isEmpty) {
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

      // Supprimer les options vides
      optionControllers.removeWhere((option) => option.controller.text.trim().isEmpty);

      List<String> updatedOptions = optionControllers.map((controller) => controller.controller.text.trim()).toList();

      Map<String, dynamic> filterToUpload = {
        'typeName': typeNameText,
        'options': { for (var item in updatedOptions) updatedOptions.indexOf(item).toString() : item },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Ajouter un filtre')),
        body: Form(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nom du type:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(controller: typeNameTextController),
                    const SizedBox(height: 16),
                    const Text(
                      'Ajouter une nouvelle option:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: newOptionController,
                            decoration: const InputDecoration(labelText: 'Nouvelle Option'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () {
                            _addNewOption();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Options existantes:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: optionControllers.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: optionControllers[index].controller,
                                  decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: Colors.grey), // Icône en gris
                                onPressed: () {
                                  _removeOption(index);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _addFilterToDatabase();
                      },
                      child: const Text('Ajouter le filtre'),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}
