import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Color(0xFF0D47A1); // Deep Blue
  static const Color accentColor = Color(0xFF42A5F5); // Lighter Blue
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textColor = Color(0xFF333333);
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;

  static final ThemeData mainTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      labelStyle: const TextStyle(color: textColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
}