import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/screens/login_view.dart';

class ApiService {
  final Logger _logger = Logger(); // Logger instance

  Future<void> sendData(String token, int id, String fcmToken) async {
    String domain2 = "https://app.spabooking.pro/api/auth/editProfil"; // Replace with your actual domain
    String authToken = "Bearer $token"; // Replace with your actual auth token

    // Request body
    Map<String, dynamic> requestBody = {"user_id": id, "FCMToken": fcmToken};

    try {
      // Make the POST request
      var response = await http.post(
        Uri.parse(domain2),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check the status code and handle response
      if (response.statusCode == 200) {
        _logger.i("Request successful: ${response.body}");
      } else {
        _logger.e("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _logger.e("Error: $e");
    }
  }

  Future<void> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fcmTokenOne = prefs.getString("FCMTokenOne");
    final fcmTokenTwo = prefs.getString("FCMTokenTwo");
    final userToken = prefs.getString("authToken");
    final id = prefs.getString("id");

    
    _logger.d("my token  $userToken");
    _logger.d("my user id  $id");

    final tokenNotif = fcmTokenTwo ?? fcmTokenOne;

    logger.i("my token notif $tokenNotif");



    if (tokenNotif != null && id != null && userToken != null) {
      int idUser = int.parse(id);

      // Call the sendData method from ApiService
      sendData(userToken, idUser, tokenNotif);
    }
  }
}
