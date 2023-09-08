import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../dataModels/Migration.dart';


enum FirebaseRefType {
  migrations,
  museums,
  museumsObjects
}

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
              if(polyValue != null){
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
                  points: points,
                  name: polyValue['name']! as String,
                );
                polygons.add(source);
              }
            }
          }
          Migration migration = Migration(
            id: key,
            name: value['name']! as String,
            description: value['description']! as String,
            arrival: value['arrival']! as String,
            polygons: polygons,
          );
          updatedMigrations.add(migration);
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

  /// Returns a reference to a Firebase database node.
  /// Parameters:
  /// - refType: the type of the reference to return (e.g. FirebaseRefType.museums)
  /// - id: the id of the node to return
  /// - Returns: a reference to a Firebase database node
  ///           (e.g. database.ref().child('museums').child(id))
  ///           or null if the refType is not supported or if the id is null or empty
  DatabaseReference? getDatabaseRef(FirebaseRefType refType, String? id)
  {
    if (id == null || id.isEmpty) {
      return null;
    }

    switch (refType) {
      case FirebaseRefType.migrations:
        return database.ref().child('migrations').child(id);
      case FirebaseRefType.museums:
        return database.ref().child('museums').child(id);
      case FirebaseRefType.museumsObjects:
        return database.ref().child('museumsObjects').child(id);
      default:
        return null;
    }
  }
}