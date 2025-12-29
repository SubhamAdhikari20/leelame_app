// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:leelame/app/theme/app_theme.dart';
import 'package:leelame/features/splash/presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Leelame",
      theme: AppTheme.lightTheme,
      // themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
