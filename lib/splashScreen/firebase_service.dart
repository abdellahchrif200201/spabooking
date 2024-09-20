import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger(); // Logger instance

  FirebaseService() {
    // Constructor to initialize the service
    _initializeLocalNotifications();
    _requestNotificationPermission();
    _setupForegroundNotificationListener();
    _listenForTokenRefresh();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Method to initialize local notifications
  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon'); // Use your app icon
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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
      _showNotification(message); // Show notification for foreground messages
    });
  }

  // Method to listen for token refresh
  void _listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _logger.d('FCM Token refreshed: $newToken');
    });
  }

  // Method to get and print the FCM token
  Future<void> printFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    _logger.d('FCM Token: $token');
  }

  // Method to show local notification when receiving a message
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

      await FlutterLocalNotificationsPlugin().show(
        notificationId, // Use a unique notification ID
        message.notification?.title ?? 'No Title', // Notification Title
        message.notification?.body ?? 'No Body', // Notification Body
        platformChannelSpecifics,
        payload: message.data.toString(), // Use dynamic payload if needed
      );
    } catch (e) {
      Logger().e('Error showing notification: $e');
    }
  }
}
