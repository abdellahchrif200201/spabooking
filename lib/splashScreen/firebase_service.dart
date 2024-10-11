import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/main.dart';
import 'package:spa/screens/boocked.dart';
import 'package:spa/screens/detials_reservation.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/parent_chat.dart';
import 'package:spa/splashScreen/api_service.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  final ApiService _apiService = ApiService();

  FirebaseService() {
    _initializeLocalNotifications();
    _requestNotificationPermission();
    _setupForegroundNotificationListener();
    _listenForTokenRefresh();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Method to initialize local notifications
  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize local notifications and handle notification taps
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          _handleNotificationNavigation(notificationResponse.payload!); // Handle notification tap
        }
      },
    );
  }

  // Method to handle navigation based on the payload using Navigator.push
  void _handleNotificationNavigation(String payload) {
    String jsonString = payload.replaceAllMapped(RegExp(r'(\w+):\s*([^,}]+)'), (match) => '"${match[1]}": "${match[2].toString().trim()}"');
    Map<String, dynamic> parsedPayload = jsonDecode(jsonString);

    // Read the id and convert to int if necessary
    int id = int.parse(parsedPayload['id'].toString());

    // Print just the id
    Logger().d('Notification ID: $id');

    if (id == 1) {  // type = booking
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => Booked()),
      );
    } else if (id == 2) { // type = confirmation always id is 1 confirmation
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => Booked()),
      );
    } else {  
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => Booked()),
      );
    }
  }

  // Helper method to parse the payload

  // Background message handler
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    Logger().i('Handling a background message: ${message.messageId}');
    await _showNotification(message); // Always show notification in background
  }

  // Method to request notification permissions
  void _requestNotificationPermission() {
    _firebaseMessaging.requestPermission();
  }

  // Method to listen for incoming foreground notifications
  void _setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Received a message in foreground: ${message.messageId}');
      _showNotification(message);
      // _handleNotificationNavigation(message.data.toString()); // Handle navigation in foreground
    });
  }

  // Method to listen for token refresh
  void _listenForTokenRefresh() async {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _logger.d('FCM Token refreshed: $newToken');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('FCMTokenTwo', newToken);

      _apiService.getFCMToken();
    });
  }

 

  static Future<void> _showNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id', // Channel ID
        'Your Channel Name', // Channel Name
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unique ID based on current time

      String payload = message.data.toString(); // Extract the payload

      // Log the payload
      Logger().d('Notification Payload: $payload');

      // Convert the payload to a valid JSON format
      String jsonString = payload.replaceAllMapped(RegExp(r'(\w+):\s*([^,}]+)'), (match) => '"${match[1]}": "${match[2].toString().trim()}"'); // Wrap both keys and values with double quotes

      try {
        // Parse the payload
        Map<String, dynamic> parsedPayload = jsonDecode(jsonString);

        // Read the id and convert to int if necessary
        int id = int.parse(parsedPayload['id'].toString());

        // Print just the id
        Logger().d('Notification ID: $id');
      } catch (e) {
        Logger().e('Error parsing payload: $e');
      }

      await FlutterLocalNotificationsPlugin().show(
        notificationId, // Use a unique notification ID
        message.notification?.title ?? 'No Title', // Notification Title
        message.notification?.body ?? 'No Body', // Notification Body
        platformChannelSpecifics,
        payload: payload, // Use dynamic payload if needed
      );
    } catch (e) {
      Logger().e('Error showing notification: $e');
    }
  }

  // Method to get and print the FCM token
  Future<void> printFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    _logger.d('FCM Token dyalom: $token');
    SharedPreferences prefs = await SharedPreferences.getInstance();


    // prefs.setString("test", token!);
    if (token != null) {
      prefs.setString('FCMTokenOne', token);
      logger.i("i save this this token $token");
    }
    await _apiService.getFCMToken();
  }
}





