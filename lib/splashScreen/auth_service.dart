import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/constents.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/login_view.dart';
import 'package:logger/logger.dart';

class AuthService {
  final Logger _logger = Logger(); // Initialize the logger

  // Method to navigate to the next screen based on the authentication token
  Future<void> navigateToNextScreen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken != null && authToken.isNotEmpty) {
      try {
        String bearerToken = "Bearer $authToken";
        _logger.d(bearerToken);

        final response = await http.post(
          Uri.parse('$domain2/api/getUserByToken'),
          headers: {'Authorization': bearerToken},
        );
        _logger.i(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // User is authorized, navigate to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          _handleUnauthorized(context, prefs);
        }
      } catch (error) {
        _logger.d('Error: $error');
        _handleUnauthorized(context, prefs);
      }
    } else {
      _logger.d('Error: Auth token not found');
      _handleUnauthorized(context, prefs);
    }
  }

  // Handle unauthorized cases and navigate to the LoginView
  void _handleUnauthorized(BuildContext context, SharedPreferences prefs) {
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView(comes: false)),
    );
  }
}
