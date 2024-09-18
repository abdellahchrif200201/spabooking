import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/service.dart';
import 'package:spa/page_transltion/service_view_tr.dart';
import 'package:spa/screens/Details.dart';

class ServiceCard extends StatefulWidget {
  final Service service;

  const ServiceCard({required this.service});

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
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
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the details page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Details(
                    ID: widget.service.id,
                    backgroundImageUrl: widget.service.image,
                  )),
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10.0)),
                child: CachedNetworkImage(
                  imageUrl: widget.service.image,
                  fit: BoxFit.cover,
                  height: 85.0,
                  width: 150,
                  errorWidget: (context, url, error) => CachedNetworkImage(
                    imageUrl:
                        "https://spabooking.pro/assets/no-image-18732f44.png",
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator()),
                    ),
                  ),
                )),
            if (widget.service.news)
              Positioned(
                top: 8.0,
                left: 8.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD91A5B), // Change color as needed
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Nouveaux',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8.0,
              left: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(
                      widget.service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                      maxLines: 1, // Set the maximum number of lines
                      softWrap: true, // Allow the text to wrap to the next line
                      overflow: TextOverflow
                          .ellipsis, // Display ellipsis (...) if the text overflows
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Row(
                    children: [
                      Text(
                        (selectedLanguage == "English"
                                ? translate("Prix :", serive_view_English)
                                : selectedLanguage == "Arabic"
                                    ? translate("Prix :", serive_view_Arabic)
                                    : "Prix :") +
                            ' ${widget.service.promo != 0 ? widget.service.promo.toStringAsFixed(0) : widget.service.startingPrice.toStringAsFixed(0)} Dh',
                        style: const TextStyle(
                          color: Color(0xFFD91A5B),
                          fontSize: 14.0,
                        ),
                      ),
                      if (widget.service.promo != 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${widget.service.startingPrice.toStringAsFixed(0)} Dh',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    (selectedLanguage == "English"
                            ? translate("Temps :", serive_view_English)
                            : selectedLanguage == "Arabic"
                                ? translate("Temps :", serive_view_Arabic)
                                : "Temps :") +
                        ' ${convertTimeToMinutes(widget.service.startingTime)} min',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int convertTimeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }
}
