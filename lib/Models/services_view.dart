import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/service_view_tr.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:spa/screens/List_salon.dart';
import 'package:spa/screens/services_list.dart';
import 'package:spa/widgets/cards.dart';
import 'package:spa/Models/service.dart';

class ServiceView extends StatefulWidget {
  final String title;
  final String icon;
  final String Cat_Id;
  final bool isNew;
  final List<PLaces2> places;

  const ServiceView({
    required this.title,
    required this.icon,
    required this.isNew,
    required this.places,
    required this.Cat_Id,
  });

  @override
  _ServiceViewState createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isListVisible = false;
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleListVisibility() {
    setState(() {
      isListVisible = !isListVisible;
      isListVisible ? _controller.reverse() : _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleListVisibility,
          child: Container(
            // padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    widget.icon != null
                        ? CachedNetworkImage(
                            imageUrl: widget.icon,
                            color: const Color(0xFFD91A5B),
                            width: 24,
                            height: 24,
                            errorWidget: (context, url, error) => CachedNetworkImage(
                                  width: 24,
                                  height: 24,
                                  imageUrl: "https://spabooking.pro/assets/no-image-18732f44.png",
                                  fit: BoxFit.fitWidth,
                                ))
                        : Container(), // Adjust this condition based on your widget.icon availability
                    const SizedBox(width: 20),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Icon(
                  isListVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 30,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            height: widget.places.isEmpty ? 50 : 170,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.places.isEmpty
                  ? 1
                  : widget.places.length < 9
                      ? widget.places.length + 1
                      : 9,
              itemBuilder: (context, index) {
                if (widget.places.isEmpty) {
                  return Center(
                    child: Text(
                      selectedLanguage == "English"
                          ? translate("Aucun élément dans cette liste.", serive_view_English)
                          : selectedLanguage == "Arabic"
                              ? translate("Aucun élément dans cette liste.", serive_view_Arabic)
                              : "Aucun élément dans cette liste.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                } else if (index == widget.places.length) {
                  // Last item is the "See All" button
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FilteredGridPage(Cat_Id: widget.Cat_Id, title: widget.title)),
                        );
                      },
                      child: Text(
                        selectedLanguage == "English"
                            ? translate('Voir tout >', serive_view_English)
                            : selectedLanguage == "Arabic"
                                ? translate('Voir tout >', serive_view_Arabic)
                                : 'Voir tout >',
                        style: TextStyle(
                          color: Color(0xFFD91A5B),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                } else {
                  final place = widget.places[index];
                  return ServiceCard(
                    service: Service(
                      place.name,
                      double.parse(place.Price),
                      place.location,
                      place.mainImage,
                      widget.isNew,
                      place.id,
                      double.parse(place.promo),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPlaceCard(PLaces2 place, bool a) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SalonDetails(
                    id: "1",
                  )),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                        imageUrl: place.mainImage,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: "https://spabooking.pro/assets/no-image-18732f44.png",
                            )),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: place.sideImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              place.mainImage = place.sideImages[index];
                            });
                          },
                          child: CachedNetworkImage(
                            imageUrl: place.sideImages[index],
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => CachedNetworkImage(
                              imageUrl: "https://spabooking.pro/assets/no-image-18732f44.png",
                              width: 24,
                              height: 24,
                              placeholder: (context, url) => Center(
                                child: Container(width: 40, height: 40, child: CircularProgressIndicator()),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFD91A5B),
                              ),
                              maxLines: 3, // Set the maximum number of lines
                              softWrap: true, // Allow the text to wrap to the next line
                              overflow: TextOverflow.ellipsis, // Display ellipsis (...) if the text overflows
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                place.stars.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 120,
                        child: Text(
                          place.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          maxLines: 3, // Set the maximum number of lines
                          softWrap: true, // Allow the text to wrap to the next line
                          overflow: TextOverflow.ellipsis, // Display ellipsis (...) if the text overflows
                        ),
                      ),
                      Text(
                        place.type,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
