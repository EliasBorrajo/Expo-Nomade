

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../firebase_options.dart';


// source Tutorial : https://firebase.flutter.dev/docs/storage/start
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "exponomade-6452",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Storage());
}


class Storage extends StatefulWidget {

  const Storage({Key? key}) : super(key: key);

  @override
  _StorageState createState() => _StorageState();
}

class _StorageState extends State<Storage> {
  // A T T R I B U T E S
  final storage = FirebaseStorage.instance;


  // M E T H O D S
  void createReferences() {
    // 1) Create a reference to storage
    final storageRef = FirebaseStorage.instance.ref();


    // 2) Create a reference to a folder or a file
    // Create a child reference
    // imagesRef now points to "images"
    final imagesRef = storageRef.child("images");

    // Child references can also take paths
    // spaceRef now points to "images/space.jpg
    // imagesRef still points to "images"
    final spaceRef = storageRef.child("images/space.jpg");


    // 3) Navigate throug reference
    // parent allows us to move our reference to a parent node
    // imagesRef2 now points to 'images'
    final imagesRef2 = spaceRef.parent;

    // root allows us to move all the way back to the top of our bucket
    // rootRef now points to the root
    final rootRef = spaceRef.root;

    // References can be chained together multiple times
    // earthRef points to 'images/earth.jpg'
    final earthRef = spaceRef.parent?.child("earth.jpg");

    // nullRef is null, since the parent of root is null
    final nullRef = spaceRef.root.parent;


    // 4) Different Properties
    // Reference's path is: "images/space.jpg"
    // This is analogous to a file path on disk
    spaceRef.fullPath;

    // Reference's name is the last segment of the full path: "space.jpg"
    // This is analogous to the file name
    spaceRef.name;

    // Reference's bucket is the name of the storage bucket that the files are stored in
    spaceRef.bucket;
  }

  void createReferencesFullExample() {
    // Points to the root reference
    final storageRef = FirebaseStorage.instance.ref();

    // Points to "images"
    Reference? imagesRef = storageRef.child("images");

    // Points to "images/space.jpg"
    // Note that you can use variables to create child values
    final fileName = "space.jpg";
    final spaceRef = imagesRef.child(fileName);

    // File path is "images/space.jpg"
    final path = spaceRef.fullPath;

    // File name is "space.jpg"
    final name = spaceRef.name;

    // Points to "images"
    imagesRef = spaceRef.parent;
  }

  Future<void> uploadFiles() async
  {
    // 1) Create REF with FULL PATH to the file INCLUDING the FILE
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to "mountains.jpg"
    final mountainsRef = storageRef.child("mountains.jpg");

    // Create a reference to 'images/mountains.jpg'
    final mountainImagesRef = storageRef.child("images/mountains.jpg");

    // While the file names are the same, the references point to different files
    assert(mountainsRef.name == mountainImagesRef.name);
    assert(mountainsRef.fullPath != mountainImagesRef.fullPath);


    // 2) UPLOAD FROM A FILE
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.absolute}/file-to-upload.png';
    File file = File(filePath);

    try {
      await mountainsRef.putFile(file);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }


    // 3) UPLOAD FROM A STRING
    String dataUrl = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==';

    try {
      await mountainsRef.putString(dataUrl, format: PutStringFormat.dataUrl);
    } on FirebaseException catch (e) {
      // ...
    }


    // 4) Get a Download URL
    final String downloadURL = await mountainsRef
        .getDownloadURL(); // CECI SERA STOCKE DANS LA DB


    // 5) MANAGEMENT UPLOAD STATE
    // In addition to starting uploads, you can pause, resume, and cancel uploads
    // using the pause(), resume(), and cancel() methods.
    // Pause and resume events raise pause and progress state changes respectively.
    // Canceling an upload causes the upload to fail with an error indicating that the upload was canceled.
    var largeFile = File('...');
    final task = mountainsRef.putFile(largeFile);

    // Pause the upload.
    bool paused = await task.pause();
    print('paused, $paused');

    // Resume the upload.
    bool resumed = await task.resume();
    print('resumed, $resumed');

    // Cancel the upload.
    bool canceled = await task.cancel();
    print('canceled, $canceled');


