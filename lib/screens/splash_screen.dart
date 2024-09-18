import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/login_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 2 seconds

    // Retrieve the value from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = "Bearer " + prefs.getString('authToken').toString();
    // If the token exists, make the API request
    if (authToken.isNotEmpty) {
      try {
        print(authToken);

        final response = await http.post(
          Uri.parse('$domain2/api/getUserByToken'),
          headers: {'Authorization': authToken},
        );
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          print(
              'Authorized aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          print(
              'Error bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
          prefs.clear();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoginView(
                      comes: false,
                    )),
          );
        }
      } catch (error) {
        print(
            'Error: $error cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc');
        prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginView(
                    comes: false,
                  )),
        );
      }
    } else {
      print('Error: Auth token not found');
      prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginView(
                  comes: false,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'Assets/Screenshot_2023-11-21_213101-removebg-preview.png',
          // Replace with the correct path to your image asset
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

class YourNextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with the actual widget for your next screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the next screen!'),
      ),
    );
  }
}
