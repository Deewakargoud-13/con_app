import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.blue.shade50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.blue.shade100,
      labelStyle: const TextStyle(color: Colors.black),
      selectedColor: Colors.blue,
      secondarySelectedColor: Colors.blue.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      brightness: Brightness.light,
    ),
  );
} 