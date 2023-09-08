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
import 'package:expo_nomade/firebase/Storage/FirebaseStorageUtil.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  late List<String> URLS = [];
  late List<MuseumObject> museumObjects = [];



  // TODO : SUPPRIMER - car images chargées depuis la DB et leurs objets
  Future<void> _loadImages() async
  {

    print("Chargement des images");
    String? imageUrl1 = await FirebaseStorageUtil().downloadImage(
      FirebaseStorageFolder.root,
      "wallhaven-zmo9wg.png",
    );
    print("Image 1 chargée");

    String? imageUrl2 = await FirebaseStorageUtil().downloadImage(
      FirebaseStorageFolder.root,
      "wallhaven-pkgkkp.png",
    );
    print("Image 2 chargée");


    if(mounted)
    {
      setState(() {
        URLS.add(imageUrl1 ?? ''); // Au cas ou le download echoue et renvoie null
        URLS.add(imageUrl2 ?? '');
      });
    }

    print("Toutes Images chargées");
    print("URLS : ${URLS.toString()}");
  }

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
          MuseumObject museumObject = MuseumObject(
            id: key,
            name: value['name'] as String,
            description: value['description'] as String,
            museumId: value['museumId'] as String,
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
    _loadImages();
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
                    ).createMarker(context, URLS),
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


  LatLng _calculateCentroid(List<LatLng> points) {
    // Calculate the centroid of the polygon
    // Replace this logic with your own centroid calculation
    double sumX = 0.0;
    double sumY = 0.0;

    for (var point in points) {
      sumX += point.latitude;
      sumY += point.longitude;
    }

    final centroid = LatLng(
      sumX / points.length,
      sumY / points.length,
    );

    return centroid;
  }

}

