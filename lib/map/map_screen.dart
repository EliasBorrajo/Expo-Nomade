import 'package:expo_nomade/map/custom-polygon-layer.dart';
import 'package:expo_nomade/map/map_marker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../dataModels/Migration.dart';
import '../dataModels/Museum.dart';
import '../dataModels/MuseumObject.dart';
import '../firebase/firebase_crud.dart';
import 'map_filters.dart';

class MapScreen extends StatefulWidget {

  final FirebaseDatabase database;
  const MapScreen({super.key, required this.points, required this.database});

  final List<LatLng> points;


  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isPopupOpen = false;
  String popupTitle = '';
  late List<Migration> migrations = [];
  bool isFiltersWindowOpen = false;
  Map<String, List<bool>> selectedFilterState = {};
  late List<Museum> museums = [];
  late List<String> urls = [];
  late List<MuseumObject> museumObjects = [];



  void _loadMuseumsFromFirebaseAndListen() {
    DatabaseReference museumsRef = widget.database.ref().child('museums');
    museumsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        List<Museum> updatedMuseums = [];
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic, dynamic>;
        museumsData.forEach((key, value) {
          double latitude = (value['address']['latitude'] as num).toDouble();
          double longitude = (value['address']['longitude'] as num).toDouble();
          if (latitude != 0.0 && longitude != 0.0) {
            Museum museum = Museum(
              id: key,
              name: value['name'] as String,
              address: LatLng(latitude, longitude),
              website: value['website'] as String,
            );
            updatedMuseums.add(museum);
          }
        });

        setState(() {
          museums = updatedMuseums;
        });
      }
    });
  }

  void _toggleFiltersWindow() {
    setState(() {
      isFiltersWindowOpen = !isFiltersWindowOpen;
    });
  }

  void openPopup(String title) {
    setState(() {
      isPopupOpen = true;
      popupTitle = title;
    });
  }

  void closePopup() {
    setState(() {
      isPopupOpen = false;
      popupTitle = '';
    });
  }


  void _loadMuseumObjectsFromFirebaseAndListen() {
    DatabaseReference museumObjectsRef = widget.database.ref().child('museumObjects');
    museumObjectsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        List<MuseumObject> updatedMuseumObjects = [];
        Map<dynamic, dynamic> objectsData = event.snapshot.value as Map<dynamic, dynamic>;
        objectsData.forEach((key, value) {

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

          MuseumObject museumObject = MuseumObject(
            id: key,
            name: value['name'] as String,
            description: value['description'] as String,
            museumId: value['museumId'] as String,
            images: images,
            point: LatLng(
              (value['point']['latitude'] as num).toDouble(),
              (value['point']['longitude'] as num).toDouble(),
            ),
          );
          updatedMuseumObjects.add(museumObject);
        });

        if (mounted) {
          setState(() {
            museumObjects = updatedMuseumObjects;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMuseumObjectsFromFirebaseAndListen();
    _loadMuseumsFromFirebaseAndListen();
    final firebaseUtils = FirebaseUtils(widget.database);
    firebaseUtils.loadMigrationsAndListen((updatedMigrations) {
      if(mounted){
        setState(() {
          migrations = updatedMigrations;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: const LatLng(46.2228401, 7.2939617),
              zoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              CustomPolygonLayer(migrations: migrations),
              MarkerLayer(
                key: const Key('Object marker'),
                markers: museumObjects.isNotEmpty
                    ? [
                  for (var museumObject in museumObjects)
                    MapMarker(
                      position: museumObject.point,
                      markerPopupData: [
                        MapEntry('Nom', museumObject.name),
                        MapEntry('Description', museumObject.description),
                      ],
                      isMuseum: false
                    ).createMarker(context, museumObject.images),
                ]
                    : [],
              ),

              // Markers for Museums
              MarkerLayer(
                key: const Key('Museum marker'),
                markers: museums.isNotEmpty
                    ? [
                  for (var museum in museums)
                    MapMarker(
                      position: museum.address,
                      markerPopupData: [
                        MapEntry('Nom', museum.name),
                        MapEntry('Site web', museum.website),
                      ],
                      isMuseum : true,
                    ).createMarker(context, null),
                ]
                    : [],
              ),
            ],
          ),
          if (isFiltersWindowOpen)
            Positioned(
              top: 50.0,
              child: FiltersWindow(database: widget.database, selectedFilterState: selectedFilterState),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _toggleFiltersWindow();
        },
        label: const Text('Filtres'),
        icon: const Icon(Icons.filter_list_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

}

