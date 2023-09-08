import 'dart:async';

import 'package:expo_nomade/dataModels/MuseumObject.dart';
import 'package:expo_nomade/firebase/Storage/ImagesMedia.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../dataModels/Museum.dart';
import '../../firebase/Storage/FirebaseStorageUtil.dart';
import '../map_point_picker.dart';


class ObjectEditPage extends StatefulWidget{
  final MuseumObject object;
  final FirebaseDatabase database;
  final Museum sourceMuseum;

  const ObjectEditPage( {Key? key, required this.object, required this.database, required this.sourceMuseum}) : super(key: key);

  @override
  _ObjectEditPageState createState() => _ObjectEditPageState();
}

class _ObjectEditPageState extends State<ObjectEditPage> {
  // A T T R I B U T E S
  late String _initialName;
  late Museum _initialSelectedMuseum;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _museumNameController;
  late LatLng selectedAddressPoint = widget.object.point;
  late LatLng displayAddressPoint  = widget.object.point;
  late DatabaseReference _objectsRef;
  late List<Museum> museumsList = [];
  late Museum _selectedMuseum = Museum(id: '0', name: 'No museum selected',website: 'No website', address: const LatLng(0.0, 0.0));
  late List<MuseumObject>   museumObjectsFromSelectedMuseum = [];   // Serves for the validation of the object name, avoid having two objects with the same name in the same museum
  late StreamSubscription<DatabaseEvent> _museumsSubscription;


  // form Key allows to validate the form and save the data in the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // M E T H O D S
  void initState() {
    super.initState();
    _nameController        = TextEditingController(text: widget.object.name);
    _descriptionController = TextEditingController(text: widget.object.description);
    _museumNameController  = TextEditingController(text: widget.sourceMuseum?.name ?? ""); // Si le musée source est null, mettre une chaine vide

    // Stocker valeurs initiales avant changement, pour pouvoir les comparer avec les nouvelles valeurs lors de la validation
    _initialName = widget.object.name;
    _initialSelectedMuseum = widget.sourceMuseum;

    // F I R E B A S E
    _objectsRef = widget.database.ref().child('museumObjects');

    print('MUSEUM SOURCE IS : ${widget.sourceMuseum?.name}');
    _loadMuseumsFromFirebaseAndListen()
        .then((_) => { _loadAllObjectsFromAMuseum(_selectedMuseum) }) // Permet de précharger la liste,
        .whenComplete(() => print('Museums loaded'));
  }

  Future<void> _loadMuseumsFromFirebaseAndListen() async
  {
    DatabaseReference museumsRef = widget.database.ref().child('museums');

    // Configurer un écouteur en temps réel pour les mises à jour dans la Firebase
    _museumsSubscription = museumsRef.onValue.listen((DatabaseEvent event)
    {
      if (event.snapshot.value != null)
      {
        // 1) Get museums from firebase and add them to the list
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic,dynamic>;

        // 2) Create a sorted list of museums and fill it with the museums from firebase
        readDataMuseumToSortedList(museumsData, updatedMuseums);

        // 3) Update the museums list in the widget tree, and autmaticaly update the dropdown list of museums with the precedent museum if it exists
        // Vérifier le widget tree est toujours monté avant de mettre à jour l'état
        setStateAndDropDownList(updatedMuseums);

      }
    });

  }

