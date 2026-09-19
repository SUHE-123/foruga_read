import 'package:flutter/material.dart';

import 'pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LearnEnglishKidsApp());
}

class LearnEnglishKidsApp extends StatelessWidget {
  const LearnEnglishKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'FORUGA READ',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),

      home: const SplashPage(),
    );
  }
}