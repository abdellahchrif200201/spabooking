import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:spa/screens/search_map.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';

class ListSalonFavoris extends StatefulWidget {
  final String? city; // Assuming you have a City class

  ListSalonFavoris({this.city});

  @override
  _ListSalonFavorisState createState() => _ListSalonFavorisState();
}

class _ListSalonFavorisState extends State<ListSalonFavoris> {
  List<bool> filterSelection = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  bool loading = true;

  List<String> list_choises = [];
  String? selectedCity;
  List<PLaces3> placeses = [];
  List<PLaces3> placeses_filtred = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedFilter = 'All';
  List<String> cities = []; // Add your city names
  Future<void> _fetchAndStoreServiceDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$domain2/api/getSalons'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['salons'] != null) {
          List<dynamic> salons = data['salons'];

          salons.sort((a, b) {
            DateTime dateA = DateTime.parse(a['created_at'].toString());
            DateTime dateB = DateTime.parse(b['created_at'].toString());
            return dateB.compareTo(dateA); // Sort in descending order
          });

          List<PLaces3> latestPlaces = salons.map((salon) {
            print("stop here");
            List<dynamic> mediaList = salon['media'] as List<dynamic>;
            String mainImage = mediaList.isNotEmpty ? mediaList[0]['original_url'] : '';

            // Extract all side images from 'original_url' in 'media'
            List<String> sideImages = mediaList.map((media) => media['original_url'].toString()).toList();
            if (sideImages.isEmpty) {
              sideImages.add("https://spabooking.pro/assets/no-image-18732f44.png");
            }
            print(salon['reviews']);
            String stars = (salon['reviews'] != null && salon['reviews']['average_rating'] != null) ? salon['reviews']['average_rating'].toString() : "0.0";

            print("Name: ${salon['name']}");
            print("ID: ${salon['id']}");
            print("Main Image: $mainImage");
            print("Side Images: $sideImages");
            print("Location: ${salon['city']}");
            print("Stars: $stars");
            print("Type: ${salon['genre']}");
            print("Is Open Now: ${isSalonOpenNow(List<Map<String, dynamic>>.from(salon['disponibility'] ?? []))}");
            if (!cities.contains(salon['city'].toString())) {
              cities.add(salon['city'].toString());
            }
            return PLaces3(
              name: salon['name'].toString(),
              id: salon['id'],
              mainImage: mainImage.toString(),
              sideImages: sideImages,
              location: salon['city'].toString(),
              stars: double.parse(stars),
              type: salon['genre'].toString(),
              is_opend: isSalonOpenNow(List<Map<String, dynamic>>.from(salon['disponibility'] ?? [])),
            );
          }).toList();