  Future<List<MuseumObject>> _loadAllObjectsFromAMuseum(Museum museum) async
  {
    final DatabaseReference objectsRef = widget.database.ref().child('museumObjects');
    final List<MuseumObject> fetchedObjects = [];

    // Utilisez une requête pour obtenir les objets du musée ayant le même nom que museum.name
    final Query query = objectsRef.orderByChild('museumId').equalTo(museum.id);
    final DataSnapshot snapshot = await query.get();

    print('SNAPOSHOT : $snapshot AND ${snapshot.value}');

    // Parcourez les résultats et supprimez les objets correspondants
    if (snapshot.exists) {
      final Map<dynamic, dynamic> objectsData = snapshot.value as Map<dynamic, dynamic>;

      objectsData.forEach((key, value)
      {
        print('CHARGER IMAGES DE FIREBASE : ${value['images']}');
        List<String> images = [];
        if (value['images'] != null) {
          List<dynamic> imagesData = value['images'] as List<dynamic>;
          for (var image in imagesData) {
            if( image != null &&
                image is String){
              images.add(image);

              print('IMAGE IN OBJECT ADDING : $image');

            }
          }
        }



        final MuseumObject object = MuseumObject(
          // Remplacez ces champs par les champs réels de votre objet
          id: key,
          museumId: value['museumId'] as String,
          name: value['name'] as String,
          description: value['description'] as String,
          images: images,
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

    // Well formated Print of the object
    for(var object in fetchedObjects)
    {
      print('OBJECT : \n-${object.name}\n-${object.description}\n-${object.point.latitude}\n-${object.point.longitude}');
      for(var image in object.images ?? [])
      {
        print('IMAGE : $image');
      }
    }

    return fetchedObjects;
  }

  void readDataMuseumToSortedList(Map<dynamic, dynamic> museumsData, List<Museum> updatedMuseums) {
    museumsData.forEach((key, value)
    {
      // M U S E U M S
      // 1) Récupérer les musées et y ajouter les objets de l'étape 1
      Museum museum = Museum(
        id: key,
        name: value['name'] as String,
        address: LatLng(
          // Vériier que les valeurs sont bien des doubles, firebase peut les convertir en int parfois
          (value['address']['latitude'] as num).toDouble(),
          (value['address']['longitude'] as num).toDouble(),
        ),
        website: value['website'] as String,
      );

      // 2) Ajouter le musée à la liste des musées
      updatedMuseums.add(museum);


    });

    museumsList.sort((a, b) => a.name.compareTo(b.name));

  }

  void setStateAndDropDownList(List<Museum> updatedMuseums) {
    if (mounted)
    {
      setState(()
      {
        // 1) Affection de la liste des musées à la liste des musées de la page en local
        museumsList = updatedMuseums;

        // 2) Si le musée source est non-null, mettre le musée source dans la dropdown list comme musée sélectionné
        if(widget.sourceMuseum != null)
        {
          print('Museum source is not null');
          // Verifier si un des musées de la liste est le musée source
          // Si oui, mettre ce musée de la liste comme musée sélectionné
          // Sinon, mettre le premier musée de la liste comme musée sélectionné
          bool museumFound = false;

          for (var museum in museumsList)
          {
            if (museum.id == widget.sourceMuseum?.id)
            {
              print('Museum source found in list');
              _selectedMuseum = museum;
              museumFound = true;
              break;
            }
          }

          if (!museumFound) {
            print('Museum source not found in list');
            _selectedMuseum = museumsList[0]; // first museum from list by default
          }

          print('Museums list updated and selected museum is: ${_selectedMuseum.name}');

        }
        else
        {
          print('Museum source is null');
          _selectedMuseum = museumsList[0]; // first museum from list by default
        }

        // 3) Charger la liste des objets du musée sélectionné
        _loadAllObjectsFromAMuseum(_selectedMuseum);

      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _museumNameController.dispose();
    _museumsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _saveChanges() async{
    // Validation
    if (_formKey.currentState!.validate()) {


      // MAJ LOCAL - Mettre à jour les propriétés du musée avec les nouvelles valeurs en local
      widget.object.name        = _nameController.text;
      widget.object.description = _descriptionController.text;
      // widget.object.point = LatLng(selectedAddressPoint.latitude.toDouble(), selectedAddressPoint.longitude.toDouble());

      // MAJ FIREBASE
      await _objectsRef.child(widget.object.id).update({
        'name': widget.object.name,
        'museumId': _selectedMuseum.id,
        'description': widget.object.description,
        'point':{
          'latitude':  selectedAddressPoint.latitude .toDouble() == 0.0 ? widget.object.point.latitude.toDouble()  : selectedAddressPoint.latitude.toDouble(),
          'longitude': selectedAddressPoint.longitude.toDouble() == 0.0 ? widget.object.point.longitude.toDouble() : selectedAddressPoint.longitude.toDouble(),
        }
      }
      ).whenComplete(() => print('Object updated : ${widget.object.name}'));

      setState(() {
        widget.object.name        = _nameController.text;
        widget.object.description = _descriptionController.text;
        // widget.object.point = LatLng(selectedAddressPoint.latitude.toDouble(), selectedAddressPoint.longitude.toDouble());
      });

      // Retourner à la page de détails du musée
      Navigator.pop(context);
    }
  }

  void updatePoint(){
    setState(() {
      displayAddressPoint = selectedAddressPoint; // Change this to your updated value
    });
  }

  // V A L I D A T I O N S
  // Verification que la description n'est pas vide
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

    return null;
  }

  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {

    final firebaseStorageUtil = FirebaseStorageUtil();

    return Scaffold(
      appBar: AppBar(title: Text('Editer l\'objet ${widget.object.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nom du de l\'objet'),
                TextFormField(controller: _nameController, validator: _validateObjectName),
                const SizedBox(height: 16),


                const Text('Description'),
                TextFormField(controller: _descriptionController, validator: _validateDescription),
                const SizedBox(height: 16),


                DropdownButtonFormField<Museum>(
                  value: _selectedMuseum ?? null,
                  onChanged: (Museum? newValue)
                  {
                    setState(() {
                      _selectedMuseum = newValue!;
                      _museumNameController.text = newValue?.name ?? 'No museum selected';
                      _loadAllObjectsFromAMuseum(newValue); // Chaque fois que on change de musée, on recharge la liste des objets du musée
                    });
                  },
                  items: museumsList.map((Museum museum)
                  {
                    return DropdownMenuItem<Museum>(
                      value: museum,
                      child: Text(museum.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner un musée auquel attribuer l\'objet',
                  ),
                ),
                const SizedBox(height: 16),


                ElevatedButton(
                    onPressed: () async {
                      selectedAddressPoint = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapPointPicker(pickerType: 2)),
                      );
                      updatePoint();
                      print(selectedAddressPoint);
                    },
                    child: const Text('Modifier l\'adresse')
                ),


                selectedAddressPoint == const LatLng(0.0, 0.0) ?
                Text('Point selectionné: ${widget.object.point.latitude.toStringAsFixed(2)}, ${widget.object.point.longitude.toStringAsFixed(2)}') :
                Text('Point selectionné: ${displayAddressPoint.latitude.toStringAsFixed(2)}, ${displayAddressPoint.longitude.toStringAsFixed(2)}'),
                const SizedBox(height: 16),


                ElevatedButton(
                    onPressed: () async {

                      var urlNewImage = await firebaseStorageUtil
                                          .uploadImageFromGallery(FirebaseStorageFolder.objects);
                      if(urlNewImage != null) {

                        // 1) MAJ locale
                        if(mounted)
                          {
                            setState(() {
                              widget.object.images?.add(urlNewImage);
                            });
                          }

                        // 2) MAJ firebase
                        await _objectsRef.child(widget.object.id).update({
                          'images': widget.object.images,
                        }
                        ).whenComplete(() => print('Object updated : ${widget.object.name}'));


                      }
                    },
                    child: const Text('Ajouter une image')),
                const SizedBox(height: 16),

                ImageGallery(
                    imageUrls: widget.object.images ?? [],
                    isEditMode: true,
                    onDeleteOfImage: (int indexImage) async{

                      // 2) MAJ firebase
                      try {
                        await widget.database.ref()
                            .child('museumObjects')
                            .child(widget.object.id)
                            .child('images/$indexImage')
                            .remove()
                            .whenComplete(() => print("DELETE OBJECT SUCCESS"))
                            .catchError((e) => print("DELETE OBJECT ERROR while deleting : $e"));
                      } catch(e) {
                        print("DELETE IMAGE ERROR: $e");
                      }

                    }
                ),
                const SizedBox(height: 16),



                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('Enregistrer'),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}
