import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/screens/Details_salon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spa/screens/home_page.dart';
import 'package:spa/screens/searchqueries.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final TextEditingController _controller = TextEditingController();

  final Completer<GoogleMapController> _controllerSSS = Completer();
  final Set<Marker> markers = <Marker>{};
  bool isListVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? currentCity;
  List<PlaceOption> filteredList = [];
  Position? P;
  Future<void> getCurrentCity() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          currentCity = placemarks[0].locality;
        });
      } else {
        setState(() {
          currentCity = 'City not found';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        currentCity = 'Error getting location';
      });
    }
    print(currentCity.toString() +
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
  }

  fetchdata() async {
    list = await fetchPlaces();
    getUserLocation();

    filteredList = list;
    setState(() {});
  }

  List<PlaceOption> list = [];
  Future<List<PlaceOption>> fetchPlaces() async {
    // await getCurrentCity();
    final response = await http.get(
      Uri.parse('$domain2/api/getSalons'),
      // body: {"city": "Tanger"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> salonList = data['salons'];

      return salonList.map((salonJson) {
        String imageUrl = '';
        final Map<String, dynamic> addressMap = salonJson['address_map'] != null
            ? json.decode(salonJson['address_map'])
            : <String, dynamic>{};

        if (salonJson['media'] != null &&
            salonJson['media'].isNotEmpty &&
            salonJson['media'][0]['original_url'] != null) {
          imageUrl = salonJson['media'][0]['original_url'];
        } else {
          imageUrl = "https://spabooking.pro/assets/no-image-18732f44.png";
        }
        if (addressMap['lat'] != null && addressMap['lon'] != null) {
          addMarker(
              LatLng(double.parse(addressMap['lat']),
                  double.parse(addressMap['lon'])),
              salonJson['name']);
        }

        return PlaceOption(
          latitude: double.parse(
              addressMap['lat'].toString() == 'null' ? "0" : addressMap['lat']),
          longitude: double.parse(
              addressMap['lon'].toString() == 'null' ? "0" : addressMap['lon']),
          placeName: salonJson['name'],
          placeCity: salonJson['city'],
          placeRating: salonJson['reviews']['average_rating'].toString(),
          placeImage:
              imageUrl, // Provide a placeholder image path or any default image
          isFemalePlace: (salonJson['genre'].contains('Femme') &&
                  salonJson['genre'].contains('Homme'))
              ? 'Mixte'
              : salonJson['genre'].contains('Femme')
                  ? 'Femme'
                  : 'Homme',
          isOpen: isSalonOpenNow(List<Map<String, dynamic>>.from(
              salonJson['disponibility'] ?? [])),
          id: salonJson['id'].toString(),
        );
      }).toList();
    } else {
      throw Exception(
          'sssssssssssssssssssssssssssssssssssssssssssssssssss Failed to load places');
    }
  }

  isSalonOpenNow(List<Map<String, dynamic>> availabilityData) {
    print("+++++++++++++++++++++++++++++++++++++++++++++++++");
    print(availabilityData);
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
          (availability) => availability['day'] == day,
          orElse: () => L);

      if (availability.isEmpty) {
        // Salon is not available on this day

        return false;
      }

      String startTimeStr = availability['start_at'];
      String endTimeStr = availability['end_at'];

      DateTime startTime = DateFormat('HH:mm').parse(startTimeStr);
      DateTime endTime = DateFormat('HH:mm').parse(endTimeStr);
      DateTime currentTime = DateTime.now();

      print("rrrrrrrrrrrrrrrrrrrrrrrr " + getCurrentDayNameInFrench());
      print("MMMMMMMMMMMMMMMMMMM " + day);
      print("NNNNNNNNNNNNNNNNNNNNNNNNNN " + startTime.hour.toString());
      print("eeeeeeeeeeeeeeeeeeeeeeeeeee " + endTime.hour.toString());
      print(getCurrentDayNameInFrench() == day);
      if (getCurrentDayNameInFrench() == day &&
          currentTime.hour > startTime.hour &&
          currentTime.hour < endTime.hour) {
        print(
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " +
                endTime.hour.toString());

        return true;
      } else {}

      //  return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLanguage();

    fetchdata();
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

  String getCurrentDayNameInFrench() {
    return formatDayNameInFrench(DateFormat('EEEE').format(DateTime.now()));
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

  void getUserLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, proceed to get location
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          P = position;
        });
      } catch (e) {
        print("Error getting location: $e");
      }
    } else {
      // Permission denied, handle accordingly
      print("Location permission denied");
    }
    print("i tryed ::::::::::::::::" + P.toString());

    if (P != null) {
      GoogleMapController controller = await _controllerSSS.future;

      // Get the center of the bounds
      LatLng center = LatLng(
        P!.latitude,
        P!.longitude,
      );

      // Set different zoom levels based on whether it's a region or a province
      double zoomLevel = 10;

      print("i tryed ::::::::::::::::");
      controller.moveCamera(CameraUpdate.newLatLngZoom(center, zoomLevel));
    }
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
              ? translate('Explore salon', drawer_English)
              : selectedLanguage == "Arabic"
                  ? translate('Explore salon', drawer_Arabic)
                  : 'Explore salon'),
      body: Column(
        children: [
          Container(
              height: isListVisible
                  ? MediaQuery.of(context).size.height * 0.3
                  : MediaQuery.of(context).size.height - 185,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) =>
                    _controllerSSS.complete(controller),
                initialCameraPosition: P != null
                    ? CameraPosition(
                        target: LatLng(
                          P!.latitude,
                          P!.longitude,
                        ),
                        zoom: 10,
                      )
                    : const CameraPosition(
                        target: LatLng(35.562956, -5.561728),
                        zoom: 8,
                      ),
                markers: markers,
              )),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (query) {
                      //  filterList(query);
                    },
                    decoration: InputDecoration(
                      hintText: selectedLanguage == "English"
                          ? translate('Rechercher des salons...', home_English)
                          : selectedLanguage == "Arabic"
                              ? translate(
                                  'Rechercher des salons...', home_Arabic)
                              : 'Rechercher des salons...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchQueries(
                                Text: removeLastSpace(_controller.text),
                              )),
                    );
                  },
                  child: Text(selectedLanguage == "English"
                      ? translate('Rechercher', home_English)
                      : selectedLanguage == "Arabic"
                          ? translate('Rechercher', home_Arabic)
                          : 'Rechercher'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isListVisible = !isListVisible;
                    });
                  },
                  icon: Icon(
                      !isListVisible ? Icons.visibility_off : Icons.visibility,
                      color: !isListVisible
                          ? Colors.grey
                          : const Color(0xFFD91A5B)),
                ),
              ],
            ),
          ),
          AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: isListVisible ? null : 0,
              child: Visibility(
                  visible: isListVisible,
                  child: Expanded(
                    child: Visibility(
                      visible: isListVisible,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return filteredList[index];
                        },
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }

  void addMarker(LatLng position, String placeName) {
    final marker = Marker(
      markerId: MarkerId(placeName),
      position: position,
      infoWindow: InfoWindow(
        title: placeName,
      ),
    );
    markers.add(marker);
  }

  void filterList(String query) {
    setState(() {
      filteredList = list
          .where((place) =>
              place.placeName.toLowerCase().contains(query.toLowerCase()) ||
              place.placeCity.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

class PlaceOption extends StatefulWidget {
  final String placeName;
  final String placeCity;
  final String placeRating;
  final String placeImage;
  final String
      isFemalePlace; // Add a boolean to determine if it's a female place
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String id;

  const PlaceOption({
    required this.placeName,
    required this.placeCity,
    required this.placeRating,
    required this.placeImage,
    required this.isFemalePlace,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    required this.id,
  });
  @override
  _PlaceOptionState createState() => _PlaceOptionState();
}

class _PlaceOptionState extends State<PlaceOption> {
  @override
  void initState() {
    super.initState();
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SalonDetails(
                    id: widget.id,
                  )),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.placeImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.placeName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow:
                            TextOverflow.ellipsis, // Truncate with ellipsis
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.placeCity,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        overflow:
                            TextOverflow.ellipsis, // Truncate with ellipsis
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFD91A5B)),
                          const SizedBox(width: 4),
                          Text(
                            widget.placeRating,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFFD91A5B)),
                            overflow:
                                TextOverflow.ellipsis, // Truncate with ellipsis
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        if (widget.isFemalePlace == "Mixte")
                          Row(
                            children: const [
                              Icon(
                                Icons.woman,
                                color:
                                    Color(0xFFD91A5B), // Set icon color to pink
                                size: 20,
                              ),
                              Icon(
                                Icons.man,
                                color:
                                    Color(0xFFD91A5B), // Set icon color to pink
                                size: 20,
                              ),
                            ],
                          ),
                        if (widget.isFemalePlace != "Mixte")
                          Icon(
                              widget.isFemalePlace == "Femme"
                                  ? Icons.female
                                  : Icons.male,
                              color: Colors.pink),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            selectedLanguage == "English"
                                ? translate(widget.isFemalePlace, home_English)
                                : selectedLanguage == "Arabic"
                                    ? translate(
                                        widget.isFemalePlace, home_Arabic)
                                    : widget.isFemalePlace,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.pink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          widget.isOpen ? Icons.check_circle : Icons.cancel,
                          color: widget.isOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                            width: 60,
                            child: Text(
                              widget.isOpen
                                  ? selectedLanguage == "English"
                                      ? translate('Ouvert', home_English)
                                      : selectedLanguage == "Arabic"
                                          ? translate('Ouvert', home_Arabic)
                                          : 'Ouvert'
                                  : selectedLanguage == "English"
                                      ? translate('Fermé', home_English)
                                      : selectedLanguage == "Arabic"
                                          ? translate('Fermé', home_Arabic)
                                          : 'Fermé',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    widget.isOpen ? Colors.green : Colors.red,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SalonDetails(
                                      id: widget.id,
                                    )),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 2, // Adjust the elevation as needed
                        ),
                        // You can customize the color, textColor, and child as needed
                        // ...
                        child: Text(
                          selectedLanguage == "English"
                              ? translate('Explorer le salon', home_English)
                              : selectedLanguage == "Arabic"
                                  ? translate('Explorer le salon', home_Arabic)
                                  : 'Explorer le salon',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
