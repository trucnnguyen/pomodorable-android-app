import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:my_first_flutter_app/pages//home_screen.dart';
import 'package:my_first_flutter_app/pages/profile_page.dart';
import 'package:my_first_flutter_app/pages/capture.dart';

class NavBarRoots extends StatefulWidget {
  final String userName;

  NavBarRoots({required this.userName});

  @override
  State<NavBarRoots> createState() => _NavBarRootsState();
}

class _NavBarRootsState extends State<NavBarRoots> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late CameraDescription cam;

  // Initialize the camera
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    setState(() {
      cam = cameras.first;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeCamera().then((_) {
      // Initialize the screens after the camera is initialized
      _screens = [
        HomeScreen(username: widget.userName),
        TempPageScreen(), // Only add CapturePage if camera is available
        ProfilePage(),
      ];
      setState(() {}); // Trigger rebuild after initializing screens
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCBCB),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60,
        child: BottomNavigationBar(
          backgroundColor: Color(0xFFFFCBCB),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                    Icons.home_filled),
                    label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(
                    Icons.calendar_month_outlined),
                    label: "moments.dart"),
            BottomNavigationBarItem(
                icon: Icon(
                    Icons.person),
                label: "Profile"),
          ],
        ),
      ),
    );
  }
}