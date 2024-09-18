import 'dart:convert';
import 'dart:io';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/messages.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';

class ChatPage extends StatefulWidget {
  final String idsalon;
  final String name;

  ChatPage({required this.idsalon, required this.name}) : super();

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> chatMessages = [];
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

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchAllChats();
  }

  bool loading = true;
  Future<void> _fetchAllChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localId = prefs.getString('id').toString();
    print(localId);
    print(widget.idsalon);
    try {
      final response = await http.post(
        Uri.parse('$domain2/api/getChatParSpaOwnerId'),
        body: {"spaOwner": widget.idsalon, "client_id": localId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          List<Map<String, dynamic>> newChatMessages = data.map((chatData) {
            return {
              'text': chatData['message'],
              'type': MessageType
                  .text, // Assuming MessageType.text is defined in your code
              'sender': chatData['from_user'] == localId
                  ? 'user'
                  : "other", // Assuming you want to show the received messages as 'other'
              'time': DateTime.parse(chatData['created_at'])
                  .toString()
                  .substring(5, 16),
              'showDetails': true,
            };
          }).toList();

          // Add the new chat messages to the existing list
          setState(() {
            chatMessages.addAll(newChatMessages);
            loading = false;
          });
        } else {
          print('Error: Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}${response.body} ');
      }
    } catch (error) {
      print('Error: $error');
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            translate('Discuter avec ', messagee_Arabic, messagee_English) +
                widget.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  return message['type'] == MessageType.image
                      ? _buildImageBubble(message)
                      : _buildMessageBubble(message);
                },
              ),
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: translate('Tapez votre message...', messagee_Arabic,
                    messagee_English),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(messageController.text, MessageType.text, 'user');
            },
          ),
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () {
              _showImagePickerDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    bool showDetails = message['showDetails'];

    return GestureDetector(
      onTap: () {
        setState(() {
          message['showDetails'] = !showDetails;
        });
      },
      child: Column(
        children: [
          Align(
            alignment: isUser ? Alignment.topRight : Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUser ? Color(0xFFD91A5B) : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  message['text'],
                  style: TextStyle(color: isUser ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
          if (showDetails)
            Align(
              alignment: isUser ? Alignment.topRight : Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: Text(
                  '${message['time']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser ? Color(0xFFD91A5B) : Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    final imagePath = message['path'] as String;
    bool showDetails = message['showDetails'];

    return GestureDetector(
      onTap: () {
        setState(() {
          message['showDetails'] = !showDetails;
        });
      },
      child: Column(
        children: [
          Align(
            alignment: isUser ? Alignment.topRight : Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (showDetails)
            Align(
                alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Text(
                    '${message['time']}    ',
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Color(0xFFD91A5B) : Colors.black,
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _sendMessage(String text, MessageType type, String sender) async {
    final now = DateTime.now().toLocal();
    bool showDetails = true;

    if (type == MessageType.image) {
      final imageFile = File(text);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = now.millisecondsSinceEpoch.toString() + '.jpg';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');

      setState(() {
        chatMessages.add({
          'path': savedImage.path,
          'type': type,
          'sender': sender,
          'time': now.toString().substring(5, 16),
          'showDetails': showDetails,
        });
        messageController.clear();
      });
    } else {
      bool send = await sendMessageToApi(text);
      if (send) {
        setState(() {
          chatMessages.add({
            'text': text,
            'type': type,
            'sender': sender,
            'time': now.toString().substring(5, 16),
            'showDetails': showDetails,
          });
          messageController.clear();
        });
      } else {}
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _showImageConfirmationDialog(pickedFile.path);
    }
  }

  Future<void> _showImageConfirmationDialog(String imagePath) async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: ElevatedButton.styleFrom(
                // primary: Colors.grey, // Background color
              ),
              child:
                  Text(translate('Annuler', messagee_Arabic, messagee_English)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                // primary: Color(0xFFD91A5B), // Background color
              ),
              child:
                  Text(translate('Envoyer', messagee_Arabic, messagee_English)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _sendMessage(imagePath, MessageType.image, 'user');
    }
  }

  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate(
              "Choisissez une option", messagee_Arabic, messagee_English)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              style: ElevatedButton.styleFrom(
                // primary: Colors.blue, // Background color
              ),
              child:
                  Text(translate('Galerie', messagee_Arabic, messagee_English)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              style: ElevatedButton.styleFrom(
                // primary: Colors.blue, // Background color
              ),
              child:
                  Text(translate('Caméra', messagee_Arabic, messagee_English)),
            ),
          ],
        );
      },
    );
  }

  Future<bool> sendMessageToApi(String message) async {
    print('sending message');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localId = prefs.getString('id').toString();
    String url = '$domain2/api/sendMessageClientOnline';
    print("salon " + widget.idsalon);
    print("Client " + localId);
    final Map<String, dynamic> requestData = {
      'message': message,
      'salon_id': widget.idsalon,
      'client_id': localId,
      // 'room': 'Y0MBT9Qh' // Uncomment if needed
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ElegantNotification.error(
          animationDuration: const Duration(milliseconds: 600),
          width: 360,
          position: Alignment.bottomCenter,
          animation: AnimationType.fromBottom,
          title: const Text('Error'),
          description: Text(response.body),
          onDismiss: () {},
        ).show(context);
        return false;
      }
    } catch (error) {
      ElegantNotification.error(
        animationDuration: const Duration(milliseconds: 600),
        width: 360,
        position: Alignment.bottomCenter,
        animation: AnimationType.fromBottom,
        title: const Text('Error'),
        description: Text(error.toString()),
        onDismiss: () {},
      ).show(context);
      print('Error sending message: $error');
      return false;
    }
  }
}

enum MessageType {
  text,
  image,
}
