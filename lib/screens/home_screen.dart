import 'package:face_attendance_app/screens/attendance_screen.dart';
import 'package:face_attendance_app/screens/registration_screen.dart';
import 'package:face_attendance_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Attendance System'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.face_retouching_natural,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Register New User',
                icon: Icons.person_add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Mark Attendance',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AttendanceScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}