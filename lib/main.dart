import 'package:face_attendance_app/screens/home_screen.dart';
import 'package:face_attendance_app/utils/app_styles.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.mainTheme,
      home: const HomeScreen(),
    );
  }
}