    // 6) MONITOR UPLOAD PROGRESS
    mountainsRef
        .putFile(file)
        .snapshotEvents
        .listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
        // ...
          break;
        case TaskState.paused:
        // ...
          break;
        case TaskState.success:
        // ...
          break;
        case TaskState.canceled:
        // ...
          break;
        case TaskState.error:
        // ...
          break;
      }
    });
  }

  Future<void> uploadFilesFullExample() async
  {
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = "${appDocDir.absolute}/path/to/mountains.jpg";
    final file = File(filePath);

    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg"); // Optional

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = storageRef
        .child("images/path/to/mountains.jpg")
        .putFile(file, metadata);

    // Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;

        case TaskState.paused:
          print("Upload is paused.");
          break;

        case TaskState.canceled:
          print("Upload was canceled");
          break;

        case TaskState.error:
        // Handle unsuccessful uploads
          break;

        case TaskState.success:
        // Handle successful uploads on complete
        // ...

          final String downloadURL = await storageRef
              .getDownloadURL(); // CECI SERA STOCKE DANS LA DB ??
          // TODO : Stocker l'URL de l'image dans la DB

          break;
      }
    });
  }

  getApplicationDocumentsDirectory() {}

  //  By default, requires Firebase Authentication to perform any action on the bucket's data or files
  Future<void> downloadFiles() async
  {
    // 1) Create a REF to the file to download
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference with an initial file path and name
    final pathReference = storageRef
        .child("images/stars.jpg");

    // Create a reference to a file from a Google Cloud Storage URI
    final gsReference = FirebaseStorage.instance
        .refFromURL("gs://YOUR_BUCKET/images/stars.jpg");

    // Create a reference from an HTTPS URL
    // Note that in the URL, characters are URL escaped!
    final httpsReference = FirebaseStorage.instance
        .refFromURL(
        "https://firebasestorage.googleapis.com/b/YOUR_BUCKET/o/images%20stars.jpg");

    // 2) DOWNLOAD THE FILE
    var imageGetData = await pathReference.getData();

    // 3) Get a Download URL for a file
    var imageGetDownload = await pathReference.getDownloadURL();

    // 4) Download BIG FILES in memory
    // If you request a file larger than your app's available memory, your app will crash.
    // To protect against memory issues, getData() takes a maximum amount of bytes to download.
    // Set the maximum size to something you know your app can handle, or use another download method.
    final islandRef = storageRef.child("images/island.jpg");

    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data = await islandRef.getData(oneMegabyte);
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      // Handle any errors.
    }

    // 5) Download to local file
    // Use "writeToFile" to download a file to a specified path on your local device.
    // If your users want to have access to the file while offline or to share the file in a different app
    final islandRef2 = storageRef.child("images/island.jpg");

    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = "${appDocDir.absolute}/images/island.jpg";
    final file = File(filePath);

    final downloadTask = islandRef2.writeToFile(file);
    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
        // TODO: Handle this case.
          break;
        case TaskState.paused:
        // TODO: Handle this case.
          break;
        case TaskState.success:
        // TODO: Handle this case.
          break;
        case TaskState.canceled:
        // TODO: Handle this case.
          break;
        case TaskState.error:
        // TODO: Handle this case.
          break;
      }
    });


    // 6) Downlaod Data via URL
    final imageUrl = await storageRef.child("users/me/profile.png")
        .getDownloadURL();
  }

  Future<void> downloadFilesFullExample() async
  {
    final storageRef = FirebaseStorage.instance.ref();
    final islandRef = storageRef.child("images/island.jpg"); // Source to download

    final appDocDir = await getApplicationDocumentsDirectory(); // Destination to download
    final filePath = "${appDocDir.absolute}/images/island.jpg";
    final file = File(filePath);

    final downloadTask = islandRef.writeToFile(file);
    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
        // TODO: Handle this case.
          break;
        case TaskState.paused:
        // TODO: Handle this case.
          break;
        case TaskState.success:
        // TODO: Handle this case.
          break;
        case TaskState.canceled:
        // TODO: Handle this case.
          break;
        case TaskState.error:
        // TODO: Handle this case.
          break;
      }
    });
  }

  Future<void> listFiles() async
  {
    // Prefix & Items separations
    // List API returns prefixes and items separately. For example, if you upload one file /images/uid/file1,
    // root.child('images').listAll() will return /images/uid as a prefix.
    // root.child('images/uid').listAll() will return the file as an item.

    // Préfixes (Prefixes) :
    //
    // Les "préfixes" sont essentiellement des sous-répertoires ou des répertoires qui se trouvent dans le répertoire actuel.
    // Ils sont utiles lorsque vous avez une structure de stockage hiérarchique, similaire à la structure de fichiers d'un système de fichiers.
    // Les préfixes sont retournés sous forme de références aux sous-répertoires,
    // et vous pouvez ensuite appeler listAll() récursivement sur ces préfixes pour lister leur contenu.
    // Par exemple, si vous avez un répertoire /images et un répertoire /images/uid, listAll() sur /images renverra /images/uid en tant que préfixe.

    // Éléments (Items) :
    //
    // Les "éléments" sont les fichiers ou objets réels situés dans le répertoire actuel.
    // Ils sont retournés sous forme de références aux fichiers ou objets stockés dans le répertoire.
    // Par exemple, si vous avez un fichier /images/uid/file1, listAll() sur /images/uid renverra file1 en tant qu'élément.

    // 1) LIST ALL items (files) in a folder
    final storageRef = FirebaseStorage.instance.ref().child("files/uid");
    final listResult = await storageRef.listAll();
    for (var prefix in listResult.prefixes) {
      // The prefixes under storageRef.
      // You can call listAll() recursively on them.
    }
    for (var item in listResult.items) {
      // The items under storageRef.
    }


    // 2) PAGINATION - LIST A LIMITED NUMBER OF ITEMS
    Stream<ListResult> listAllPaginated(Reference storageRef) async*
    {
      String? pageToken;
      do {
        final listResult = await storageRef.list(ListOptions(
          maxResults: 100,
          pageToken: pageToken,
        ));
        yield listResult;
        pageToken = listResult.nextPageToken;
      } while (pageToken != null);
    }
  }


  // R E N D E R I N G
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}
