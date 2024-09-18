import 'dart:convert';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/signup_tr.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/login_view.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';

class SignUpView extends StatefulWidget {
  final bool comes;
  SignUpView({Key? key, required this.comes}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool acceptConditions = false;
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences _prefs;
  String selectedLanguage = '';
  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefs.getString('selectedLanguage') ?? 'Frensh';
    });
  }

  Future<void> _saveLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });
    await _prefs.setString('selectedLanguage', language);
  }

  String translate(String key, Map<String, String> translationMap) {
    print(translationMap[key]);
    return translationMap[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildLargeScreen(size);
              } else {
                return _buildSmallScreen(size);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreen(Size size) {
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
          child: _buildMainBody(size),
        ),
      ],
    );
  }

  Widget _buildSmallScreen(Size size) {
    return Center(
      child: _buildMainBody(size),
    );
  }

  Widget _buildMainBody(Size size) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: size.height * 0.2,
          width: size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
            boxShadow: [
              // Your shadow configuration here
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
                  ? translate('S\'inscrire', signup_english)
                  : selectedLanguage == "Arabic"
                      ? translate('S\'inscrire', signup_arabic)
                      : 'S\'inscrire',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              selectedLanguage == "English"
                  ? translate('Créez un compte pour commencer', signup_english)
                  : selectedLanguage == "Arabic"
                      ? translate(
                          'Créez un compte pour commencer', signup_arabic)
                      : 'Créez un compte pour commencer',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: selectedLanguage == "English"
                        ? translate('Nom complet', signup_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Nom complet', signup_arabic)
                            : 'Nom complet',
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Veuillez entrer votre nom complet';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                TextFormField(
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    hintText: selectedLanguage == "English"
                        ? translate('Téléphone', signup_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Téléphone', signup_arabic)
                            : 'Téléphone',
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 8) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                TextFormField(
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: selectedLanguage == "English"
                        ? translate('Email', signup_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Email', signup_arabic)
                            : 'Email',
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Veuillez entrer votre adresse e-mail';
                    } else if (!value.contains('@')) {
                      return 'Veuillez entrer une adresse e-mail valide';
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
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: selectedLanguage == "English"
                        ? translate('Mot de passe', signup_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Mot de passe', signup_arabic)
                            : 'Mot de passe',
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Veuillez entrer un mot de passe';
                    } else if (value.length < 7) {
                      return 'Veuillez entrer au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                TextFormField(
                  style: const TextStyle(fontSize: 16),
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: selectedLanguage == "English"
                        ? translate('Confirmer le mot de passe', signup_english)
                        : selectedLanguage == "Arabic"
                            ? translate(
                                'Confirmer le mot de passe', signup_arabic)
                            : 'Confirmer le mot de passe',
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Veuillez confirmer votre mot de passe';
                    } else if (value != passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: acceptConditions,
                      onChanged: (value) {
                        setState(() {
                          acceptConditions = value!;
                        });
                      },
                    ),
                    Text(
                      selectedLanguage == "English"
                          ? translate(
                              'J\'accepte les conditions', signup_english)
                          : selectedLanguage == "Arabic"
                              ? translate(
                                  'J\'accepte les conditions', signup_arabic)
                              : 'J\'accepte les conditions',
                      style: TextStyle(fontSize: 16),
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
                    if (_formKey.currentState!.validate()) {
                      await save_user();
                    }
                  },
                  child: Text(
                    selectedLanguage == "English"
                        ? translate('S\'inscrire', signup_english)
                        : selectedLanguage == "Arabic"
                            ? translate('S\'inscrire', signup_arabic)
                            : 'S\'inscrire',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                /* OutlinedButton(
                  onPressed: () {
                    // Implement Google authentication logic
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
                        'Assets/download-removebg-preview (26).png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedLanguage == "English"
                            ? translate(
                                'S\'inscrire avec Google', signup_english)
                            : selectedLanguage == "Arabic"
                                ? translate(
                                    'S\'inscrire avec Google', signup_arabic)
                                : 'S\'inscrire avec Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),*/
                SizedBox(
                  height: size.height * 0.03,
                ),
                Center(
                    child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    nameController.clear();
                    phoneController.clear();
                    emailController.clear();
                    passwordController.clear();
                    confirmPasswordController.clear();
                    _formKey.currentState?.reset();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginView(comes: false)),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: selectedLanguage == "English"
                          ? translate('Déjà un compte?', signup_english)
                          : selectedLanguage == "Arabic"
                              ? translate('Déjà un compte?', signup_arabic)
                              : 'Déjà un compte?',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: selectedLanguage == "English"
                              ? translate("Se connecter", signup_english)
                              : selectedLanguage == "Arabic"
                                  ? translate("Se connecter", signup_arabic)
                                  : "Se connecter",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD91A5B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Future<void> save_user() async {
    if (nameController.text.length > 5 &&
        phoneController.text.length > 8 &&
        passwordController.text.length > 6) {
      String? newName = nameController.text;
      String? Email = emailController.text;
      String? newPhone = phoneController.text;
      String? newPassword = passwordController.text;

      try {
        final response = await http.post(
          Uri.parse('$domain2/api/auth/register'),
          body: {
            "name": newName,
            "phone": newPhone,
            "email": Email,
            "password": newPassword,
            "role": "Client"
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(response.body);
          String tokenFromResponse = data['token'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print('Before saving to SharedPreferences:');
          print('authToken: $tokenFromResponse');
          print('name: $newName');
          print('email: $Email');
          print('phone: $newPhone');
          print('id: ${data['data']['id']}');
          print('password: $newPassword');
          prefs.setString('authToken', tokenFromResponse);
          prefs.setString('name', newName);
          prefs.setString('email', Email);
          prefs.setString('phone', newPhone);
          prefs.setString('id', data['data']['id'].toString());
          prefs.setString('password', newPassword);
          print("API call successful");
          nameController.clear();
          phoneController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          _formKey.currentState?.reset();
          if (widget.comes) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          ElegantNotification.error(
            animationDuration: const Duration(milliseconds: 600),
            width: 360,
            position: Alignment.bottomCenter,
            animation: AnimationType.fromBottom,
            title: const Text('Error'),
            description: Text('${response.body}'),
            onDismiss: () {},
          ).show(context);
          print(
              "API call failed with status code  ${response.statusCode} : ${response.body}");
        }
      } catch (e) {
        ElegantNotification.error(
          animationDuration: const Duration(milliseconds: 600),
          width: 360,
          position: Alignment.bottomCenter,
          animation: AnimationType.fromBottom,
          title: const Text('Error'),
          description: Text("Error during API call: $e"),
          onDismiss: () {},
        ).show(context);
        print("Error during API call: $e");
      }
    } else {
      ElegantNotification.error(
        animationDuration: const Duration(milliseconds: 600),
        width: 360,
        position: Alignment.bottomCenter,
        animation: AnimationType.fromBottom,
        title: const Text('Error'),
        description: const Text('verify feilds codition'),
        onDismiss: () {},
      ).show(context);
    }
  }
}
