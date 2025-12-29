// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:leelame/app/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      useMaterial3: true,
      fontFamily: "OpenSans Regular",

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: "OpenSans Regular",
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.primaryButtonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 0,
        ),
      ),

      // Elevated Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: "OpenSans Regular",
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: AppColors.primaryButtonColor, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 0,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        hintStyle: TextStyle(color: AppColors.textHintColor, fontSize: 17),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: TextStyle(color: Color(0xFF999999)),
        floatingLabelStyle: TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.focusedBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.focusedBorderColor, width: 2),
        ),
        // Optional error style
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
