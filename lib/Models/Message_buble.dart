import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;

  MessageBubble({required this.message, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSentByMe ? 12 : 0),
            topRight: Radius.circular(isSentByMe ? 0 : 12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
