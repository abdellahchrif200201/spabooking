import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/login_view.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class SplashScreenn extends StatefulWidget {
  @override
  _SplashScreennState createState() => _SplashScreennState();
}

class _SplashScreennState extends State<SplashScreenn> {
  final Logger logger = Logger(); // Initialize the logger

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Initialize FlutterLocalNotificationsPlugin

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();

    // Initialize local notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon'); // Use your app icon
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.instance.requestPermission();

    // @Setup foreground notification listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Received a message in foreground: ${message.messageId}');
      _showNotification(message);
    });

    // Get and print the FCM token
    _printFCMToken();

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      logger.d('FCM Token refreshed: $newToken');
    });
  }

  // Method to get and print the FCM token
  Future<void> _printFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    logger.d('FCM Token: $token');
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 2 seconds

    // Retrieve the value from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken != null && authToken.isNotEmpty) {
      try {
        String bearerToken = "Bearer $authToken";
        logger.d(bearerToken);

        final response = await http.post(
          Uri.parse('$domain2/api/getUserByToken'),
          headers: {'Authorization': bearerToken},
        );
        // logger.d(response.statusCode);
        logger.i(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // logger.d('Authorized');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          _handleUnauthorized(prefs);
        }
      } catch (error) {
        logger.d('Error: $error');
        _handleUnauthorized(prefs);
      }
    } else {
      logger.d('Error: Auth token not found');
      _handleUnauthorized(prefs);
    }
  }

  void _handleUnauthorized(SharedPreferences prefs) {
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginView(
                comes: false,
              )),
    );
  }

  // Method to show notification based on received message
  // Future<void> _showNotification(RemoteMessage message) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'your_channel_id', // Channel ID
  //     'Your Channel Name', // Channel Name
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     0, // Notification ID
  //     message.notification?.title ?? 'No Title', // Notification Title
  //     message.notification?.body ?? 'No Body', // Notification Body
  //     platformChannelSpecifics,
  //     payload: 'Message Payload', // Optional payload
  //   );
  // }

  Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id', // Channel ID
    'Your Channel Name', // Channel Name
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unique ID based on current time

  await flutterLocalNotificationsPlugin.show(
    notificationId, // Use a unique notification ID
    message.notification?.title ?? 'No Title', // Notification Title
    message.notification?.body ?? 'No Body', // Notification Body
    platformChannelSpecifics,
    payload: 'Message Payload', // Optional payload
  );
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

class YourNextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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






// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:spa/constents.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:spa/screens/home_page.dart';
// import 'package:spa/screens/login_view.dart';

// class SplashScreenn extends StatefulWidget {
//   @override
//   _SplashScreennState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToNextScreen();
//   }

//   Future<void> _navigateToNextScreen() async {
//     // Wait for 2 seconds

//     // Retrieve the value from local storage
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? authToken = "Bearer " + prefs.getString('authToken').toString();
//     // If the token exists, make the API request
//     if (authToken.isNotEmpty) {
//       try {
//         logger.d(authToken);

//         final response = await http.post(
//           Uri.parse('$domain2/api/getUserByToken'),
//           headers: {'Authorization': authToken},
//         );
//         logger.d(response.statusCode);
//         logger.d(response.body);
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           logger.d('Authorized aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage()),
//           );
//         } else {
//           logger.d('Error bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
//           prefs.clear();
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => LoginView(
//                       comes: false,
//                     )),
//           );
//         }
//       } catch (error) {
//         logger.d('Error: $error cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc');
//         prefs.clear();
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) => LoginView(
//                     comes: false,
//                   )),
//         );
//       }
//     } else {
//       logger.d('Error: Auth token not found');
//       prefs.clear();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => LoginView(
//                   comes: false,
//                 )),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset(
//           'Assets/Screenshot_2023-11-21_213101-removebg-preview.png',
//           // Replace with the correct path to your image asset
//           width: 200,
//           height: 200,
//         ),
//       ),
//     );
//   }
// }

// class YourNextScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Replace this with the actual widget for your next screen
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Next Screen'),
//       ),
//       body: const Center(
//         child: Text('Welcome to the next screen!'),
//       ),
//     );
//   }
// }
