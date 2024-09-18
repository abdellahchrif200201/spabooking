import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/salon_list_favoris.dart';
import 'package:spa/screens/search_map.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:jumping_dot/jumping_dot.dart';

class ListSalon extends StatefulWidget {
  @override
  _ListSalonState createState() => _ListSalonState();
}

class _ListSalonState extends State<ListSalon> {
  String nameFilter = "";
  bool loading = true;
  List<PLaces3> placeses = [];
  List<PLaces3> placeses_filtred = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _fetchAndStoreServiceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    Map<String, dynamic> requestBody = {"client_id": id, "type": "salon"};

    try {
      final response = await http.post(
        Uri.parse('$domain2/api/getAllFavoriteByCilent'),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['favorite'] != null) {
          List<dynamic> salons = data['favorite'];

          List<PLaces3> latestPlaces = [];
          for (var salon in salons) {
            try {
              var salonResponse = await http.get(
                Uri.parse('$domain2/api/getSalonById/${salon['salon']['id']}'),
              );

              if (salonResponse.statusCode == 200 ||
                  salonResponse.statusCode == 201) {
                final Map<String, dynamic> salonData =
                    json.decode(salonResponse.body);

                // Check if 'media' is present and not empty
                // List<dynamic> mediaList = [];
                String mainImage =
                    "$domain2/storage/" + salonData['salon']['logo'].toString();

                // Extract all side images from 'original_url' in 'media'
                List<String> sideImages = salonData['salon']['media']
                    .map<String>((media) => media['original_url'].toString())
                    .toList();
                print(salonData['salon']['reviews']['average_rating']);
                String stars = (salonData['salon']['reviews'] != null &&
                        salonData['salon']['reviews']['average_rating'] != null)
                    ? salonData['salon']['reviews']['average_rating'].toString()
                    : "0.0";

                print("Name: ${salonData['name']}");
                print("ID: ${salonData['id']}");
                print("Main Image: $mainImage");
                print("Side Images: $sideImages");
                print("Location: ${salonData['city']}");
                print("Stars: $stars");
                print("Type: ${salonData['genre']}");

                latestPlaces.add(
                  PLaces3(
                    name: salonData['salon']['name'].toString(),
                    id: salonData['salon']['id'],
                    mainImage: mainImage.toString(),
                    sideImages: sideImages,
                    location: salonData['salon']['city'].toString(),
                    stars: double.parse(stars),
                    type: salonData['salon']['genre'].toString(),
                    is_opend: true,
                  ),
                );
                setState(() {
                  placeses_filtred = latestPlaces;
                  placeses = latestPlaces;
                  loading = false;
                });
              } else {
                print("Failed to fetch salon by ss ID ${salon['id']}");
                print(salonResponse.body);
              }
            } catch (error) {
              print(
                  "Error during salon by ss ID ${salon['id']} API call: $error");
            }
          }

          setState(() {
            placeses_filtred = latestPlaces;
            placeses = latestPlaces;
          });

          // Optionally, you can print or use the latest placeses
          print('Latest placeses: ${placeses.length}');
        } else {
          print('Error: Invalid response structure');
        }
      } else {
        print('Error: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchAndStoreServiceDetails();
    _loadLanguage();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD91A5B),
        elevation: 0,
        title: Center(
            child: Text(
          selectedLanguage == "English"
              ? translate('Salons favoris', home_English)
              : selectedLanguage == "Arabic"
                  ? translate('Salons favoris', home_Arabic)
                  : 'Salons favoris',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyMap()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(
          currentPage: selectedLanguage == "English"
              ? translate('Favoris', drawer_English)
              : selectedLanguage == "Arabic"
                  ? translate('Favoris', drawer_Arabic)
                  : 'Favoris'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              /*    Divider(
                color: Colors.pink, // Pink line color
                thickness: 2, // Pink line thickness
              ),*/
              const SizedBox(height: 16),
              Expanded(
                child: loading
                    ? JumpingDots(
                        color: Color(0xFFD91A5B),
                        radius: 10,
                        numberOfDots: 3,
                        animationDuration: Duration(milliseconds: 200),
                      )
                    : placeses_filtred.isEmpty
                        ? Center(
                            child: Container(
                              margin: EdgeInsets.all(40),
                              padding: EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Color(0xFFD91A5B).withOpacity(0.8),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    selectedLanguage == "English"
                                        ? translate('Aucun salon disponible',
                                            home_English)
                                        : selectedLanguage == "Arabic"
                                            ? translate(
                                                'Aucun salon disponible',
                                                home_Arabic)
                                            : 'Aucun salon disponible',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFD91A5B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 2 / 3,
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: placeses_filtred.length,
                            itemBuilder: (context, index) {
                              final PLaces2 = placeses_filtred[index];
                              return _buildPLaces2Card(PLaces2);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD91A5B), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFFD91A5B)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  nameFilter = removeLastSpace(value);
                });
                getFilteredPlaces();
              },
              decoration: InputDecoration(
                hintText: selectedLanguage == "English"
                    ? translate('Recherche...', home_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Recherche...', home_Arabic)
                        : 'Recherche...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getFilteredPlaces() {
    setState(() {
      if (nameFilter.length > 1) {
        placeses_filtred = placeses_filtred
            .where((place) =>
                place.name.toLowerCase().contains(nameFilter.toLowerCase()))
            .toList();
      } else {
        placeses_filtred = placeses;
      }
    });
  }

  Widget _buildPLaces2Card(PLaces3 PLaces2) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SalonDetails(
                    id: PLaces2.id.toString(),
                  )),
        );
      },
      child: Container(
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
        child: Column(
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
                  imageUrl: PLaces2.sideImages[0],
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) => CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl:
                        "https://spabooking.pro/assets/no-image-18732f44.png",
                    placeholder: (context, url) => Center(
                      child: Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: PLaces2.sideImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                          onTap: () {
                            setState(() {
                              PLaces2.mainImage = PLaces2.sideImages[index];
                            });
                          },
                          child: CachedNetworkImage(
                            imageUrl: PLaces2.sideImages[index],
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorWidget: (context, url, error) =>
                                CachedNetworkImage(
                              imageUrl:
                                  "https://spabooking.pro/assets/no-image-18732f44.png",
                              width: 24,
                              height: 24,
                              placeholder: (context, url) => Center(
                                child: Container(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator()),
                              ),
                            ),
                          )));
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
                          width: 108,
                          child: Text(
                            PLaces2.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 3, // Set the maximum number of lines
                            softWrap:
                                true, // Allow the text to wrap to the next line
                            overflow: TextOverflow
                                .ellipsis, // Display ellipsis (...) if the text overflows
                          )),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFD91A5B), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            PLaces2.stars.toString(),
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
                  Text(
                    PLaces2.type,
                    style: const TextStyle(
                      color: Colors.grey,
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
}

class PLaces2 {
  String name;
  int id;
  String mainImage;
  List<String> sideImages;
  String location;
  double stars;
  String type;
  String Price;
  String promo;

  PLaces2({
    required this.name,
    required this.id,
    required this.mainImage,
    required this.sideImages,
    required this.location,
    required this.stars,
    required this.type,
    required this.Price,
    required this.promo,
  });
}
