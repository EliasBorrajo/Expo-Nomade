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
        migrationsData.forEach((key, value)
        {
          // POLYGONES
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

          // IMAGES
          List<String> images = [];
          if (value['images'] != null) {
            List<dynamic> imagesData = value['images'] as List<dynamic>;
            for (var image in imagesData) {
              if( image != null &&
                  image is String){
                images.add(image);
              }
            }
          }

          // MIGRATIONS
          Migration migration = Migration(
            id: key,
            name: value['name']! as String,
            description: value['description']! as String,
            arrival: value['arrival']! as String,
            images: images,
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

}