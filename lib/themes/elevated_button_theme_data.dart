// lib/themes/elevated_button_theme_data.dart
import 'package:flutter/material.dart';

ElevatedButtonThemeData getElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontFamily: "OpenSans Regular",
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Color(0xFF2ADA03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 0,
    ),
  );
}
