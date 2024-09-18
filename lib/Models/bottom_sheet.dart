import 'package:flutter/material.dart';
import 'package:spa/Models/Message_buble.dart';
import 'package:spa/screens/chat_details.dart';

class BottomSheetForm extends StatefulWidget {
  final String idsalon;

  BottomSheetForm({required this.idsalon});

  @override
  _BottomSheetFormState createState() => _BottomSheetFormState();
}

class _BottomSheetFormState extends State<BottomSheetForm> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      title: Text('envoyer un message'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: TextStyle(fontSize: 16),
              controller: userNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'User Name',
                contentPadding: EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your user name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              style: TextStyle(fontSize: 16),
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: 'Phone Number',
                contentPadding: EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              style: TextStyle(fontSize: 16),
              controller: messageController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.message),
                hintText: 'Message',
                contentPadding: EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle send button press
                // You can access the entered values using:
                // userNameController.text, phoneNumberController.text, messageController.text
                Navigator.pop(context); // Close the dialog
                ;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            idsalon: widget.idsalon,
                            name: "mok",
                          )),
                );
              },
              child: Text('Send'),
              style: ElevatedButton.styleFrom(
                elevation: 4, // Add elevation
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat'),
          content: Column(
            children: [
              MessageBubble(message: 'Demo Message 1', isSentByMe: true),
              MessageBubble(message: 'Demo Message 2', isSentByMe: false),
              MessageBubble(message: 'Demo Message 3', isSentByMe: true),
            ],
          ),
        );
      },
    );
  }
}
