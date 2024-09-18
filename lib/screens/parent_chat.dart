import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/page_transltion/messages.dart';
// import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
// import 'package:html/parser.dart' show parse;
import 'package:spa/screens/chat_details.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/signUp_view.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatListItem> chatListOrigine = [];

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

  String translate(
      String key, Map<String, String> Arabic, Map<String, String> Eglish) {
    if (selectedLanguage == "English") {
      return Eglish[key] ?? key;
    } else if (selectedLanguage == "Arabic") {
      return Arabic[key] ?? key;
    } else {
      return key;
    }
  }

  bool loading = true;

  Future<void> _fetchAllChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localId = prefs.getString('id').toString();
    print("id is " + localId);
    try {
      final response = await http.post(
        Uri.parse('$domain2/api/getChatsParClientId'),
        body: {
          "client_id": localId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['chat'] != null) {
          List<dynamic> allChatList = data['chat'];

          List<ChatListItem> chatListItems = allChatList.map((chatData) {
            return ChatListItem.fromJson(chatData);
          }).toList();

          // Now, chatListItems contains a list of ChatListItem objects
          // Do whatever you need to do with the list, such as storing it in state or using it further.

          // Example: Assuming chatListItems is a state variable
          setState(() {
            // Assuming you have a List<ChatListItem> chatListItems in your state
            chatListOrigine = chatListItems;
            loading = false;
          });
        } else {
          print('Error: Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    setState(() {
      loading = false;
    });
    for (int i = 0; i < chatListOrigine.length; i++) {
      // Call the second API to get the last message for each chat
      final secondApiResponse = await http.post(
        Uri.parse('$domain2/api/getChatParSpaOwnerId'),
        body: {"client_id": localId, "spaOwner": chatListOrigine[i].id_salon},
      );
      if (secondApiResponse.statusCode == 200 ||
          secondApiResponse.statusCode == 201) {
        final List<dynamic> secondApiData = json.decode(secondApiResponse.body);
        final DateTime updatedAt =
            DateTime.parse(secondApiData[0]['updated_at']);
        final String formattedTime = _formatLastMessageTime(updatedAt);
        if (secondApiData.isNotEmpty) {
          // Update the last message for the current chat item
          chatListOrigine[i].lastMessage =
              secondApiData[0]['message'].toString();
          chatListOrigine[i].lastMessageTime = formattedTime;
        }
      }
    }
    for (int i = 0; i < chatListOrigine.length; i++) {
      final salonApiResponse = await http.post(
        Uri.parse('$domain2/api/getSalonByUserId'),
        body: {"user_id": chatListOrigine[i].id_salon, "role": "spaOwner"},
      );

      if (salonApiResponse.statusCode == 200) {
        final Map<String, dynamic> salonData =
            json.decode(salonApiResponse.body);
        if (salonData['status'] == true && salonData['salons'] != null) {
          List<dynamic> salons = salonData['salons'];

          // Assuming the structure of the salon data, update the chatListItems
          // with the name and image information
          if (salons.isNotEmpty) {
            chatListOrigine[i].salonName = salons[0]['name'].toString();
            chatListOrigine[i].friendName = salons[0]['name'].toString();
            chatListOrigine[i].friendImage =
                "$domain2/storage/" + salons[0]['logo'].toString();
          }
        }
      }
    }

    setState(() {
      chatListOrigine = chatListOrigine;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchAllChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
          currentPage: translate('Messagerie', drawer_Arabic, drawer_English)),
      appBar: AppBar(
        title: Text(
            translate('Votre discussion', messagee_Arabic, messagee_English)),
      ),
      body: loading
          ? JumpingDots(
              color: Color(0xFFD91A5B),
              radius: 10,
              numberOfDots: 3,
              animationDuration: Duration(milliseconds: 200),
            )
          : chatListOrigine.isEmpty
              ? Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 48,
                          color: Color(0xFFD91A5B).withOpacity(0.8),
                        ),
                        SizedBox(height: 16),
                        Text(
                          translate("Vous n'avez aucune discussion disponible",
                              home_Arabic, home_English),
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFD91A5B),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: chatListOrigine.length,
                  itemBuilder: (context, index) {
                    return _buildChatTile(context, chatListOrigine[index]);
                  },
                ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatListItem chatItem) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chatItem.friendImage), // Use NetworkImage
        radius: 25,
      ),
      title: Text(
        chatItem.friendName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(chatItem.lastMessage),
      trailing: Text(chatItem.lastMessageTime),
      onTap: () async {
        print(chatItem.id_salon);
        print(chatItem.salonName);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? localId = prefs.getString('id');
        if (localId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                  idsalon: chatItem.id_salon, name: chatItem.salonName),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(
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
                  style: TextStyle(color: Color(0xFFD91A5B)),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
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
                          icon: Icon(Icons.login), // Add the login icon
                          label: Text(selectedLanguage == "English"
                              ? "Sign In"
                              : selectedLanguage == "Arabic"
                                  ? "تسجيل الدخول"
                                  : "Connexion"),
                        ),
                        SizedBox(
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
                          icon: Icon(Icons.person_add), // Add the sign-up icon
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
      },
    );
  }
}

class ChatListItem {
  String salonName;
  String friendName;
  String friendImage;
  String lastMessage;
  String lastMessageTime;
  final String id_salon;
  final List<Message> messages;

  ChatListItem({
    required this.salonName,
    required this.friendName,
    required this.friendImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.id_salon,
    required this.messages,
  });
  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final DateTime updatedAt = DateTime.parse(user['updated_at']);
    final String formattedTime = _formatLastMessageTime(updatedAt);
    print(user['id'].toString());
    List<dynamic> mediaList = user['media'] as List<dynamic>;

    return ChatListItem(
      id_salon: user['id'].toString(),
      salonName: '',
      friendName: '',
      friendImage: '',
      lastMessage: '',
      lastMessageTime: formattedTime,

      messages: [], // You need to parse messages here if available
    );
  }
}

String _formatLastMessageTime(DateTime updatedAt) {
  final now = DateTime.now();
  final difference = now.difference(updatedAt);

  if (difference.inDays > 0) {
    return 'il y a ${difference.inDays} j';
  } else if (difference.inHours > 0) {
    return 'il y a ${difference.inHours} h';
  } else if (difference.inMinutes > 0) {
    return 'il y a ${difference.inMinutes} min';
  } else {
    return 'il y a quelques secondes';
  }
}

class Message {
  final String text;
  final String sender;

  Message({required this.text, required this.sender});
}
