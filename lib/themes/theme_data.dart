// lib/themes/theme_data.dart
import 'package:flutter/material.dart';
import 'package:leelame/themes/elevated_button_theme_data.dart';
import 'package:leelame/themes/input_decoration_theme_data.dart';
import 'package:leelame/themes/outlined_button_theme_data.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    useMaterial3: true,
    fontFamily: "OpenSans Regular",
    elevatedButtonTheme: getElevatedButtonTheme(),
    outlinedButtonTheme: getOutlinedButtonTheme(),
    inputDecorationTheme: getInputDecorationTheme(),
  );
}
