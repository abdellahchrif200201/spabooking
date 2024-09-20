import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/LoginTR.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/signUp_view.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';

var logger = Logger();

class SimpleUIController {
  ValueNotifier<bool> isObscure = ValueNotifier<bool>(true);

  void isObscureActive() {
    isObscure.value = !isObscure.value;
  }
}

class LoginView extends StatefulWidget {
  final bool comes;
  LoginView({Key? key, required this.comes}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool see = false;
  late SharedPreferences _prefs;
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        print(_currentUser);
      });
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  // Future<void> _handleSignOut() async {
  //   await _googleSignIn.disconnect();
  // }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefs.getString('selectedLanguage') ?? 'Frensh';
    });
  }

  String translate(String key, Map<String, String> translationMap) {
    return translationMap[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    SimpleUIController simpleUIController = SimpleUIController();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: GestureDetector(
            onTap: () {
              nameController.clear();
              emailController.clear();
              passwordController.clear();
              _formKey.currentState?.reset();
              simpleUIController.isObscure.value = true;
              // Navigate to the desired page for logging in as a guest
              // You may replace GuestLoginView with the appropriate page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Container(
              width: 280,
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFD91A5B).withOpacity(1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    (selectedLanguage == "English"
                        ? translate(
                            "Connexion en tant qu'invité", login_english)
                        : selectedLanguage == "Arabic"
                            ? translate(
                                "Connexion en tant qu'invité", login_arabic)
                            : "Connexion en tant qu'invité" + " ->"),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildLargeScreen(size, simpleUIController);
              } else {
                return _buildSmallScreen(size, simpleUIController);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: RotatedBox(
            quarterTurns: 3,
            child: Container(
              height: size.height * 0.3,
              width: double.infinity,
              color:
                  const Color(0xFFD91A5B), // Replace with your background color
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                  child: Transform.rotate(
                    angle: 90 *
                        (3.14159265358979323846 /
                            180), // Convert degrees to radians
                    child: Image.asset(
                      "Assets/Screenshot_2023-11-21_213101-removebg-preview.png",
                      width: MediaQuery.of(context).size.width * 0.3,
                      fit: BoxFit.cover,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.06),
        Expanded(
          flex: 5,
          child: _buildMainBody(
            size,
            simpleUIController,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Center(
      child: _buildMainBody(
        size,
        simpleUIController,
      ),
    );
  }

  Widget _buildMainBody(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          size.width > 600 ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        size.width > 600
            ? Container()
            : Container(
                height: size.height * 0.2,
                width: size.width,
                decoration: const BoxDecoration(
                  // color: Color(0xFFD91A5B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                  boxShadow: [
                    /*  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),*/
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                    child: Image.asset(
                      "Assets/Screenshot_2023-11-21_213101-removebg-preview.png",
                      width: MediaQuery.of(context).size.width * 0.3,
                      fit: BoxFit.cover,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ),
        SizedBox(
          height: size.height * 0.02,
        ),
        Center(
            child: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            selectedLanguage == "English"
                ? translate('Se connecter', login_english)
                : selectedLanguage == "Arabic"
                    ? translate('Se connecter', login_arabic)
                    : 'Se connecter',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )),
        const SizedBox(
          height: 10,
        ),
        Center(
            child: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            selectedLanguage == "English"
                ? translate('Connectez-vous pour continuer sur SpaBookin',
                    login_english)
                : selectedLanguage == "Arabic"
                    ? translate('Connectez-vous pour continuer sur SpaBookin',
                        login_arabic)
                    : 'Connectez-vous pour continuer sur SpaBookin',
            style: TextStyle(fontSize: 12),
          ),
        )),
        SizedBox(
          height: size.height * 0.03,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: selectedLanguage == "English"
                        ? translate("Nom d'utilisateur ou Gmail", login_english)
                        : selectedLanguage == "Arabic"
                            ? translate(
                                "Nom d'utilisateur ou Gmail", login_arabic)
                            : "Nom d'utilisateur ou Gmail",
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    } else if (value.length < 4) {
                      return 'At least enter 4 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                TextFormField(
                  style: const TextStyle(fontSize: 16),
                  controller: passwordController,
                  obscureText: see,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_open),
                    suffixIcon: IconButton(
                      icon: Icon(
                        see ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          see = !see;
                        });
                      },
                    ),
                    hintText: selectedLanguage == "English"
                        ? translate('Mot de passe', login_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Mot de passe', login_arabic)
                            : 'Mot de passe',
                    contentPadding: const EdgeInsets.all(16),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 7) {
                      return 'At least enter 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  children: [
                    Checkbox(
                      value:
                          rememberMe, // Add a boolean variable for state management
                      onChanged: (value) {
                        // Implement logic for handling "Remember me"
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    Text(
                      selectedLanguage == "English"
                          ? translate('Se souvenir de moi', login_english)
                          : selectedLanguage == "Arabic"
                              ? translate('Se souvenir de moi', login_arabic)
                              : 'Se souvenir de moi',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Implement logic for "Forgot Password"
                      },
                      child: Text(
                        selectedLanguage == "English"
                            ? translate('Mot de passe oublié ?', login_english)
                            : selectedLanguage == "Arabic"
                                ? translate(
                                    'Mot de passe oublié ?', login_arabic)
                                : 'Mot de passe oublié ?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD91A5B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFD91A5B)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                  ),
                  onPressed: () async {
                    /*  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );*/
                    if (_formKey.currentState!.validate()) {
                      // Construct the API endpoint URL
                      String apiUrl = "$domain2/api/auth/login";

                      Map<String, String> body;

                      bool containsOnlyNumbersAndSymbols(String input) {
                        return RegExp(r'^[0-9+\-*/]+$').hasMatch(input);
                      }

                      if (containsOnlyNumbersAndSymbols(nameController.text)) {
                        body = {
                          "phone_number": nameController.text,
                          "password": passwordController.text,
                        };
                      } else {
                        body = {
                          "email": nameController.text,
                          "password": passwordController.text,
                        };
                      }

                      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
                      try {
                        var response = await http.post(Uri.parse(apiUrl),
                            body: jsonEncode(body),
                            headers: {"Content-Type": "application/json"});
                        // Process the response

                        print(response.statusCode);
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          final Map<String, dynamic> data =
                              json.decode(response.body);
                          if (data['data']['role'] != "Spa owner") {
                            String tokenFromResponse = data['token'];
                            String nameFromResponse = data['data']['name'];
                            String emailFromResponse = data['data']['email'];
                            String phoneFromResponse = data['data']['phone'];
                            String image = data['data']['media']['original_url'];
                            String id = data['data']['id'].toString();

                            SharedPreferences prefs = await SharedPreferences.getInstance();

                            prefs.setString('authToken', tokenFromResponse);
                            prefs.setString('name', nameFromResponse);
                            prefs.setString('email', emailFromResponse);
                            prefs.setString('phone', phoneFromResponse);
                            prefs.setString('id', id);
                            prefs.setString('password', passwordController.text);
                            prefs.setString('image', image);
                            if (widget.comes) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                              );
                            }
                          } else {
                            ElegantNotification.error(
                              animationDuration:
                                  const Duration(milliseconds: 600),
                              width: 360,
                              position: Alignment.bottomCenter,
                              animation: AnimationType.fromBottom,
                              title: const Text('Error'),
                              description:
                                  const Text("votre role n'est pas compatible"),
                              onDismiss: () {},
                            ).show(context);
                          }
                        } else {
                          ElegantNotification.error(
                            animationDuration:
                                const Duration(milliseconds: 600),
                            width: 360,
                            position: Alignment.bottomCenter,
                            animation: AnimationType.fromBottom,
                            title: const Text('Error'),
                            description: const Text(
                                'Échec de la connexion, identifiant ou mot de passe incorrect'),
                            onDismiss: () {},
                          ).show(context);
                        }
                      } catch (e) {
                        print('Error during HTTP request: $e');
                        // Handle the error
                      }
                    } else {}
                  },
                  child: Text(
                    selectedLanguage == "English"
                        ? translate('Connexion', login_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Connexion', login_arabic)
                            : 'Connexion',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      logger.d("click google");

                      // Sign in with Google and wait for it to complete
                      await _handleSignIn();

                      // Wait until _currentUser is not null
                      while (_currentUser == null) {
                        await Future.delayed(Duration(
                            milliseconds: 100)); // Check every 100 milliseconds
                      }

                      String name = "Unknown";
                      String email = "Unknown";

                      // Print current user information
                      print(_currentUser);

                      // Check if user is signed in
                      if (_currentUser != null &&
                          _currentUser!.email.isNotEmpty) {
                        name = _currentUser!.displayName ?? "Unknown";
                        email = _currentUser!.email;
                      }

                      String apiUrl = "$domain2/api/loginWithGoogle";

                      // Prepare the request body
                      Map<String, String> body = {
                        "name": name,
                        "role": "Client",
                        "email": email,
                      };

                      // Make the HTTP request and wait for the response
                      var response = await http.post(
                        Uri.parse(apiUrl),
                        body: jsonEncode(body),
                        headers: {"Content-Type": "application/json"},
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        final Map<String, dynamic> data =json.decode(response.body);
                        logger.d('Token: ${data['token']}');
                        logger.d('Name: ${data['data']['name']}');
                        logger.d('Email: ${data['data']['email']}');
                        logger.d('Phone: ${data['data']['phone']}');
                        logger.d('ID: ${data['data']['id'].toString()}');

                        // Save the data in SharedPreferences
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('authToken', data['token'].toString());
                        prefs.setString('name', data['data']['name'].toString());
                        prefs.setString('email', data['data']['email'].toString());
                        prefs.setString('phone', data['data']['phone'].toString());
                        prefs.setString('id', data['data']['id'].toString());

                        // Navigate based on the condition
                        if (widget.comes) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        }
                      } else {
                        logger.e(response.body);
                        ElegantNotification.error(
                          animationDuration: const Duration(milliseconds: 600),
                          width: 360,
                          position: Alignment.bottomCenter,
                          animation: AnimationType.fromBottom,
                          title: Text('Errorssssss'),
                          description: Text(response.body),
                          onDismiss: () {},
                        ).show(context);
                      }
                    } catch (error) {
                      logger.d("Error: " + error.toString());
                      ElegantNotification.error(
                        animationDuration: const Duration(milliseconds: 600),
                        width: 360,
                        position: Alignment.bottomCenter,
                        animation: AnimationType.fromBottom,
                        title: Text('Error'),
                        description: Text(error.toString()),
                        onDismiss: () {},
                      ).show(context);
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'Assets/download-removebg-preview (26).png', // Add the path to your Google icon
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedLanguage == "English"
                            ? translate('Se connecter avec Google', login_english)
                            : selectedLanguage == "Arabic"
                                ? translate('Sign in with Google', login_arabic)
                                : 'Se connecter avec Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    _formKey.currentState?.reset();
                    simpleUIController.isObscure.value = true;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpView(comes: false)),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: selectedLanguage == "English"
                          ? translate(
                              "Vous n'avez pas de compte ?", login_english)
                          : selectedLanguage == "Arabic"
                              ? translate(
                                  "Vous n'avez pas de compte ?", login_arabic)
                              : "Vous n'avez pas de compte ?",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: " " +
                              (selectedLanguage == "English"
                                  ? translate("Inscription", login_english)
                                  : selectedLanguage == "Arabic"
                                      ? translate("Inscription", login_arabic)
                                      : "Inscription"),
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD91A5B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