          setState(() {
            placeses_filtred = latestPlaces;
            placeses = latestPlaces;
            loading = false;
          });
          print('Latest 8 placeses: ${placeses.length}');
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
      if (cities.contains(widget.city.toString()) && widget.city != null) {
        selectedCity = widget.city;
        filterPlaces();
      }
    });
    setState(() {
      loading = false;
    });
  }

  late SharedPreferences _prefs;
  String selectedLanguage = '';
  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefs.getString('selectedLanguage') ?? 'Frensh';
    });
    Ouvert = selectedLanguage == "English"
        ? translate('Ouvert maintenant', home_English)
        : selectedLanguage == "Arabic"
            ? translate('Ouvert maintenant', home_Arabic)
            : 'Ouvert maintenant';
    Tous = selectedLanguage == "English"
        ? translate('Tous les genres', home_English)
        : selectedLanguage == "Arabic"
            ? translate('Tous les genres', home_Arabic)
            : 'Tous les genres';
    Homme = selectedLanguage == "English"
        ? translate('Homme', home_English)
        : selectedLanguage == "Arabic"
            ? translate('Homme', home_Arabic)
            : 'Homme';
    Femme = selectedLanguage == "English"
        ? translate('Femme', home_English)
        : selectedLanguage == "Arabic"
            ? translate('Femme', home_Arabic)
            : 'Femme';
    Mixte = selectedLanguage == "English"
        ? translate('Mixte', home_English)
        : selectedLanguage == "Arabic"
            ? translate('Mixte', home_Arabic)
            : 'Mixte';
    list_choises = [Ouvert, Tous, Homme, Femme, Mixte];
    print(selectedLanguage);
    print(list_choises);
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

  String Ouvert = 'Ouvert maintenant';
  String Tous = 'Tous les genres';
  String Homme = "Homme";
  String Femme = "Femme";
  String Mixte = "Mixte";

  @override
  void initState() {
    super.initState();

    _loadLanguage();

    _fetchAndStoreServiceDetails();
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
                ? translate('Tout les salon', home_English)
                : selectedLanguage == "Arabic"
                    ? translate('Tout les salon', home_Arabic)
                    : 'Tout les salon',
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
          ),
        ),
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
              ? translate('Tout les salon', home_English)
              : selectedLanguage == "Arabic"
                  ? translate('Tout les salon', home_Arabic)
                  : 'Tout les salon'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(),
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
                                        ? translate('Rechercher des salons', home_English)
                                        : selectedLanguage == "Arabic"
                                            ? translate('Rechercher des salons', home_Arabic)
                                            : 'Rechercher des salons',
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
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              childAspectRatio: 2 / 3,
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: placeses_filtred.length,
                            itemBuilder: (context, index) {
                              final place = placeses_filtred[index];
                              return _buildPlaceCard(place);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            selectedLanguage == "English"
                ? translate('Filtres', home_English)
                : selectedLanguage == "Arabic"
                    ? translate('Filtres', home_Arabic)
                    : 'Filtres',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD91A5B),
            ),
          ),
        ),*/
        _buildFilterRow([
          _buildFilterCheckbox(0),
          _buildFilterCheckbox(1),
          _buildFilterCheckbox(2),
          _buildFilterCheckbox(3),
          _buildFilterCheckbox(4),
          _buildCityDropdown(),
        ]),
      ],
    );
  }

  Widget _buildFilterRow(List<Widget> filters) {
    return Wrap(
      spacing: 8.0,
      children: filters,
    );
  }

  bool isSelected = false;
  Widget _buildFilterCheckbox(int label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle the selection for the tapped filter
          filterSelection[label] = !filterSelection[label];
          filterPlaces();
        });
      },
      child: Container(
        // height: 30,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
        decoration: BoxDecoration(
          color: filterSelection[label] ? const Color(0xFFD91A5B) : Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: const Color(0xFFD91A5B),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filterSelection[label] ? Colors.white : const Color(0xFFD91A5B),
                border: Border.all(
                  color: const Color(0xFFD91A5B),
                  width: 1.5,
                ),
              ),
              child: null,
            ),
            const SizedBox(width: 8),
            Text(
              list_choises[label],
              style: TextStyle(
                color: filterSelection[label] ? Colors.white : const Color(0xFFD91A5B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      width: 200,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        value: selectedCity,
        onChanged: (String? newValue) {
          setState(() {
            selectedCity = newValue!;
          });
          filterPlaces();
        },
        items: cities.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value.toString(),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        iconSize: 20,
        elevation: 16,
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        underline: Container(),
        hint: Text(
          selectedLanguage == "English"
              ? translate('Sélectionner une ville', drawer_English)
              : selectedLanguage == "Arabic"
                  ? translate('Sélectionner une ville', drawer_Arabic)
                  : 'Sélectionner une ville',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(PLaces3 place) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SalonDetails(
                    id: place.id.toString(),
                  )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
                  imageUrl: place.mainImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => CachedNetworkImage(
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    imageUrl: "https://spabooking.pro/assets/no-image-18732f44.png",
                    placeholder: (context, url) => Center(
                      child: Container(width: 40, height: 40, child: CircularProgressIndicator()),
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
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          errorWidget: (context, url, error) => CachedNetworkImage(
                            imageUrl: "https://spabooking.pro/assets/no-image-18732f44.png",
                            width: 24,
                            height: 24,
                            placeholder: (context, url) => Center(
                              child: Container(width: 40, height: 40, child: CircularProgressIndicator()),
                            ),
                          ),
                        )),
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
                              color: Colors.black87,
                            ),
                            maxLines: 3, // Set the maximum number of lines
                            softWrap: true, // Allow the text to wrap to the next line
                            overflow: TextOverflow.ellipsis, // Display ellipsis (...) if the text overflows
                          )),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFD91A5B), size: 16),
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
                  Text(
                    place.type,
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

  bool isSalonOpenNow(List<Map<String, dynamic>> availabilityData) {
    DateTime currentTime = DateTime.now();

    for (String day in [
      'Lundi', // Monday
      'Mardi', // Tuesday
      'Mercredi', // Wednesday
      'Jeudi', // Thursday
      'Vendredi', // Friday
      'Samedi', // Saturday
      'Dimanche' // Sunday
    ]) {
      Map<String, dynamic> L = {};

      var availability = availabilityData.firstWhere(
        (availability) => availability['day'].toString() == day,
        orElse: () => L,
      );

      String? startTimeStr = availability['start_at'];
      String? endTimeStr = availability['end_at'];

      if (startTimeStr != null && endTimeStr != null) {
        DateTime startTime = DateFormat('HH:mm').parse(startTimeStr);
        DateTime endTime = DateFormat('HH:mm').parse(endTimeStr);
        DateTime currentTimeOnlyTime = DateTime.parse('1970-01-01 ${DateFormat('HH:mm').format(currentTime)}');
        String dayNameInFrench = DateFormat('EEEE', 'fr_FR').format(currentTime);
        print("wwwwwwwwwwwwwwwwwwwwwwwwwwwDay Name: $dayNameInFrench");
        print("yyyyyyyyyyyyyyyyyyyyyyyyyyyDay Name: $day  ");
        print("aaaaaaaaaaaaaaaaaaaaaaaaaaaStart: $startTime ");
        print("yyyyyyyyyyyyyyyyyyyyyyyyyyyEnd: $endTime");
        print("bbbbbbbbbbbbbbbbbbbbbbbbbbbCurrent: $currentTimeOnlyTime");

        if (dayNameInFrench.toLowerCase() == day.toLowerCase() && currentTimeOnlyTime.isAfter(startTime) && currentTimeOnlyTime.isBefore(endTime)) {
          print("Salon is open now!");
          return true;
        }
      }
    }

    print("Salon is not open now.");
    return false;
  }

  String formatDayNameInFrench(String dayName) {
    if (dayName.isNotEmpty) {
      // Map English day names to French day names
      Map<String, String> dayNameMapping = {
        'Monday': 'Lundi',
        'Tuesday': 'Mardi',
        'Wednesday': 'Mercredi',
        'Thursday': 'Jeudi',
        'Friday': 'Vendredi',
        'Saturday': 'Samedi',
        'Sunday': 'Dimanche',
      };

      // Convert the first letter to uppercase
      String formattedDayName = dayNameMapping[dayName] ?? dayName;

      return formattedDayName;
    }
    return '';
  }

  filterPlaces() {
    placeses_filtred = placeses;
    setState(() {
      if (filterSelection[0]) {
        placeses_filtred = placeses_filtred.where((place) => place.is_opend).toList();
      }
      if (filterSelection[1]) {
        placeses_filtred = placeses;
      }
      if (filterSelection[2]) {
        placeses_filtred = placeses_filtred.where((place) => place.type.contains("Homme")).toList();
      }
      if (filterSelection[3]) {
        placeses_filtred = placeses_filtred.where((place) => place.type.contains("Femme")).toList();
      }
      if (filterSelection[4]) {
        placeses_filtred = placeses_filtred.where((place) => place.type.contains("Mixte")).toList();
      }
      if (selectedCity != null) {
        placeses_filtred = placeses_filtred.where((place) => place.location == selectedCity).toList();
      }
    });
  }
/*
applyFilters() {
  List<PLaces3> filteredList= placeses;

filteredList = placeses;  if (filterSelection[0]) {
    filteredList = filteredList.where((place) => /* your condition */).toList();
  }

  // Apply "Most Popular" filter
  if (filterSelection[1]) {
    filteredList = filteredList.where((place) => /* your condition */).toList();
  }

  // Apply "Male" filter
  if (filterSelection[2]) {
    filteredList = filteredList.where((place) => /* your condition */).toList();
  }

  // Apply "Female" filter
  if (filterSelection[3]) {
    filteredList = filteredList.where((place) => /* your condition */).toList();
  }

  // Apply "Mixed" filter
  if (filterSelection[4]) {
    filteredList = filteredList.where((place) => /* your condition */).toList();
  }if (filterSelection[5]) {
    filteredList = filteredList.where((place) => /* your condition */).toList();
  }

  return filteredList;
}*/
}

class PLaces3 {
  String name;
  int id;
  String mainImage;
  List<String> sideImages;
  String location;
  double stars;
  String type;
  bool is_opend;
  PLaces3({
    required this.name,
    required this.id,
    required this.mainImage,
    required this.sideImages,
    required this.location,
    required this.stars,
    required this.type,
    required this.is_opend,
  });
}
