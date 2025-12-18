// lib/themes/outlined_button_theme_data.dart
import 'package:flutter/material.dart';

OutlinedButtonThemeData getOutlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontFamily: "OpenSans Regular",
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: Color(0xFF2ADA03), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 0,
    ),
  );
}
