import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter_app/pages/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter_app/pages/navbar_roots.dart';
import 'package:firebase_database/firebase_database.dart';


class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passToggle = true;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var partnerNameController= TextEditingController();
  var dateController= TextEditingController();


  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        //profileImage = File(pickedImage.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  "images/logo.png",
                ),
              ),
              const Text(
                "Pomodorable",
                style: TextStyle(
                  color: Color(0xFFFFCBCB),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  wordSpacing: 2,
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              //   child: InkWell(
              //     onTap: pickProfileImage,
              //     child: profileImage == null
              //         ? Container(
              //       height: 100,
              //       width: 100,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.grey[300],
              //       ),
              //       child: Icon(
              //         Icons.camera_alt,
              //         size: 50,
              //         color: Colors.grey[600],
              //       ),
              //     )
              //         : CircleAvatar(
              //       radius: 50,
              //       backgroundImage: FileImage(profileImage!),
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: TextField(
                  controller: nameController, // Connect the controller to the TextField
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Set border radius here
                    ),
                    prefixIcon: Icon(Icons.person),
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    // Set label text color here
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: TextField(
                  controller: partnerNameController, // Connect the controller to the TextField
                  decoration: InputDecoration(
                    labelText: "Your Partner Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Set border radius here
                      borderSide: BorderSide(color: Colors.green), // Set border color here
                    ),
                    prefixIcon: Icon(Icons.person),
                    labelStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,// Set label text color here
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: TextField(
                  controller: dateController, // Connect the controller to the TextField
                  decoration: InputDecoration(
                    labelText: "Your First date Is On",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Set border radius here
                      borderSide: BorderSide(color: Colors.orange), // Set border color here
                    ),
                    prefixIcon: Icon(Icons.calendar_today),
                    labelStyle: TextStyle(color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,// Set label text color here
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      // Update the date controller when a date is selected
                      dateController.text = pickedDate.toString();
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: TextField(
                  controller: emailController, // Connect the controller to the TextField
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Set border radius here
                      borderSide: BorderSide(color: Colors.red), // Set border color here
                    ),
                    prefixIcon: Icon(Icons.email),
                    labelStyle: TextStyle(color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white,// Set label text color here
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: passwordController, // Connect the controller to the TextField
                  obscureText: passToggle ? true : false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Set border radius here
                      borderSide: BorderSide(color: Colors.purple), // Set border color here
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    label: Text("Enter Password"),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: InkWell(
                      onTap: () {
                        if (passToggle == true) {
                          passToggle = false;
                        } else {
                          passToggle = true;
                        }
                        setState(() {});
                      },
                      child: passToggle
                          ? Icon(CupertinoIcons.eye_slash_fill)
                          : Icon(CupertinoIcons.eye_fill),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print(emailController.text);
                  print(passwordController.text);

                  // Authorize user
                  FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text, // Use the text from the email controller
                    password: passwordController.text, // Use the text from the password controller
                  ).then((authResult) {
                    print("Success with UID:" + authResult.user!.uid);

                    // Create new user
                    var userProfile = {
                      'uid' : authResult.user?.uid,
                      'name' : nameController.text,
                      'email' : emailController.text,
                      'date' : dateController.text,
                      'partner' : partnerNameController.text,
                    };

                    FirebaseDatabase.instance.ref().child("pomodorable/users/user" + authResult.user!.uid.toString())
                    .set(userProfile)
                        .then((value) {
                      print("==========Success===============");
                    }).catchError((error) {
                      print("============Failed to create user profile!===========");
                      print(error.toString());
                    });

                    //Navigate to the homePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavBarRoots(userName: nameController.text,),
                      ));

                  }).catchError((error) {
                    print("Failed to create user profile in auth!");
                    print(error.toString());
                  });

                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFBBBB)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 15)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
                  ),
                ),
                child: Text("Sign Up"),

              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have account?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFBBBB),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFCBCB),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}