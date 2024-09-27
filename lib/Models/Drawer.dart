import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/LoginTR.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/screens/Contact.dart';
import 'package:spa/screens/List_salon.dart';
import 'package:spa/screens/Profile.dart';
import 'package:spa/screens/boocked.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/parent_chat.dart';
import 'package:spa/screens/salon_list_favoris.dart';
import 'package:spa/screens/search_map.dart';
import 'package:flag/flag.dart';
import 'package:spa/screens/signUp_view.dart';

class CustomDrawer extends StatefulWidget {
  final String currentPage;
  const CustomDrawer({required this.currentPage});
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String selectedLanguage = '';
  String name = '';
  String email = '';
  String image = '';
  bool loggedIn = false;
  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localId = prefs.getString('id');
    if (localId != null) {
      loggedIn = true;
    }
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      image = prefs.getString('image') ?? '';
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'Frensh';
    });
  }

  Future<void> _saveLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedLanguage = language;
    });
    await prefs.setString('selectedLanguage', language);
  }

  String translate(String key, Map<String, String> translationMap) {
    return translationMap[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFD91A5B),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
            
          ),
        ),
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            DrawerHeader(
              margin: const EdgeInsets.only(right: 10, left: 10),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 250, 110, 157),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFD91A5B),
                    child: ClipOval(
                      child: image.isNotEmpty ? Image.network(
                              image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ) : Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTx3WjXK1quQwF5dl6PsQFSQOa1WJrl-45LcODj0k7w5A&s",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (name != '')
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  if (email != '')
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Accueil', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Accueil', drawer_Arabic)
                        : 'Accueil',
                Icons.home, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Explore salon', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Explore salon', drawer_Arabic)
                        : 'Explore salon',
                Icons.place, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyMap()),
              );
            }),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Tout les salon', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Tout les salon', drawer_Arabic)
                        : 'Tout les salon',
                Icons.explore, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ListSalonFavoris()),
              );
            }),
            const Divider(color: Colors.white),

            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Profile', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Profile', drawer_Arabic)
                        : 'Profile',
                Icons.account_circle, () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? localId = prefs.getString('id');
              if (localId != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color(0xFFD91A5B), // Add border color here
                        ),
                      ),
                      title: Text(
                        selectedLanguage == "English"
                            ? "You are not signed in!"
                            : selectedLanguage == "Arabic"
                                ? "أنت غير مسجل الدخول!"
                                : "Vous n'êtes pas connecté!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFD91A5B)),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.login), // Add the login icon
                                label: Text(selectedLanguage == "English"
                                    ? "Sign In"
                                    : selectedLanguage == "Arabic"
                                        ? "تسجيل الدخول"
                                        : "Connexion"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.person_add), // Add the sign-up icon
                                label: Text(
                                  selectedLanguage == "English"
                                      ? "Sign Up"
                                      : selectedLanguage == "Arabic"
                                          ? "التسجيل"
                                          : "S'inscrire",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Favoris', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Favoris', drawer_Arabic)
                        : 'Favoris',
                Icons.favorite, () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? localId = prefs.getString('id');
              if (localId != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListSalon()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color(0xFFD91A5B), // Add border color here
                        ),
                      ),
                      title: Text(
                        selectedLanguage == "English"
                            ? "You are not signed in!"
                            : selectedLanguage == "Arabic"
                                ? "أنت غير مسجل الدخول!"
                                : "Vous n'êtes pas connecté!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFD91A5B)),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.login), // Add the login icon
                                label: Text(selectedLanguage == "English"
                                    ? "Sign In"
                                    : selectedLanguage == "Arabic"
                                        ? "تسجيل الدخول"
                                        : "Connexion"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.person_add), // Add the sign-up icon
                                label: Text(
                                  selectedLanguage == "English"
                                      ? "Sign Up"
                                      : selectedLanguage == "Arabic"
                                          ? "التسجيل"
                                          : "S'inscrire",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Réservation', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Réservation', drawer_Arabic)
                        : 'Réservation',
                Icons.schedule, () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? localId = prefs.getString('id');
              if (localId != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Booked()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color(0xFFD91A5B), // Add border color here
                        ),
                      ),
                      title: Text(
                        selectedLanguage == "English"
                            ? "You are not signed in!"
                            : selectedLanguage == "Arabic"
                                ? "أنت غير مسجل الدخول!"
                                : "Vous n'êtes pas connecté!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFD91A5B)),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.login), // Add the login icon
                                label: Text(selectedLanguage == "English"
                                    ? "Sign In"
                                    : selectedLanguage == "Arabic"
                                        ? "تسجيل الدخول"
                                        : "Connexion"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.person_add), // Add the sign-up icon
                                label: Text(
                                  selectedLanguage == "English"
                                      ? "Sign Up"
                                      : selectedLanguage == "Arabic"
                                          ? "التسجيل"
                                          : "S'inscrire",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Messagerie', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Messagerie', drawer_Arabic)
                        : 'Messagerie',
                Icons.message, () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? localId = prefs.getString('id');
              if (localId != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListPage()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color(0xFFD91A5B), // Add border color here
                        ),
                      ),
                      title: Text(
                        selectedLanguage == "English"
                            ? "You are not signed in!"
                            : selectedLanguage == "Arabic"
                                ? "أنت غير مسجل الدخول!"
                                : "Vous n'êtes pas connecté!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFD91A5B)),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.login), // Add the login icon
                                label: Text(selectedLanguage == "English"
                                    ? "Sign In"
                                    : selectedLanguage == "Arabic"
                                        ? "تسجيل الدخول"
                                        : "Connexion"),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpView(comes: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.person_add), // Add the sign-up icon
                                label: Text(
                                  selectedLanguage == "English"
                                      ? "Sign Up"
                                      : selectedLanguage == "Arabic"
                                          ? "التسجيل"
                                          : "S'inscrire",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }),

            const Divider(color: Colors.white),

            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Contactez-nous', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Contactez-nous', drawer_Arabic)
                        : 'Contactez-nous',
                Icons.mail, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            }),
            _buildSubSection(
                false,
                selectedLanguage == "English"
                    ? translate('Choisir language', drawer_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Choisir language', drawer_Arabic)
                        : 'Choisir language',
                Icons.language, () {
              _showLanguageDialog(context);
            }),

//  const Divider(color: Colors.white),

            _buildSubSection(
                false,
                loggedIn
                    ? (selectedLanguage == "English"
                        ? translate('Déconnexion', drawer_English)
                        : selectedLanguage == "Arabic"
                            ? translate('Déconnexion', drawer_Arabic)
                            : 'Déconnexion')
                    : (selectedLanguage == "English"
                        ? translate('Connexion', login_english)
                        : selectedLanguage == "Arabic"
                            ? translate('Connexion', login_arabic)
                            : 'Connexion'),
                Icons.logout, () async {
              GoogleSignInAccount? account = await GoogleSignIn().signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginView(comes: false)),
              );
            }),

            const SizedBox(height: 50),
