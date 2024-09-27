import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:spa/splashScreen/auth_service.dart';
import 'package:spa/splashScreen/firebase_service.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Logger logger = Logger(); // Initialize the logger
  late FirebaseService firebaseService; // Declare FirebaseService
  late AuthService authService; // Declare AuthService

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService(); // Initialize FirebaseService
    authService = AuthService(); // Initialize AuthService
    firebaseService.printFCMToken(); // Get and print FCM token

    _startNavigation(); // Start navigation process
  }

  // Start the navigation process using AuthService
  Future<void> _startNavigation() async {
    await Future.delayed(const Duration(seconds: 2)); // Add a delay for splash effect
    authService.navigateToNextScreen(context); // Navigate based on authentication
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'Assets/Screenshot_2023-11-21_213101-removebg-preview.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}