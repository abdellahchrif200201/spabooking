import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/page_transltion/service_details_tr.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:spa/screens/book.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:html/parser.dart' show parse;
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/signUp_view.dart';

class Details extends StatefulWidget {
  String backgroundImageUrl;
  int ID;

  Details({required this.backgroundImageUrl, required this.ID});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String email = '';
  String phone = '';
  double latitude = 3;
  double longitude = 3;
  String salon_id = "";
  String adress = '';
  String price = '';
  String promo = '';
  List<Map<String, dynamic>> availabilityData = [];

  String name = '';
  String description = '';
  List<String> images = [];

  Future<void> _fetchAndStoreServiceDetails() async {
    try {
      final response =
          await http.get(Uri.parse('$domain2/api/getServiceById/${widget.ID}'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['service'] != null) {
          Map<String, dynamic> serviceData = data['service'];

          setState(() {
            promo = serviceData['discount_price'] ?? '0';
            price = serviceData['price'].toString();
            name = serviceData['name'].toString();
            salon_id = serviceData['salon_id'].toString();
            description =
                extractPlainText(serviceData['description'].toString());

            // Extracting image URLs from the 'media' list
            images = List<String>.from(serviceData['media'].map((item) {
              return item['original_url'].toString();
            }));
            if (images.isNotEmpty) {
              widget.backgroundImageUrl = images[0].toString();
            }
          });
        } else {
          print('Error: Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    try {
      final response = await http
          .get(Uri.parse('$domain2/api/getServiceByIdMobile/${widget.ID}'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['service'] != null) {
          Map<String, dynamic> serviceData = data['service'];

          setState(() {
            availabilityData = List<Map<String, dynamic>>.from(
              serviceData['salon']['salon_availability'] ?? [],
            );
          });
        } else {
          print('Error: Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    try {
      final response =
          await http.post(Uri.parse('$domain2/api/getSalonsFromMaps'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['salons'] != null) {
          List<dynamic> salonList = data['salons'];

          // Find the salon with id = 1
          Map<String?, dynamic>? targetSalon;

          for (var salon in salonList) {
            if (salon['id'].toString() == salon_id) {
              print("aaaaaaaaaaaaaaaaaaaaaa" + salon.toString());
              targetSalon = salon;
              break;
            }
          }
          if (targetSalon != null) {
            setState(() {
              email = targetSalon!['address'].toString();
              adress = targetSalon['address'].toString();
              phone = targetSalon['phone_number'].toString();
            });

            if (targetSalon['address_map'].toString() != 'null') {
              final Map<String, dynamic> addressMap =
                  json.decode(targetSalon['address_map']);
              if (double.tryParse(addressMap['lat']) != null) {
                latitude = double.parse(addressMap['lat']);
                longitude = double.parse(addressMap['lon']);
              }
            }
          } else {
            print('Error: Salon with id = 1 not found');
          }
        } else {
          print('Error: Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchAndStoreServiceDetails();
  }

  @override
  void dispose() {
    super.dispose();
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(10), // Adjust the radius value as needed
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? localId = prefs.getString('id');
                if (localId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Book(
                              promo: promo,
                              serviceId: widget.ID.toString(),
                              price: price,
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
                            color: Color(0xFFD91A5B), // Add border color here
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  icon: Icon(Icons.login), // Add the login icon
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
                                  icon: Icon(
                                      Icons.person_add), // Add the sign-up icon
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
                    ? translate('Réserver maintenant', service_details_English)
                    : selectedLanguage == "Arabic"
                        ? translate(
                            'Réserver maintenant', service_details_Arabic)
                        : 'Réserver maintenant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SalonDetails(
                            id: salon_id,
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                // primary: const Color.fromARGB(255, 235, 235, 235),
                // onPrimary: const Color(0xFFD91A5B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                selectedLanguage == "English"
                    ? translate('Explorer le salon', service_details_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Explorer le salon', service_details_Arabic)
                        : 'Explorer le salon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFD91A5B),
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Image.network(
                    widget.backgroundImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ))),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: const Color(0xFFD91A5B),
                        width: 2.0,
                      )),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemBuilder: (context, index) {
                      String imageUrl = images[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.backgroundImageUrl = imageUrl;
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // This is called when the image fails to load
                                return const Icon(
                                  Icons
                                      .error_outline, // You can use any error icon you prefer
                                  color: Colors
                                      .red, // Customize the color if needed
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ),
          Positioned(
              top: 40.0,
              left: 10.0,
              child: CircleAvatar(
                backgroundColor: const Color(0xFFD91A5B),
                radius: 20.0,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )),
          Positioned(
            top: 35.0,
            left: 60,
            right: 20,
            child: Container(
              height: 50,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD91A5B).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                    child: Text(
                  name, textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                  maxLines: 2, // Limit the maximum number of lines to 2
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis (...) for overflow
                )),
              ),
            ),
          ),
          Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.36,
              child: SingleChildScrollView(
                  child: Column(children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLanguage == "English"
                            ? translate('Description', service_details_English)
                            : selectedLanguage == "Arabic"
                                ? translate(
                                    'Description', service_details_Arabic)
                                : 'Description',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                /*   Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Display reviews and star rating here
                      Row(
                        children: const [
                          Icon(Icons.star,
                              color: Color(0xFFD91A5B), size: 20.0),
                          Icon(Icons.star,
                              color: Color(0xFFD91A5B), size: 20.0),
                          Icon(Icons.star,
                              color: Color(0xFFD91A5B), size: 20.0),
                          Icon(Icons.star,
                              color: Color(0xFFD91A5B), size: 20.0),
                          Icon(Icons.star_border,
                              color: Color(0xFFD91A5B), size: 20.0),
                          SizedBox(width: 8.0),
                          Text(
                            '4.0',
                            style: TextStyle(
                                fontSize: 12.0, color: Color(0xFFD91A5B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'A delightful experience! The atmosphere is amazing, and the service is top-notch. Highly recommended!',
                        style:
                            TextStyle(fontSize: 12.0, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6.0),
                      // Add more reviews as needed

                      // Display the distance
                      Text(
                        'Distance: 2.0 km',
                        style:
                            TextStyle(fontSize: 12.0, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),*/
                // Contact Us Container
                Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLanguage == "English"
                            ? translate(
                                'Contactez-nous', service_details_English)
                            : selectedLanguage == "Arabic"
                                ? translate(
                                    'Contactez-nous', service_details_Arabic)
                                : 'Contactez-nous',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Email
                      /*   Row(
                        children: [
                          const Icon(Icons.email,
                              size: 20, color: Color(0xFFD91A5B)),
                          const SizedBox(width: 12.0),
                          Text(
                            "can't find the email",
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),*/
                      // Phone Number
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 20, color: Color(0xFFD91A5B)),
                          const SizedBox(width: 12.0),
                          Text(
                            phone,
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      // Send a Message
                      Row(
                        children: [
                          const Icon(Icons.message,
                              size: 20, color: Color(0xFFD91A5B)),
                          const SizedBox(width: 12.0),
                          Text(
                            selectedLanguage == "English"
                                ? translate('Envoyer un message',
                                    service_details_English)
                                : selectedLanguage == "Arabic"
                                    ? translate('Envoyer un message',
                                        service_details_Arabic)
                                    : 'Envoyer un message',
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.grey[800]),
                          ),
                          const SizedBox(width: 12.0),
                          const Icon(Icons.send,
                              size: 20, color: Color(0xFFD91A5B)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Availability List Container
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLanguage == "English"
                            ? translate('Liste de disponibilité',
                                service_details_English)
                            : selectedLanguage == "Arabic"
                                ? translate('Liste de disponibilité',
                                    service_details_Arabic)
                                : 'Liste de disponibilité',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      if (availabilityData.isNotEmpty)
                        for (String day in [
                          'Lundi', // Monday
                          'Mardi', // Tuesday
                          'Mercredi', // Wednesday
                          'Jeudi', // Thursday
                          'Vendredi', // Friday
                          'Samedi', // Saturday
                          'Dimanche' // Sunday
                        ]) ...[
                          const SizedBox(height: 12.0),
                          Visibility(
                              visible: generateText(day),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${selectedLanguage == "English" ? translate(day, service_details_English) : selectedLanguage == "Arabic" ? translate(day, service_details_Arabic) : day}:',
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8.0),
                                  // Rounded container for hours
                                  buildAvailabilityText(day),
                                ],
                              )),
                        ],
                      if (availabilityData.isEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.info, size: 16,
                              color: Color(0xFFD91A5B),
                              //  color: Colors.black,
                            ),
                            SizedBox(
                                width: 8.0), // Adjust the spacing as needed
                            Text(
                              'No service available',
                              style: TextStyle(
                                color: Color(0xFFD91A5B),
                                //  color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),

                /*  Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Google Maps
                      SizedBox(
                        height: 200.0, // Set the height as needed
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(
                                33.5333312, -7.583331), // Example coordinates
                            zoom: 5,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('your_location_marker'),
                              position: LatLng(
                                  latitude, longitude), // Example coordinates
                              infoWindow: const InfoWindow(
                                title: 'Your Location',
                                snippet: 'This is your location',
                              ),
                            ),
                          },
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Address and Direction Icon
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color(0xFFD91A5B)),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              adress, // Replace with your actual address
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.grey[800]),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.directions,
                                color: Color(0xFFD91A5B)),
                            onPressed: () {
                              // Handle direction button press
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),*/

                const SizedBox(
                  height: 60,
                )
              ]))),
        ],
      ),
    );
  }

  bool generateText(String day) {
    Map<String, dynamic> L = {};

    var availability = availabilityData.firstWhere(
      (availability) => availability['day'] == day,
      orElse: () => L,
    );

    print('Availability for $day: $availability');

    if (availability != null &&
        availability['start_at'] != null &&
        availability['end_at'] != null) {
      String startTime = availability['start_at'];
      String endTime = availability['end_at'];

      print('Start Time: $startTime, End Time: $endTime');

      // Check if startTime and endTime are not null
      if (startTime != null && endTime != null) {
        return true;
      } else {
        print('Error: Start Time or End Time is null.');
        return false;
      }
    } else {
      print('Availability is null for $day');
      return false;
    }
  }

  Widget buildAvailabilityText(String day) {
    Map<String, dynamic> L = {};
    var availability;
    try {
      availability = availabilityData.firstWhere(
        (availability) => availability['day'] == day,
        orElse: () => L,
      );
    } catch (e) {
      print(e);
    }
    print(availability['start_at']);
    print(availability['end_at']);
    if (availability != null &&
        availability['start_at'] != null &&
        availability['end_at'] != null) {
      String startTime = availability['start_at'].toString();
      String endTime = availability['end_at'].toString();

      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFD91A5B),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}',
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const Text(
        'Not Available',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black,
        ),
      );
    }
  }

  String extractPlainText(String htmlContent) {
    var document = parse(htmlContent);
    return parse(document.body!.text).documentElement!.text;
  }

  String generateRandomWord() {
    List<String> words = [
      "Lorem",
      "ipsum",
      "dolor",
      "sit",
      "amet",
      "consectetur",
      "adipiscing",
      "elit",
    ];
    final random = Random();
    return words[random.nextInt(words.length)];
  }
}
