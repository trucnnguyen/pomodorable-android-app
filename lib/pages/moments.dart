import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'capture.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      body: Column(
        children: [
          Image.file(File(imagePath)),
          Text('${imagePath}'),
          ElevatedButton(
            child: Text("Upload"),
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser;
              final ref = FirebaseDatabase.instance.ref();
              final username = await ref
                  .child("pomodorable/users/user${currentUser?.uid}/name")
                  .get();
              var fileToUpload = File(imagePath);
              var fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".png";
              UploadTask task = FirebaseStorage.instance.ref().child("images/user: ${username.value}/" + fileName).putFile(fileToUpload);

              // Listen for state changes, errors, and completion of the upload.
              task.snapshotEvents.listen((TaskSnapshot snapshot) {
                if (snapshot.state == TaskState.success) {
                  snapshot.ref.getDownloadURL().then((url) {
                    print("URL: " + url.toString());
                    // Navigate back to TempPage after uploading
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TempPageScreen(),
                      ),
                    );
                  }).catchError((error) {
                    print("Failed to get the URL");
                  });
                }
              });
            },
          )
        ],
      ),
    );
  }
}

