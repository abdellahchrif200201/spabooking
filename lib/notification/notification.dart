// // import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:logger/logger.dart';
// import 'package:rename/platform_file_editors/abs_platform_file_editor.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();



// // Handle background messages from Firebase
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   Logger().i('Handling a background message: ${message.messageId}');
//   await _showNotification(message); // Call the function to show notification
// }

// // Method to display incoming Firebase message as a notification
// Future<void> _showNotification(RemoteMessage message) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'firebase_channel_id', // Channel ID for Firebase messages
//     'Firebase Notifications', // Channel Name
//     importance: Importance.max,
//     priority: Priority.high,
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);

//   await flutterLocalNotificationsPlugin.show(
//     message.hashCode, // Unique ID
//     message.notification?.title ?? 'No Title',
//     message.notification?.body ?? 'No Body',
//     platformChannelSpecifics,
//     payload: message.data.toString(),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Firebase Notifications',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: NotificationScreen(),
//     );
//   }
// }

// class NotificationScreen extends StatefulWidget {
//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Show static notification on startup for testing
//     _showStaticNotification();

//     // Request notification permissions for iOS devices
//     FirebaseMessaging.instance.requestPermission();

//     // Setup foreground notification listener
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       Logger().i('Received a message in foreground: ${message.messageId}');
//       _showNotification(message);
//     });

//     // Get and print the FCM token
//     _printFCMToken();

//     // Listen for token refresh
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       logger.d('FCM Token refreshed: $newToken');
//     });
//   }

//   // Method to get and print the FCM token
//   Future<void> _printFCMToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     logger.d('FCM Token: $token');
//   }

//   // Method to show a static notification
//   Future<void> _showStaticNotification() async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'static_channel_id', // Channel ID
//       'Static Notifications', // Channel Name
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       0, // Notification ID
//       'Static Notification Title', // Notification Title
//       'This is a static notification body.', // Notification Body
//       platformChannelSpecifics,
//       payload: 'Static Notification', // Optional payload
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firebase Notifications'),
//       ),
//       body: Center(
//         child: Text('Listening for Notifications...'),
//       ),
//     );
//   }
// }