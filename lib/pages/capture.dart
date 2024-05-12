import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'display.dart'; // Assuming this is the file where CapturePage is defined

class TempPageScreen extends StatefulWidget {
  @override
  TempPageScreenState createState() => TempPageScreenState();
}

class TempPageScreenState extends State<TempPageScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription cam;
  List<String> imageUrls2 = []; // Store URLs of images

  @override
  void initState() {
    super.initState();
    initializeCamera();
    // Fetch image URLs from Firebase Storage
    fetchImageUrls();
  }

  // Initialize the camera
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    setState(() {
      cam = cameras.first;
      _controller = CameraController(cam, ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();
    });
  }

  // Fetch image URLs from Firebase Storage
  Future<List<String>> fetchImageUrls() async {
    List<String> imageUrls = [];
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final ref = FirebaseDatabase.instance.ref();
      final usernameSnapshot = await ref
          .child("pomodorable/users/user${currentUser?.uid}/name")
          .get();
      final username = usernameSnapshot.value.toString();

      // Get a reference to the images folder for the current user
      final imagesRef = FirebaseStorage.instance.ref().child("images/user: $username");

      // List all items (images) in the images folder
      final ListResult result = await imagesRef.listAll();

      // Iterate over each item (image) and get its download URL
      await Future.forEach(result.items, (Reference ref) async {
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      });
      print("========= IMAGES ============");
      print(imageUrls);

      // Update the UI
      setState(() {imageUrls2 = imageUrls;});

    } catch (error) {
      print("Error fetching image URLs: $error");
    }

    return imageUrls;
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Take a picture'),
          backgroundColor: Color(0xFFFAC1C1), // Set the background color here
          elevation: 0,),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CapturePage(camera: cam),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
      body: GridView.builder(
        itemCount: imageUrls2.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Handle image tap
            },
            child: Image.network(imageUrls2[index]),
          );
        },
      ),
    );
  }
}
