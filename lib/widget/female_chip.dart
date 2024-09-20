import 'package:flutter/material.dart';

class FemmeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  const Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.woman,
            color: Color(0xFFD91A5B),
          ),
          SizedBox(width: 8),
          Text(
            'Femme',
            style: TextStyle(
              color: Color(0xFFD91A5B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: Color(0xFFD91A5B),
          width: 1.5,
        ),
      ),
    );
  }
}
