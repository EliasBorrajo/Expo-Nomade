import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isPopupOpen = false;
  String popupTitle = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('OpenStreetMap Example'),
      ),*/
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(46.2228401, 7.2939617),
          zoom: 12.0,
        ),
        children: [
          Stack(
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: _createMarkers(),
              ),
            ],
          ),
        ],
      ),
    );
  }



  List<Marker> _createMarkers() {
    return [
      Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(46.2228401, 7.2939617),
        builder: (ctx) => GestureDetector(
          onTap: () {
            _showMarkerPopup(context);
          },
          child: Container(
            child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 50.0,
            ),
          ),
        ),
      ),
      // Add more markers as needed
    ];
  }

  void _showMarkerPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Marker Clicked'),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9, // Customize the width
          height: MediaQuery.of(context).size.height * 0.6, // Customize the height
          child: Column(
            children: [
              Text('You clicked on the marker!'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

