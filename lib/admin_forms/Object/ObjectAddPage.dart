import 'dart:async';
import 'package:expo_nomade/dataModels/MuseumObject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../dataModels/Museum.dart';
import '../../dataModels/filters_tags.dart';
import '../../map/map_filters.dart';
import '../map_point_picker.dart';

class ObjectAddPage extends StatefulWidget{

  final FirebaseDatabase database;
  final Museum? sourceMuseum;

  const ObjectAddPage({super.key, required this.database, this.sourceMuseum});

  @override
  _ObjectAddPageState createState() => _ObjectAddPageState();
}

class _ObjectAddPageState extends State<ObjectAddPage> {
  // A T T R I B U T E S
  late TextEditingController _nameController;
  late TextEditingController _museumNameController;
  late TextEditingController _descriptionController;
  late LatLng selectedAddressPoint = const LatLng(0.0, 0.0);
  late LatLng displayAddressPoint = const LatLng(0.0, 0.0);
  late DatabaseReference _objectsRef;
  late List<Museum> museumsList = [];
  late List<MuseumObject>   museumObjectsFromSelectedMuseum = [];
  Map<String, List<bool>> selectedFilterState = {};

  late List<FilterTag> filters = [];
  late List<FilterTag> selectedFilters = [];


  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('filters');

  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // M E T H O D S
  @override
  void initState() {
    super.initState();
    _nameController        = TextEditingController(text: "");
    _descriptionController = TextEditingController(text: "");
    _museumNameController  = TextEditingController(text: widget.sourceMuseum?.name ?? ""); // Si le musée source est null, mettre une chaine vide

    // F I R E B A S E
    _objectsRef = widget.database.ref().child('museumObjects');
    fetchFilters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _museumNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  void updatePoint(){
    setState(() {
      displayAddressPoint = selectedAddressPoint; // Change this to your updated value
    });
  }

  Future<void> _saveChanges() async {
    selectedFilters = getSelectedFilters(filters, selectedFilterState);
    // Validation
    if (_formKey.currentState!.validate()) {
      // Create a list of filter data
      List<Map<String, dynamic>> filtersData = [];

      for (var filter in selectedFilters) {
        Map<String, dynamic> filterData = {
          "options": filter.options,
          "typeName": filter.typeName,
        };
        filtersData.add(filterData);
      }

      // Create an object with the desired structure
      Map<String, dynamic> objectData = {
        'name': _nameController.text,
        'museumId': widget.sourceMuseum?.id.toString(),
        'description': _descriptionController.text,
        'point': {
          'latitude': selectedAddressPoint.latitude.toDouble(),
          'longitude': selectedAddressPoint.longitude.toDouble(),
        },
        'filters': filtersData,
      };

      // Generate a new unique key for the museum
      await _objectsRef.push().set(objectData);

      // Return to the museum details page
      Navigator.pop(context);
    }
  }

  Future<List<MuseumObject>> _loadAllObjectsFromAMuseum(Museum museum) async
  {
    final DatabaseReference objectsRef = widget.database.ref().child('museumObjects');
    final List<MuseumObject> fetchedObjects = [];

    // Utilisez une requête pour obtenir les objets du musée ayant le même nom que museum.name
    final Query query = objectsRef.orderByChild('museumId').equalTo(museum.id);
    final DataSnapshot snapshot = await query.get();

    // Parcourez les résultats et supprimez les objets correspondants
    if (snapshot.exists) {
      final Map<dynamic, dynamic> objectsData = snapshot.value as Map<dynamic, dynamic>;

      objectsData.forEach((key, value)
      {
        final MuseumObject object = MuseumObject(
          // Remplacez ces champs par les champs réels de votre objet
          id: key,
          museumId: value['museumId'] as String,
          name: value['name'] as String,
          description: value['description'] as String,
          point: LatLng(
            // Vériier que les valeurs sont bien des doubles, firebase peut les convertir en int parfois
            (value['point']['latitude'] as num).toDouble(),
            (value['point']['longitude'] as num).toDouble(),
          ),
        );

        fetchedObjects.add(object);
      });
    }

    if (mounted)
    {
      setState(() {
        museumObjectsFromSelectedMuseum = fetchedObjects;
      });
    }

    return fetchedObjects;
  }



  // V A L I D A T I O N S
  String? _validateDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Veuillez entrer une description';
    }
    return null;
  }

  String? _validateObjectName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Veuillez entrer un nom';
    }

    _loadAllObjectsFromAMuseum(widget.sourceMuseum!) ;

    // Parcourir la liste des objets du musée sélectionné
    for (var object in museumObjectsFromSelectedMuseum) {
      if (object.name.toLowerCase() == name.toLowerCase()) {
        return 'Ce nom d\'objet existe déjà dans ce musée';
      }
    }


    return null;
  }

  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un objet')),
      body: Form(
        key: _formKey,  // Permet de valider le formulaire et de sauvegarder les données dans les champs du formulaire
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Écran suffisamment large, affichez les filtres à droite
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nom de l\'objet'),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Epée de Charlemagne',
                              ),
                              validator: _validateObjectName,
                            ),
                            const SizedBox(height: 16),

                            const Text('Description'),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Cette épée a été utilisée par Charlemagne lors de la bataille de Poitiers',
                              ),
                              validator: _validateDescription,
                            ),
                            const SizedBox(height: 16),

                            const Text('Musée'),
                            TextFormField(
                              readOnly: true,
                              enabled: false, // Prevents programmatic changes
                              decoration: InputDecoration(
                                labelText: widget.sourceMuseum?.name,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              child: const Text('Sélectionner l\'adresse'),
                              onPressed: () async {
                                selectedAddressPoint = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 2)),
                                );
                                updatePoint();
                              },
                            ),
                            Text('Point sélectionné: ${displayAddressPoint.latitude.toStringAsFixed(2)}, ${displayAddressPoint.longitude.toStringAsFixed(2)}'),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _saveChanges,
                              child: const Text('Enregistrer'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FiltersWindow(database: widget.database, selectedFilterState: selectedFilterState),
                    ],
                  ),
                ),
              );
            } else {
              // Écran étroit, affichez les filtres en dessous
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nom de l\'objet'),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Epée de Charlemagne',
                        ),
                        validator: _validateObjectName,
                      ),
                      const SizedBox(height: 16),

                      const Text('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Cette épée a été utilisée par Charlemagne lors de la bataille de Poitiers',
                        ),
                        validator: _validateDescription,
                      ),
                      const SizedBox(height: 16),

                      const Text('Musée'),
                      TextFormField(
                        readOnly: true,
                        enabled: false, // Prevents programmatic changes
                        decoration: InputDecoration(
                          labelText: widget.sourceMuseum?.name,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        child: const Text('Sélectionner l\'adresse'),
                        onPressed: () async {
                          selectedAddressPoint = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 2)),
                          );
                          updatePoint();
                        },
                      ),
                      Text('Point sélectionné: ${displayAddressPoint.latitude.toStringAsFixed(2)}, ${displayAddressPoint.longitude.toStringAsFixed(2)}'),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('Enregistrer'),
                      ),
                      FiltersWindow(database: widget.database, selectedFilterState: selectedFilterState),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void fetchFilters() async {
    try {
      DatabaseEvent event = await _database.once();
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic,dynamic>?;

      if (data != null) {
        List<FilterTag> fetchedFilters = data.entries
            .map((entry) {
          String filterId = entry.key;
          Map<String, dynamic> filterData = Map<String, dynamic>.from(
              entry.value);
          return FilterTag(
            id: filterId,
            typeName: filterData['typeName'] ?? '',
            options: List<String>.from(filterData['options'] ?? []),
          );
        })
            .toList();


        if(selectedFilterState.isEmpty) {
          for (var filter in fetchedFilters) {
            selectedFilterState[filter.typeName] = List.filled(filter.options.length, false);
          }
        }

        setState(() {
          filters = fetchedFilters;
        });
      }
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  List<FilterTag> getSelectedFilters(List<FilterTag> filterTags, Map<String, List<bool>> selectedFilterState) {
    Map<String, FilterTag> groupedFilters = {};

    for (var filter in filterTags) {
      var typeName = filter.typeName;
      var selections = selectedFilterState[typeName];

      if (selections != null) {
        for (var i = 0; i < selections.length; i++) {
          if (selections[i]) {
            var option = filter.options[i];

            if (groupedFilters.containsKey(typeName)) {
              groupedFilters[typeName]!.options.add(option);
            } else {
              var selectedFilter = FilterTag(
                id: filter.id, // Assuming FilterTag has an id property
                typeName: typeName,
                options: [option],
              );
              groupedFilters[typeName] = selectedFilter;
            }
          }
        }
      }
    }    return groupedFilters.values.toList();
  }
}