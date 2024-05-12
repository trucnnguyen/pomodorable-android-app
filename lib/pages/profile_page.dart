import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var user = [];
  List<String> imageUrls2 = [];
  bool image1Selected = false;
  bool image2Selected = false;
  late File image1;
  late File image2;

  @override
  void initState() {
    super.initState();
    image1 = File("images/naname.png");
    image2 = File("images/profile01.png");
    loadUserInfo();
    fetchImageUrls();
    saveImages();
  }

  Future<void> loadUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance.ref();
    var userTemp = [];

    final userName = await ref.child('pomodorable/users/user${currentUser?.uid}/name').get();
    if (userName.exists) {
      print(userName.value);
    } else {
      print('No data available.');
    }

    final partnerName = await ref.child('pomodorable/users/user${currentUser?.uid}/partner').get();
    if (partnerName.exists) {
      print(partnerName.value);
    } else {
      print('No data available.');
    }

    final date = await ref.child('pomodorable/users/user${currentUser?.uid}/date').get();
    if (date.exists) {
      print(date.value);
    } else {
      print('No data available.');
    }

    userTemp.add(userName.value);
    userTemp.add(partnerName.value);
    userTemp.add(date.value);

    user = userTemp;
    setState(() {});
  }

  Future<List<String>> fetchImageUrls() async {
    List<String> imageUrls = [];
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final ref = FirebaseDatabase.instance.ref();
      final usernameSnapshot = await ref.child("pomodorable/users/user${currentUser?.uid}/name").get();
      final username = usernameSnapshot.value.toString();

      final imagesRef = FirebaseStorage.instance.ref().child("images/user: $username");
      final ListResult result = await imagesRef.listAll();

      await Future.forEach(result.items, (Reference ref) async {
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      });

      setState(() {
        imageUrls2 = imageUrls;
      });
    } catch (error) {
      print("Error fetching image URLs: $error");
    }

    return imageUrls;
  }

  Future<void> pickImage(int imageNumber) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        if (imageNumber == 1) {
          image1Selected = true;
          image1 = File(pickedImage.path);
        } else {
          image2Selected = true;
          image2 = File(pickedImage.path);
        }
      });
    }
    saveImages();
  }

  Future<void> saveImages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance.ref();
    final username = await ref.child("pomodorable/users/user${currentUser?.uid}/name").get();
    final partnername = await ref.child("pomodorable/users/user${currentUser?.uid}/partner").get();
    try {
      if (image1Selected) {
        final image1Ref = FirebaseStorage.instance.ref().child('images').child('${username.value}profileImage.jpg');
        await image1Ref.putFile(image1);
        final image1Url = await image1Ref.getDownloadURL();
        FirebaseDatabase.instance
            .ref()
            .child('pomodorable/users/user${currentUser?.uid}/profile')
            .set(image1Url);
      }

      if (image2Selected) {
        final image2Ref = FirebaseStorage.instance.ref().child('images').child('${partnername.value}_profileImage.jpg');
        await image2Ref.putFile(image2);
        final image2Url = await image2Ref.getDownloadURL();
        FirebaseDatabase.instance
            .ref()
            .child('pomodorable/users/user${currentUser?.uid}/partnerProfile')
            .set(image2Url);
      }
    } catch (error) {
      print('Error saving images: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Color(0xFFFAC1C1), // Set the background color here
        elevation: 0, // This removes the shadow
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFAC1C1), // Set the background color here
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(image1),
                        ),
                        ElevatedButton(
                          onPressed: () => pickImage(1),
                          child: const Text('Change Image 1'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(image2),
                        ),
                        ElevatedButton(
                          onPressed: () => pickImage(2),
                          child: const Text('Change Image 2'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Parallel Boxes
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Name", // Description text
                          style: TextStyle(
                            fontSize: 16, // Adjust font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Adjust font weight as needed
                          ),
                        ),
                        SizedBox(height: 8), // Add space between the description and the box
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.isNotEmpty ? user[0] : 'Loading...'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Partner Name", // Description text
                          style: TextStyle(
                            fontSize: 16, // Adjust font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Adjust font weight as needed
                          ),
                        ),
                        SizedBox(height: 8), // Add space between the description and the box
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.isNotEmpty ? user[1] : 'Loading...'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Your Journey Started On Box
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Journey Started On", // Description text
                    style: TextStyle(
                      fontSize: 16, // Adjust font size as needed
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Adjust font weight as needed
                    ),
                  ),
                  SizedBox(height: 8), // Add space between the description and the box
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(user.isNotEmpty ? user[2] : 'Loading...'),
                    ),
                  ),
                ],
              ),
              // GridView
              Container(
                height: 250, // Adjust the height as needed
                child: GridView.builder(
                  itemCount: imageUrls2.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
