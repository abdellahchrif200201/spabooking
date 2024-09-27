import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/service_details_tr.dart';
import 'package:spa/screens/Details.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:spa/screens/book.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/signUp_view.dart';

class FilteredGridPage extends StatefulWidget {
  final String Cat_Id; // Add a string parameter
  final String title; // Add a string parameter

  const FilteredGridPage({Key? key, required this.Cat_Id, required this.title})
      : super(key: key);

  @override
  _FilteredGridPageState createState() => _FilteredGridPageState();
}

class _FilteredGridPageState extends State<FilteredGridPage> {
  List<String> filters = ['Filter 1', 'Filter 2', 'Filter 3'];
  String selectedFilter = 'Filter 1';
  List<Service2> places = [];
  List<Service2> filteredPlaces = [];
  Future<void> GetData() async {
    try {
      final response2 = await http.get(
        Uri.parse('$domain2/api/getServicesByCategoryId/${widget.Cat_Id}'),
      );

      if (response2.statusCode == 200) {
        Map<String, dynamic> data2 = json.decode(response2.body);

        if (data2['status'] == true && data2['services'] != null) {
          List<dynamic> services = data2['services'];

          List<Service2> latestServices = [];

          // Loop through the services from the second API call
          for (var service in services) {
            // Get service details from the first API call
            final response1 = await http
                .get(Uri.parse('$domain2/api/getServiceById/${service['id']}'));
            if (response1.statusCode == 200) {
              final Map<String, dynamic> data1 = json.decode(response1.body);

              if (data1['status'] == true && data1['service'] != null) {
                Map<String, dynamic> serviceData = data1['service'];

                List<String> images =
                    List<String>.from(serviceData['media'].map((item) {
                  return item['original_url'];
                }));

                String mainImageUrl = "";
                if (images.isNotEmpty) {
                  mainImageUrl = images[0];
                }

                // Create a Service2 object and add it to the list
                Service2 service2 = Service2(
                  promo: service['discount_price'] ?? '0',
                  price: service['price'],
                  name: service['name'],
                  id: service['id'],
                  mainImage: mainImageUrl,
                  sideImages: [""],
                  location: service['duration'],
                  stars: 0,
                  type: service['genre'],
                );

                latestServices.add(service2);

                setState(() {
                  filteredPlaces = latestServices;
                  places = latestServices;
                });
               
              } else {
                print('Error: Invalid response structure for getServiceById');
              }
            } else {
              print('Error: ${response1.statusCode}');
            }
          }

          print('Latest services: $latestServices');
        } else {
          print(
              'Error: Invalid response structure for getServicesByCategoryId');
        }
      } else {
        print('Error: ${response2.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLanguage();
    GetData();
  }

  late SharedPreferences _prefsss;
  String selectedLanguage = '';
  Future<void> _loadLanguage() async {
    _prefsss = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefsss.getString('selectedLanguage') ?? 'Frensh';
    });
  }

  Future<void> _saveLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });
    await _prefsss.setString('selectedLanguage', language);
  }

  String translate(String key, Map<String, String> translationMap) {
    return translationMap[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services ${widget.title} '),
      ),
      body: Column(
        children: [
          //  _buildChips(),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _buildServiceListView()),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ActionChip(
              backgroundColor: selectedFilter == filters[index]
                  ? Colors.pink // Background color for selected chip
                  : Colors.grey[200], // Background color for unselected chip
              label: Text(
                filters[index],
                style: TextStyle(
                  color: selectedFilter == filters[index]
                      ? Colors.white // Text color for selected chip
                      : Colors.black, // Text color for unselected chip
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedFilter = filters[index];
                  filterPlaces();
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        var service = filteredPlaces[index];

        return _buildServiceCard(
            promo: service.promo,
            mainImage: service.mainImage,
            nonService: service.name,
            timeStarting: service.location,
            price: service.price,
            averageRating: service.type,
            id: service.id);
      },
    );
  }

  Widget _buildServiceCard({
    required String nonService,
    required String timeStarting,
    required String price,
    required String promo,
    required String averageRating,
    required int id,
    required String mainImage,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 10,
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0, left: 16.0),
                width: 90,
                height: 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.grey, width: 1.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13.0),
                  child: Image.network(
                    mainImage,
                    height: 60.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Display a default icon for network errors
                      return Icon(Icons.error_outline, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.4, // Adjust the width as needed
                          child: Text(
                            nonService,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                            maxLines: 3,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        promo != '0'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${promo.toString()} Dh",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD91A5B),
                                    ),
                                  ),
                                  Text(
                                    "${price.toString()} Dh",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "${price.toString()} Dh",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD91A5B),
                                ),
                              )
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Duration: ${timeStarting.substring(0, 1)} h ${timeStarting.substring(2)} min',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        buildGenderTextsimple(
                            averageRating.replaceAll(',', '')),
                        const SizedBox(width: 4.0),
                        buildGenderIcons(averageRating.replaceAll(',', '')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 35,
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? localId = prefs.getString('id');
                    if (localId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Book(
                                  promo: promo,
                                  price: price,
                                  serviceId: id.toString(),
                                )),
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
                                color:
                                    Color(0xFFD91A5B), // Add border color here
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LoginView(comes: true),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                          Icons.login), // Add the login icon
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
                                            builder: (context) =>
                                                SignUpView(comes: true),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons
                                          .person_add), // Add the sign-up icon
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
                  style: ElevatedButton.styleFrom(
                    // primary: const Color(0xFFD91A5B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    selectedLanguage == "English"
                        ? translate('Réserver', service_details_English)
                        : selectedLanguage == "Arabic"
                            ? translate('Réserver', service_details_Arabic)
                            : 'Réserver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          ID: id,
                          backgroundImageUrl: "", // Remove this line
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.grey[200], // Change to your desired color
                    // onPrimary: const Color(0xFFD91A5B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    selectedLanguage == "English"
                        ? translate("Voir détails", service_details_English)
                        : selectedLanguage == "Arabic"
                            ? translate("Voir détails", service_details_Arabic)
                            : "Voir détails",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void filterPlaces() {
    filteredPlaces = places;
    setState(() {
      /*   // Add your logic to filter the data based on the selected filter
      if (selectedFilter == 'Filter 1') {
        filteredPlaces = places.where((place) => /* your condition */).toList();
      } else if (selectedFilter == 'Filter 2') {
        filteredPlaces = places.where((place) => /* your condition */).toList();
      } else if (selectedFilter == 'Filter 3') {
        filteredPlaces = places.where((place) => /* your condition */*).toList();
      }*/
    });
  }

  Widget buildGenderText(String genre) {
    bool containsHomme = genre.toLowerCase().contains("homme");
    bool containsFemme = genre.toLowerCase().contains("femme");

    if (containsHomme && containsFemme) {
      // If it contains both "Homme" and "Femme"
      return const Text(
        'Mixte',
        style: TextStyle(
          color: Color(0xFFD91A5B), // Set text color to pink
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else if (containsHomme) {
      // If it contains only "Homme"
      return const Text(
        'Homme',
        style: TextStyle(
          color: Color(0xFFD91A5B), // Set text color to pink
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else if (containsFemme) {
      // If it contains only "Femme"
      return const Text(
        'Femme',
        style: TextStyle(
          color: Color(0xFFD91A5B), // Set text color to pink
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else {
      // If it doesn't contain either "Homme" or "Femme"
      return const Text(
        'Mixte',
        style: TextStyle(
          color: Color(0xFFD91A5B), // Set text color to pink
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
  }

  Widget buildGenderTextsimple(String genre) {
    bool containsHomme = genre.toLowerCase().contains("homme");
    bool containsFemme = genre.toLowerCase().contains("femme");

    if (containsHomme && containsFemme) {
      // If it contains both "Homme" and "Femme"
      return const Text(
        'Mixte',
        style: TextStyle(
          fontSize: 14,
        ),
      );
    } else if (containsHomme) {
      // If it contains only "Homme"
      return const Text(
        'Homme',
        style: TextStyle(
          fontSize: 14,
        ),
      );
    } else if (containsFemme) {
      // If it contains only "Femme"
      return const Text(
        'Femme',
        style: TextStyle(
          fontSize: 14,
        ),
      );
    } else {
      // If it doesn't contain either "Homme" or "Femme"
      return const Text(
        'Mixte',
        style: TextStyle(
          fontSize: 14,
        ),
      );
    }
  }

  Widget buildGenderIcons(String genre) {
    bool containsHomme = genre.contains("Homme");
    bool containsFemme = genre.contains("Femme");

    if (containsHomme && containsFemme) {
      // If it contains both "Homme" and "Femme"
      return Row(
        children: const [
          Icon(
            Icons.woman,
            color: Color(0xFFD91A5B), // Set icon color to pink
            size: 20,
          ),
          SizedBox(width: 5), // Add some space between icons

          Icon(
            Icons.man,
            color: Color(0xFFD91A5B), // Set icon color to pink
            size: 20,
          ),
        ],
      );
    } else if (containsHomme) {
      // If it contains only "Homme"
      return const Icon(
        Icons.man,
        color: Color(0xFFD91A5B), // Set icon color to pink
        size: 20,
      );
    } else if (containsFemme) {
      // If it contains only "Femme"
      return const Icon(
        Icons.woman,
        color: Color(0xFFD91A5B), // Set icon color to pink
        size: 20,
      );
    } else {
      return Row(
        children: const [
          Icon(
            Icons.woman,
            color: Color(0xFFD91A5B), // Set icon color to pink
            size: 20,
          ),
          SizedBox(width: 5), // Add some space between icons

          Icon(
            Icons.man,
            color: Color(0xFFD91A5B), // Set icon color to pink
            size: 20,
          ),
        ],
      );
    }
  }
}

class Place4 {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final double price;
  final String time;

  Place4({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.time,
  });
}
