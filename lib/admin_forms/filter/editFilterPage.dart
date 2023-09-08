import 'dart:async';

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

  // TODO si j'update une option je dois aussi update dans les objets des musées
  void _updateFilterInDatabase() async {
    try {
      DatabaseReference optionsRef = widget.database.ref().child('filters').child(widget.filter.id);
      DatabaseReference objectsRef = widget.database.ref().child('museumObjects');

      // Supprimer les options vides
      optionControllers.removeWhere((option) => option.controller.text.trim().isEmpty);

      List<String> updatedOptions = optionControllers.map((controller) => controller.controller.text.trim()).toList();

      Map<String, dynamic> updatedFilter = {
        'typeName': typeNameTextController.text.trim(),
        'options': Map.fromIterable(updatedOptions, key: (item) => updatedOptions.indexOf(item).toString(), value: (item) => item),
      };

      await optionsRef.update(updatedFilter);

      DatabaseEvent event = await objectsRef.once();
      DataSnapshot objectsSnapshot =  event.snapshot;

      // Obtenez tous les objets de musée
      if (objectsSnapshot.value != null) {
        Map<dynamic, dynamic> museumObjects = objectsSnapshot.value as Map<dynamic, dynamic>;

        // Parcourez tous les objets de musée
        museumObjects.forEach((key, value) {
          Map<String, dynamic> museumObject = Map<String, dynamic>.from(value);

          // Parcourir les filtres de l'objet de musée
          if (museumObject.containsKey('filters')) {
            List<dynamic> filters = museumObject['filters'];
            for (int i = 0; i < filters.length; i++) {
              Map<String, dynamic> filter = Map<String, dynamic>.from(filters[i]);
              String typeName = filter['typeName'];

              // Si le filtre utilise le type que vous avez modifié, mettez à jour les options du filtre dans cet objet de musée
              if (typeName == widget.filter.typeName) {
                filter['options'] = updatedOptions.where((option) =>
                filter['options'].contains(option) || optionControllers.any((controller) =>
                controller.controller.text.trim() == option)).toList();

                filters[i] = filter;
              }
            }

            // Mettre à jour l'objet de musée dans la base de données
            //museumObject['filters'] = filters;
            objectsRef.child(key).update({'filters': filters});
          }
        });
      }

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
