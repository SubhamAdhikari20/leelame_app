// lib/app.dart
import 'package:flutter/material.dart';
import 'package:leelame/screens/splash_screen.dart';
import 'package:leelame/themes/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Leelame",
      theme: getApplicationTheme(),
      home: SplashScreen(),
    );
  }
}
