import 'dart:convert';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/screens/search_map.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController message = TextEditingController();
  String? option = null;
  Future<void> loadSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // Retrieve values from shared preferences or use default values if not found
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLanguage();

    loadSharedPrefs();
  }

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
    return translationMap[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Center(
            child: Image.asset("Assets/1-removebg-preview.png",
                height: 30, color: const Color(0xFFD91A5B)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFD91A5B)),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.map, color: Color(0xFFD91A5B)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyMap()),
                );
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Color(0xFFD91A5B)),
        ),
        drawer: CustomDrawer(
            currentPage: selectedLanguage == "English"
                ? translate('Contactez-nous', drawer_English)
                : selectedLanguage == "Arabic"
                    ? translate('Contactez-nous', drawer_Arabic)
                    : 'Contactez-nous'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                      selectedLanguage == "English"
                          ? translate('Nom', home_English)
                          : selectedLanguage == "Arabic"
                              ? translate('Nom', home_Arabic)
                              : 'Nom',
                      nameController),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                      selectedLanguage == "English"
                          ? translate('E-mail', home_English)
                          : selectedLanguage == "Arabic"
                              ? translate('E-mail', home_Arabic)
                              : 'E-mail',
                      emailController),
                  const SizedBox(height: 16),
                  _buildStyledDropdownButtonFormField(),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                      selectedLanguage == "English"
                          ? translate('Message', home_English)
                          : selectedLanguage == "Arabic"
                              ? translate('Message', home_Arabic)
                              : 'Message',
                      message,
                      maxLines: 4),
                  const SizedBox(height: 16),
                  _buildStyledButton(
                      selectedLanguage == "English"
                          ? translate('Envoyer', home_English)
                          : selectedLanguage == "Arabic"
                              ? translate('Envoyer', home_Arabic)
                              : 'Envoyer', onPressed: () async {
                    final String apiUrl = "$domain2/api/sendMessageOffline";

                    String name = nameController.text;
                    String email = emailController.text;
                    String? selectedDropdownValue = option;
                    String messageText = message.text;

                    print(selectedDropdownValue);
                    if (name.isEmpty ||
                        email.isEmpty ||
                        selectedDropdownValue == null ||
                        messageText.isEmpty) {
                      ElegantNotification.error(
                        animationDuration: const Duration(milliseconds: 600),
                        width: 360,
                        position: Alignment.bottomCenter,
                        animation: AnimationType.fromBottom,
                        title: const Text('Error'),
                        description: const Text('Invalid format'),
                        onDismiss: () {},
                      ).show(context);
                      return;
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? authToken =
                        "Bearer " + prefs.getString('authToken').toString();
                    Map<String, dynamic> requestBody = {
                      "message": messageText,
                      "request_type": selectedDropdownValue.toString(),
                      "user_offline": jsonEncode({
                        'name': name,
                        'email': email,
                        'phone_number': prefs.getString('phone').toString(),
                      })
                    };

                    try {
                      var response = await http.post(
                        Uri.parse(apiUrl),
                        body: requestBody,
                        headers: {
                          'Authorization': authToken,
                          //  "Content-Type": "application/json"
                        },
                      );

                      // Check the status code directly
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        // Handle success
                        print("API call successful");
                        ElegantNotification.success(
                          animationDuration: const Duration(milliseconds: 600),
                          width: 360,
                          position: Alignment.bottomCenter,
                          animation: AnimationType.fromBottom,
                          title: const Text('OK'),
                          description: const Text('Bien envoyer'),
                          onDismiss: () {},
                        ).show(context);
                      } else {
                        ElegantNotification.error(
                          animationDuration: const Duration(milliseconds: 600),
                          width: 360,
                          position: Alignment.bottomCenter,
                          animation: AnimationType.fromBottom,
                          title: const Text('Error'),
                          description: const Text('Probleme'),
                          onDismiss: () {},
                        ).show(context);
                        print(requestBody);
                        print(
                            "API call failed with status code ${response.body}");
                      }
                    } catch (e) {
                      // Handle other exceptions
                      print("Exception during API call: $e");
                    }
                  }),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFD91A5B), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle(selectedLanguage == "English"
                            ? translate('Informations de contact', home_English)
                            : selectedLanguage == "Arabic"
                                ? translate(
                                    'Informations de contact', home_Arabic)
                                : 'Informations de contact'),
                        const SizedBox(height: 16),

                        _buildContactInfoTile(Icons.phone, ' 06 67 58 58 19'),
                        //  const SizedBox(height: 8),
                        _buildContactInfoTile(
                            Icons.email, 'contact@spabooking.pro'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  /*   SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target:
                            LatLng(37.7749, -122.4194), // Example coordinates
                        zoom: 14.0,
                      ),
                      markers: {
                        const Marker(
                          markerId: MarkerId('your_location_marker'),
                          position:
                              LatLng(37.7749, -122.4194), // Example coordinates
                          infoWindow: InfoWindow(
                            title: 'Your Location',
                            snippet: 'This is your location',
                          ),
                        ),
                      },
                    ),
                  ),*/
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildStyledTextField(
      String labelText, TextEditingController controller,
      {int? maxLines}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildStyledDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      items: ['Support commercial', 'Support technique', 'Support client']
          .map((type) => DropdownMenuItem<String>(
                child: Text(type),
                value: type,
              ))
          .toList(),
      decoration: InputDecoration(
        labelText: selectedLanguage == "English"
            ? translate('Type', home_English)
            : selectedLanguage == "Arabic"
                ? translate('Type', home_Arabic)
                : 'Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: (value) {
        setState(() {
          option = value;
        });
      },
    );
  }

  Widget _buildStyledButton(String label, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        // primary: Colors.pink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
        child: Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD91A5B)),
    ));
  }

  Widget _buildContactInfoTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFD91A5B),
      ),
      title: Text(text),
    );
  }
}
