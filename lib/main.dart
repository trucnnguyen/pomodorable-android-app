import 'package:flutter/material.dart';
import 'package:my_first_flutter_app/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'pages/home_page.dart';
//
//
// void main() async {
//   await Hive.initFlutter();
//   //open a task box
//   var box = await Hive.openBox('myBox');
//
//   runApp(const MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build (BuildContext context) {
//     return MaterialApp(
//       home:MyHomePage(),
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         appBarTheme: const AppBarTheme(
//         backgroundColor: Color(0xFFFFCBCB),
//         ),
//       ),
//     );
//   }
// }
