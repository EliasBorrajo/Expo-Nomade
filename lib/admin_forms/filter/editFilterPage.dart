import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/filters_tags.dart';

class EditFilterPage extends StatefulWidget {
  final FirebaseDatabase database;
  final FilterTag filter;

  const EditFilterPage({Key? key, required this.database, required this.filter}) : super(key: key);

  @override
  _EditFilterPageState createState() => _EditFilterPageState();
}

class OptionModel {
  TextEditingController controller;
  String key;
  OptionModel(this.controller, this.key);
}

class _EditFilterPageState extends State<EditFilterPage> {
  final TextEditingController typeNameTextController = TextEditingController();
  List<OptionModel> optionControllers = [];
  final TextEditingController newOptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    typeNameTextController.text = widget.filter.typeName;
    optionControllers = widget.filter.options.asMap().entries.map((entry) {
      return OptionModel(
        TextEditingController(text: entry.value),
        entry.key.toString(),
      );
    }).toList();
  }

  void _updateFilterInDatabase() async {
    try {
      DatabaseReference optionsRef = widget.database.ref().child('filters').child(widget.filter.id);

      // Supprimer les options vides (facultatif)
      optionControllers.removeWhere((option) => option.controller.text.trim().isEmpty);

      List<String> updatedOptions = optionControllers.map((controller) => controller.controller.text.trim()).toList();

      Map<String, dynamic> updatedFilter = {
        'typeName': typeNameTextController.text.trim(),
        'options': Map.fromIterable(updatedOptions, key: (item) => updatedOptions.indexOf(item).toString(), value: (item) => item),
      };

      await optionsRef.update(updatedFilter);

      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le filtre a été édité avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error updating filter: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'édition du filtre.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Éditer le filtre')
        ),
        body: Form(
            child: SingleChildScrollView( // Wrap the entire content in a SingleChildScrollView
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
                            decoration: InputDecoration(labelText: 'Nouvelle Option'),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
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
                    ListView.builder(
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
                              icon: Icon(Icons.delete, color: Colors.grey), // Icône en gris
                              onPressed: () {
                                _removeOption(index);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _updateFilterInDatabase();
                      },
                      child: const Text('Mettre à jour le filtre'),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}