// Add space at the end of the drawer
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> subSections) {
    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      leading: Icon(icon, color: Colors.white),
      children: subSections,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            selectedLanguage == "English"
                ? translate('Choisir une langue', drawer_English)
                : selectedLanguage == "Arabic"
                    ? translate('Choisir une langue', drawer_Arabic)
                    : 'Choisir une langue',
          ),
          children: [
            _buildLanguageOption(
              'English',
              '🇺🇸',
              Flag.fromCode(
                FlagsCode.US,
                height: 20,
                width: 30,
                fit: BoxFit.fill,
              ),
            ),
            _buildLanguageOption(
              'Arabic',
              '🇦🇪',
              Flag.fromCode(
                FlagsCode.MA,
                height: 20,
                width: 30,
                fit: BoxFit.fill,
              ),
            ),
            _buildLanguageOption(
              'French',
              '🇫🇷',
              Container(
                  width: 30,
                  child: Flag.fromCode(
                    FlagsCode.FR,
                    height: 20,
                    width: 30,
                    fit: BoxFit.fill,
                  )),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String flag, Widget child) {
    String languageCode;
    String showlanguage = '';
    if (language == 'English') {
      showlanguage = selectedLanguage == 'Arabic'
          ? "الإنجليزية"
          : selectedLanguage == 'English'
              ? language
              : "Anglais";
      languageCode = 'English';
    } else if (language == 'Arabic') {
      showlanguage = selectedLanguage == 'Arabic'
          ? "العربية"
          : selectedLanguage == 'English'
              ? language
              : "Arabe";

      languageCode = 'Arabic';
    } else {
      showlanguage = selectedLanguage == 'Arabic'
          ? "الفرنسية"
          : selectedLanguage == 'English'
              ? language
              : "Français";
      languageCode = 'French';
    }

    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        _saveLanguage(languageCode);
      },
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: child),
          Text(showlanguage),
          const SizedBox(
            width: 20,
          ),
          if (selectedLanguage == language)
            const Icon(
              Icons.check,
              color: Colors.pink,
            ),
        ],
      ),
    );
  }

  Widget _buildSubSection(bool khez, String title, IconData icon, VoidCallback onTap) {
    return Stack(
      children: [
        if (widget.currentPage == title) // Show white container only for the selected option
          Positioned.fill(
              child: Container(
            margin: const EdgeInsets.only(right: 50.0, top: 3, bottom: 3), // Add margin to the right
            decoration: const BoxDecoration(
              color: Colors.white, // Pink color
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              ),
            ),
          )),
        Container(
          margin: EdgeInsets.only(left: khez ? 30 : 0),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: widget.currentPage == title ? const Color(0xFFD91A5B) : Colors.white,
              ),
            ),
            leading: Icon(
              icon,
              color: widget.currentPage == title ? const Color(0xFFD91A5B) : Colors.white,
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
