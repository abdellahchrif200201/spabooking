import 'dart:convert';
import 'dart:io';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/signup_tr.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/search_map.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = '';
  String Nom = '';
  String phone = '';
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;
  bool visible = false;
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  String image = '';
  // final bool _isEditingPassword = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _fetchAndStoreBookingDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _emailController.text = prefs.getString('email') ?? '';
    _nameController.text = prefs.getString('name') ?? '';
    _phoneController.text = prefs.getString('phone').toString() == 'null' ? '' : prefs.getString('phone').toString();
    _controller.text = prefs.getString('password') ?? '';
    image = prefs.getString('image') ?? '';
    setState(() {});
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String name = "Name";
  @override
  void initState() {
    super.initState();
    _loadLanguage();

    name = selectedLanguage == "English"
        ? translate('Nom complet', signup_english)
        : selectedLanguage == "Arabic"
            ? translate('Nom complet', signup_arabic)
            : 'Nom complet';
    _fetchAndStoreBookingDetails();
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

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Image.asset(
            "Assets/1-removebg-preview.png",
            height: 30,
            color: const Color(0xFFD91A5B),
          ),
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
              ? translate('Profile', drawer_English)
              : selectedLanguage == "Arabic"
                  ? translate('Profile', drawer_Arabic)
                  : 'Profile'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Trigger image picker when the CircleAvatar is tapped
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFD91A5B),
                          child: ClipOval(
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : image.isNotEmpty
                                    ? Image.network(
                                        image,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'Assets/png-clipart-man-wearing-blue-shirt-illustration-computer-icons-avatar-user-login-avatar-blue-child.png',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEditableTextField(
                        "Name",
                        selectedLanguage == "English"
                            ? translate('Nom complet', signup_english)
                            : selectedLanguage == "Arabic"
                                ? translate('Nom complet', signup_arabic)
                                : 'Nom complet',
                        _nameController,
                        initialValue: Nom,
                        isEditing: _isEditingName),
                    const SizedBox(height: 16),
                    _buildEditableTextField(
                        "Email",
                        selectedLanguage == "English"
                            ? translate('Email', signup_english)
                            : selectedLanguage == "Arabic"
                                ? translate('Email', signup_arabic)
                                : 'Email',
                        _emailController,
                        initialValue: email,
                        isEditing: _isEditingEmail),
                    const SizedBox(height: 16),
                    _buildEditableTextField(
                      "Phone Number",
                      selectedLanguage == "English"
                          ? translate('Téléphone', signup_english)
                          : selectedLanguage == "Arabic"
                              ? translate('Téléphone', signup_arabic)
                              : 'Téléphone',
                      _phoneController,
                      initialValue: phone,
                      isEditing: _isEditingPhone,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller,
                            obscureText: !visible,
                            readOnly: !_isEditing,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    visible = !visible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              errorText: ((_controller.text.length < 6)) ? 'Password should be at least 6 characters' : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditing ? Icons.edit : Icons.edit_off,
                            color: _isEditing ? Colors.green : Colors.red,
                          ),
                          onPressed: () {
                            if (!_isEditing) {
                              _showConfirmationDialog();
                            } else {
                              setState(() {
                                _isEditing = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildStyledButton(
                        selectedLanguage == "English"
                            ? translate('Enregistrer les modifications', signup_english)
                            : selectedLanguage == "Arabic"
                                ? translate('Enregistrer les modifications', signup_arabic)
                                : 'Enregistrer les modifications', onPressed: () {
                      saveChanges();
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0), // Add border radius
                              ),
                              content: Container(
                                  height: 85,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.delete, color: Colors.red, size: 25), // Add delete icon
                                          SizedBox(width: 8),
                                          Text(
                                            "Supprimer le compte",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold, // Make the text bold
                                              fontSize: 18, // Increase font size
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "Êtes-vous sûr(e) de vouloir supprimer votre compte ?",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  )),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text('Annuler', style: TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await deleteProfile();
                                      },
                                      child: Text('Supprimer'),
                                      style: ElevatedButton.styleFrom(
                                          // primary: const Color.fromARGB(
                                          //     255,
                                          //     171,
                                          //     27,
                                          //     16), // Change confirm button color to red
                                          // onPrimary: Colors
                                          //     .white, // Change text color to white
                                          ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Supprimer le compte"),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTextField(String label, String labelText, TextEditingController controller, {String? initialValue, bool obscureText = false, required bool isEditing}) {
    String? errorText;
    switch (label) {
      case 'Name':
        if ((_nameController.text.length < 6)) {
          errorText = 'Le nom doit comporter au moins 6 caractères';
        }
        break;
      case 'Email':
        // Add conditions for email if needed
        break;
      case 'Phone Number':
        if ((_phoneController.text.length < 9)) {
          errorText = 'Numéro de téléphone invalide (doit contenir 10 chiffres)';
        }
        break;
      // Add other cases as needed
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: labelText == 'Phone Number' ? TextInputType.phone : null,
            controller: controller,
            readOnly: !isEditing,
            obscureText: obscureText,
            decoration: InputDecoration(
              errorText: errorText,
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            isEditing ? Icons.edit : Icons.edit_off,
            color: isEditing ? Colors.green : Colors.red,
          ),
          onPressed: () {
            setState(() {
              switch (label) {
                case 'Name':
                  _isEditingName = !_isEditingName;
                  break;
                case 'Email':
                  _isEditingEmail = !_isEditingEmail;
                  break;
                case 'Phone Number':
                  _isEditingPhone = !_isEditingPhone;
                  break;
                // Add other cases as needed
              }
            });
          },
        ),
      ],
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

  Future<void> _showConfirmationDialog() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password Change'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to change the password?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        visible = true;
                      });
                      Navigator.of(context).pop(true); // User confirmed
                    },
                    child: const Text('Confirm'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // User canceled
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );

    if (confirm) {
      // User confirmed, now toggle the editing state
      setState(() {
        _isEditing = !_isEditing;
      });
    }
  }

  Future<void> saveChanges() async {
    if (_validateFields()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? localId = prefs.getString('id');
      String? oldName = prefs.getString('name');
      String? oldPhone = prefs.getString('phone');
      String? oldPassword = prefs.getString('password');
      String? authToken = prefs.getString('authToken');
      // String? image = prefs.getString("image");

      if (authToken == null || localId == null) {
        logger.e('Authentication token or user ID not found');
        return;
      }

      authToken = "Bearer $authToken";
      String? newName = _nameController.text;
      String? newPhone = _phoneController.text;
      String? newPassword = _controller.text;

      logger.d(authToken);

      // Creating the request body
      Map<String, String> fieldsToUpdate = {"user_id": localId};

      if (oldName != newName) {
        fieldsToUpdate["name"] = newName;
      }

      if (oldPhone != newPhone) {
        fieldsToUpdate["phone"] = newPhone;
      }

      if (oldPassword != newPassword) {
        fieldsToUpdate["password"] = newPassword;
      }

      logger.d(fieldsToUpdate);

      if (fieldsToUpdate.length > 1 || _image != null) {
        try {
          var requestBody = fieldsToUpdate;

          // Convert the image to Base64 and add it to the request body if present
          if (_image != null) {
            logger.d("Image found");
            List<int> imageBytes = await _image!.readAsBytes();
            String base64Image = base64Encode(imageBytes);
            requestBody['image'] = base64Image;
          }

          // Make the POST request
          var response = await http.post(
            Uri.parse('$domain2/api/auth/editProfil'),
            headers: {
              'Authorization': authToken,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          );

          // Handle the response
          if (response.statusCode == 200 || response.statusCode == 201) {
            logger.d("API call successful");
            logger.d("Response body: ${response.body}");

            SharedPreferences prefs = await SharedPreferences.getInstance();

            // prefs.setString('authToken', tokenFromResponse);
           
           
            // prefs.setString('image', image);

            if (oldName != newName) {
              prefs.setString('name', newName);
            }

            if (oldPhone != newPhone) {
              prefs.setString('phone', newPhone);
            }

            if (oldPassword != newPassword) {
              prefs.setString('password', newPassword);
            }

            ElegantNotification.success(
              animationDuration: const Duration(milliseconds: 600),
              width: 360,
              position: Alignment.bottomCenter,
              animation: AnimationType.fromBottom,
              title: const Text('succès'),
              description: const Text('Profil mis à jour avec succès'),
            ).show(context);
          } else {
            logger.e("API call failed with status code ${response.statusCode}");
            logger.e("Response body: ${response.body}");
            ElegantNotification.error(
              animationDuration: const Duration(milliseconds: 600),
              width: 360,
              position: Alignment.bottomCenter,
              animation: AnimationType.fromBottom,
              title: const Text('Error'),
              description: Text('Failed to save changes: ${response.body}'),
            ).show(context);
          }
        } catch (e) {
          logger.e("Error during API call: $e");
          ElegantNotification.error(
            animationDuration: const Duration(milliseconds: 600),
            width: 360,
            position: Alignment.bottomCenter,
            animation: AnimationType.fromBottom,
            title: const Text('Error'),
            description: const Text('Failed to save changes'),
          ).show(context);
        }
      } else {
        logger.d("No changes to save");
        ElegantNotification.info(
          animationDuration: const Duration(milliseconds: 600),
          width: 360,
          position: Alignment.bottomCenter,
          animation: AnimationType.fromBottom,
          title: const Text('Info'),
          description: const Text('No changes detected to save'),
        ).show(context);
      }
    } else {
      ElegantNotification.error(
        animationDuration: const Duration(milliseconds: 600),
        width: 360,
        position: Alignment.bottomCenter,
        animation: AnimationType.fromBottom,
        title: const Text('Error'),
        description: const Text('Verify fields condition'),
        onDismiss: () {},
      ).show(context);
    }
  }

  bool _validateFields() {
    return _nameController.text.length > 5 && _phoneController.text.length > 8;
  }

  deleteProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = "Bearer " + prefs.getString('authToken').toString();
    // If the token exists, make the API request
    if (authToken != null) {
      try {
        logger.d(authToken);

        final response = await http.post(
          Uri.parse('$domain2/api/deleteAccountUser'),
          headers: {'Authorization': authToken},
        );
        logger.d(response.statusCode);
        logger.d(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Compte bien supprimé"),
            ),
          );
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginView(
                        comes: false,
                      )),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Impossible de supprimer le compte"),
            ),
          );
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginView(
                        comes: false,
                      )),
            );
          });
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossible de supprimer le compte"),
          ),
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoginView(
                      comes: false,
                    )),
          );
        });
      }
    } else {
      logger.d('Error: Auth token not found');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginView(
                  comes: false,
                )),
      );
    }
  }
}
