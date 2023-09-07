import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../dataModels/Migration.dart';

class FirebaseUtils {
  final FirebaseDatabase database;

  FirebaseUtils(this.database);

  Future<void> loadMigrationsAndListen(Function(List<Migration>) onDataReceived) async {
    DatabaseReference migrationsRef = database.ref().child('migrations');
    migrationsRef.onValue.listen((DatabaseEvent event) {
      List<Migration> updatedMigrations = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> migrationsData =
        event.snapshot.value as Map<dynamic, dynamic>;
        migrationsData.forEach((key, value) {
          List<MigrationSource>? polygons = [];
          if (value['polygons'] != null) {
            List<dynamic> polygonsData = value['polygons'] as List<dynamic>;
            for (var polyValue in polygonsData) {
              List<dynamic> pointsData = polyValue['points'] as List<dynamic>;
              List<LatLng> points = [];

              for (var point in pointsData) {
                points.add(
                  LatLng(
                    point['latitude'] as double,
                    point['longitude'] as double,
                  ),
                );
              }
              MigrationSource source = MigrationSource(
                id: key.toString(),
                points: points,
                name: polyValue['name']! as String,
              );
              polygons.add(source);
            }
          }
          Migration migration = Migration(
            id: key,
            name: value['name'] as String,
            description: value['description'] as String,
            arrival: value['arrival'] as String,
            polygons: polygons,
          );
          updatedMigrations.add(migration);
          print('add called');
        });
        onDataReceived(updatedMigrations);
      }
      else if(event.snapshot.value == null){
        if(updatedMigrations.isNotEmpty){
          updatedMigrations.removeLast();
        }
        onDataReceived(updatedMigrations);
      }
    });
  }

  /*String getMuseumIdByName(String museumName)  {
    DatabaseReference museumsRef = database.ref().child('museums');
    String museumId = '';
    museumsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> museumsData = event.snapshot.value as Map<dynamic, dynamic>;

        museumsData.forEach((key, value) {
            if(value['name'] == museumName){
              museumId = value['id'];
              print(key);
            }
        });
      }
    });
    return museumId;
  }*/




}