// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleSignInDemo extends StatefulWidget {
//   @override
//   _GoogleSignInDemoState createState() => _GoogleSignInDemoState();
// }

// class _GoogleSignInDemoState extends State<GoogleSignInDemo> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email'],
//   );

//   GoogleSignInAccount? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       setState(() {
//         _currentUser = account;
//         print(_currentUser);
//       });
//     });
//   }

//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print('Error signing in: $error');
//     }
//   }

//   Future<void> _handleSignOut() async {
//     await _googleSignIn.disconnect();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Sign-In'),
//       ),
//       body: Center(
//         child: _currentUser != null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Signed in as: ${_currentUser!.displayName}'),
//                   ElevatedButton(
//                     onPressed: _handleSignOut,
//                     child: Text('Sign out'),
//                   ),
//                 ],
//               )
//             : ElevatedButton(
//                 onPressed: _handleSignIn,
//                 child: Text('Sign in with Google'),
//               ),
//       ),
//     );
//   }
// }
