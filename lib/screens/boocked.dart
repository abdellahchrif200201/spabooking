import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/screens/detials_reservation.dart';
import 'package:spa/screens/search_map.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:html/parser.dart' show parse;

class Booked extends StatefulWidget {
  @override
  _BookedState createState() => _BookedState();
}

class _BookedState extends State<Booked> {
  List<Reservation> placeses = [];
  List<Reservation> placeses_filtred = [];
  bool loading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _fetchAndStoreBookingDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? localId = prefs.getString('id').toString();

      final response = await http.post(
        Uri.parse('$domain2/api/getBookingByClient'),
        body: {'client_id': localId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['booking'] != null) {
          List<dynamic> salons = data['booking'];
          print(localId);
          List<Reservation> latestPlaces = salons.map((salon) {
            // Print the data before creating Reservation object
            print('Salon ID: ${salon['id']}');
            print('Salon Name: ${salon['service']['salon']['name']}');
            print('User Name: ${salon['user']['name']}');
            print('Booking Status: ${salon['booking_status']}');
            print('Date: ${salon['created_at']}');
            print('Description: ${salon['service']['description']}');
            print('Price: ${salon['price']}');
            print('Reservation Number: ${salon['id']}');
            print('Payment Status: ${salon['payment_status']}');
            print('-----------------------------------------');
            return Reservation(
              promo: salon['service']['discount_price'] ?? '0',
              SalonTelephone:
                  salon['service']['salon']['phone_number'].toString(),
              SalonName: salon['service']['salon']['name'].toString(),
              emailStaff: salon['staff']['email'].toString(),
              folder_number: salon['folder_number'].toString(),
              nameStaff: salon['staff']['name'].toString(),
              start_at: salon['start_at'].toString(),
              phone_numberStaff:
                  salon['staff']['phone_number'] ?? ' Untrouvable',
              img: "$domain2/storage/" +
                  salon['service']['salon']['logo'].toString(),
              adress: salon['service']['salon']['address'].toString(),
              name: salon['user']['name'].toString(),
              bookingStatus: salon['booking_status'].toString(),
              date: salon['created_at'].toString(),
              description: salon['service']['description'].toString(),
              price: salon['service']['price'].toString(),
              reservationNumber: salon['folder_number'],
              payment_status: salon['payment_status'].toString(),
            );
          }).toList();
          latestPlaces = latestPlaces.reversed.toList();
          setState(() {
            placeses_filtred = latestPlaces;
            placeses = latestPlaces;
            loading = false;
          });

          // Optionally, you can print or use the latest bookings
          print('Latest 8 bookings: ${placeses_filtred.length}');
        } else {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error: $error');
    }
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
    // TODO: implement initState
    super.initState();
    _loadLanguage();

    _fetchAndStoreBookingDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD91A5B),
        elevation: 0,
        title: Center(
          child: Image.asset(
            "Assets/1-removebg-preview.png",
            height: 30,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
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
              ? translate('Réservation', drawer_English)
              : selectedLanguage == "Arabic"
                  ? translate('Réservation', drawer_Arabic)
                  : 'Réservation'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedLanguage == "English"
                    ? translate('Réservations', home_English)
                    : selectedLanguage == "Arabic"
                        ? translate('Réservations', home_Arabic)
                        : 'Réservations',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD91A5B)),
              ),
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
                              margin: EdgeInsets.all(20),
                              padding: EdgeInsets.all(20),
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
                                        ? translate(
                                            'Aucun réservations disponible',
                                            home_English)
                                        : selectedLanguage == "Arabic"
                                            ? translate(
                                                'Aucun réservations disponible',
                                                home_Arabic)
                                            : 'Aucun réservations disponible',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFD91A5B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: placeses_filtred
                                .length, // Replace with your actual data length
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReservationPage(
                                                reservation:
                                                    placeses_filtred[index],
                                              )),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFD91A5B),
                                          width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(children: [
                                              Text((selectedLanguage ==
                                                          "English"
                                                      ? translate(
                                                          'Réservations',
                                                          home_English)
                                                      : selectedLanguage ==
                                                              "Arabic"
                                                          ? translate(
                                                              'Réservations',
                                                              home_Arabic)
                                                          : 'Réservations') +
                                                  " "),
                                              Text(
                                                placeses_filtred[index]
                                                    .reservationNumber
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ]),
                                            const SizedBox(width: 8),
                                            if (placeses_filtred[index]
                                                    .phone_numberStaff
                                                    .toString() !=
                                                ' Untrouvable')
                                              Row(children: [
                                                Chip(
                                                  label: Text(
                                                    placeses_filtred[index]
                                                        .phone_numberStaff
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor:
                                                      Color(0xFFD91A5B)
                                                          .withOpacity(0.8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4,
                                                      vertical: 0),
                                                ),
                                                const SizedBox(width: 5),
                                              ]),
                                            if (placeses_filtred[index]
                                                    .phone_numberStaff
                                                    .toString() ==
                                                ' Untrouvable')
                                              Row(children: [
                                                Chip(
                                                  label: Text(
                                                    placeses_filtred[index]
                                                        .phone_numberStaff
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4,
                                                      vertical: 0),
                                                ),
                                                const SizedBox(width: 5),
                                              ]),
                                          ],
                                        ),
                                        const Divider(
                                          color: Color(0xFFD91A5B),
                                          thickness: 2,
                                        ),
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    placeses_filtred[index]
                                                        .img
                                                        .toString(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        CachedNetworkImage(
                                                  imageUrl:
                                                      "https://spabooking.pro/assets/no-image-18732f44.png",
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        child:
                                                            CircularProgressIndicator()),
                                                  ),
                                                ),
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      placeses_filtred[index]
                                                          .name
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFFD91A5B),
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis, // Truncate with ellipsis
                                                      maxLines:
                                                          1, // Set the maximum number of lines
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      extractPlainText(
                                                          placeses_filtred[
                                                                  index]
                                                              .description
                                                              .toString()),
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      overflow: TextOverflow
                                                          .ellipsis, // Truncate with ellipsis
                                                      maxLines:
                                                          1, // Set the maximum number of lines
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        child: Text(
                                                          placeses_filtred[
                                                                  index]
                                                              .adress
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          overflow: TextOverflow
                                                              .ellipsis, // Truncate with ellipsis
                                                          maxLines:
                                                              1, // Set the maximum number of lines
                                                        )),
                                                  ],
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Text(
                                                  "Créé le : " +
                                                      DateTime.parse(
                                                              placeses_filtred[
                                                                      index]
                                                                  .date
                                                                  .toString())
                                                          .toLocal()
                                                          .toString()
                                                          .substring(0, 16)
                                                          .replaceAll(
                                                              'T', ' - '),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]),
                                              Row(children: [
                                                Text(selectedLanguage ==
                                                        "English"
                                                    ? translate('Prix total: ',
                                                        home_English)
                                                    : selectedLanguage ==
                                                            "Arabic"
                                                        ? translate(
                                                            'Prix total: ',
                                                            home_Arabic)
                                                        : 'Prix total: '),
                                                placeses_filtred[index]
                                                            .promo
                                                            .toString() !=
                                                        '0'
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "${placeses_filtred[index].promo.toString()} Dh",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xFFD91A5B),
                                                            ),
                                                          ),
                                                          Text(
                                                            "${placeses_filtred[index].price.toString()} Dh",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        "${placeses_filtred[index].price.toString()} Dh",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFFD91A5B),
                                                        ),
                                                      )
                                              ]),
                                            ]),
                                      ],
                                    ),
                                  ));
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String extractPlainText(String htmlContent) {
    var document = parse(htmlContent);
    return parse(document.body!.text).documentElement!.text;
  }
}

class Reservation {
  String folder_number;
  String start_at;
  String nameStaff;
  String phone_numberStaff;
  String emailStaff;
  String name;
  String SalonName;
  String SalonTelephone;

  String date;
  String description;
  String price;
  String promo;
  String reservationNumber;
  String bookingStatus;
  String payment_status;
  String img;
  String adress;

  Reservation({
    required this.folder_number,
    required this.start_at,
    required this.promo,
    required this.nameStaff,
    required this.phone_numberStaff,
    required this.name,
    required this.emailStaff,
    required this.SalonName,
    required this.SalonTelephone,
    required this.date,
    required this.description,
    required this.price,
    required this.reservationNumber,
    required this.bookingStatus,
    required this.payment_status,
    required this.img,
    required this.adress,
  });
}
