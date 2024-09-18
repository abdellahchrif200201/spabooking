import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spa/Models/cities.dart';
import 'package:spa/screens/salon_list_favoris.dart';

class CityCart extends StatefulWidget {
  final City city;

  CityCart({required this.city});

  @override
  _CityCartState createState() => _CityCartState();
}

class _CityCartState extends State<CityCart> {
  bool _isHovered = false;
  late Color _randomColor;

  @override
  void initState() {
    super.initState();
    _randomColor = _getRandomColor();
  }

  Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void _updateHoverState(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = _isHovered ? 1.05 : 1.0; // 5% bigger on hover

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListSalonFavoris(
                    city: widget.city.name,
                  )),
        );
      },
      child: Card(
        elevation: _isHovered ? 12.0 : 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                imageUrl: widget.city.image,
                width: 1510.0 * baseSize,
                height: 1000.0 * baseSize,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl:
                      "https://spabooking.pro/assets/no-image-18732f44.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,

                    //   _randomColor.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Light Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.transparent,
// _randomColor.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              top: 10,
              left: 10.0,
              right: 10.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.city.name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  /* Text(
                    'ID: ${widget.city.id}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
