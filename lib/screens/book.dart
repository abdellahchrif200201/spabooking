import 'dart:convert';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Staff.dart';
import 'package:spa/page_transltion/Reservation_tr.dart';
import 'package:spa/screens/boocked.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:spa/screens/login_view.dart';

class Book extends StatefulWidget {
  final String serviceId;
  final String price;
  final String promo;
  const Book(
      {required this.serviceId, required this.price, required this.promo});

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CountryCode? _selectedCountry;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedOption;
  String notes = '';
  String adress = '';
  String couponCode = '';
  bool home = false;
  bool at_salon = false;
  int? selectedStaffIndex;
  String id_staff = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController backupController = TextEditingController();
  List<Staff> stf = [];
  bool reserving = false;
  Future<void> fetchAvailableStaff() async {
    getdata();
    getstaff();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('name').toString() != 'null'
        ? prefs.getString('name').toString()
        : '';
    phoneController.text = prefs.getString('phone').toString() != 'null'
        ? prefs.getString('phone').toString()
        : '';
    String salon_id_2 = '';
  }

  getdata() async {
    try {
      final response = await http
          .get(Uri.parse('$domain2/api/getServiceById/${widget.serviceId}'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['service'] != null) {
          Map<String, dynamic> serviceData = data['service'];
          
          setState(() {
            home = serviceData['enable_at_customer_address'].toString() == '1';
            at_salon = serviceData['enable_booking_at_salon'].toString() == '1';
          });
        } else {
          print('Error 1 : Invalid response structure');
        }
      } else {
        print('Error 2 : ${response.body}');
      }
    } catch (error) {
      print('Error 3 : $error');
    }
  }

  getstaff() async {
    try {
      final response = await http.post(
        Uri.parse('$domain2/api/getStaff'),
        body: {"service_id": widget.serviceId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Request successful');

        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['staff'] != null) {
          List<Map<String, dynamic>> staffList =
              List<Map<String, dynamic>>.from(data['staff']);

          List<Staff> stfs = staffList.map((staffData) {
            /*  List<dynamic> mediaList = staffData['media'] as List<dynamic>;
            print(mediaList);
            String avatarUrl = mediaList.isNotEmpty
                ? (mediaList[0]['original_url'])
                : "https://media.istockphoto.com/id/1495088043/vector/user-profile-icon-avatar-or-person-icon-profile-picture-portrait-symbol-default-portrait.jpg?s=612x612&w=0&k=20&c=dhV2p1JwmloBTOaGAtaA3AW1KSnjsdMt7-U_3EZElZ0=";*/
            return Staff(
              name: staffData['name'],
              id: staffData['id'].toString(),
              avatarUrl: staffData['media'],
            );
          }).toList();

          // Now 'stf' contains a list of Staff objects with an optional empty media field
          setState(() {
            stf = stfs;
          });
        } else {
          print('Error 5: Invalid response structure or missing staff data');
        }
      } else {
        print('Error 6: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error 7: $error');
    }
  }

  String at_salons = '';
  String at_home = "";
  String selectedHour = ''; // Variable to store the selected hour
  List<String> staffAvailabilityDates = [];
  List<String> staffAvailabilityhours = [];

  Future<void> fetchStaffAvailability(String staffId) async {
    try {
      final response = await http.post(
        Uri.parse('$domain2/api/getDateFromStaff'),
        body: {
          'service_id': widget.serviceId,
          'staff_id': staffId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true) {
          dynamic dateData = data['date'];

          if (dateData is List) {
            // Assuming 'date' contains a list of date strings
            staffAvailabilityDates = List<String>.from(dateData);
            
          } else if (dateData is Map) {
            Map<String, String> dateMap = Map<String, String>.from(dateData);
            staffAvailabilityDates = dateMap.values.toList();
          } else {
            print('Error: Unexpected data format for "date"');
          }

          for (int a = 0; a < staffAvailabilityDates.length; a++) {
            staffAvailabilityDates[a] =
                "20" + staffAvailabilityDates[a] + " 00:00:00.000";
          }
          setState(() {});
        } else {
          print('Error: Invalid response structure ${response.body}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  bool loading = false;
  Future<void> fetchAvailableHours() async {
    try {
      final response = await http.post(
        Uri.parse('$domain2/api/getHoursFromDate'),
        body: {
          'service_id': widget.serviceId,
          'staff_id': stf[selectedStaffIndex!].id,
          'date': selectedDate.toString().substring(0, 10),
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['HoursDisponilble'] != null) {
          List<String> allHours = [];
          if (data['HoursDisponilble'] is Map) {
            allHours = (data['HoursDisponilble'] as Map<String, dynamic>)
                .values
                .where((hour) => hour is String)
                .cast<String>()
                .toList();
          } else {
            allHours = (data['HoursDisponilble'] as List<dynamic>)
                .where((hour) => hour is String)
                .cast<String>()
                .toList();
          }
          print("abcde");
          if (selectedDate.year == DateTime.now().year &&
              selectedDate.month == DateTime.now().month &&
              selectedDate.day == DateTime.now().day) {
            allHours = allHours.where((hour) {
              try {
                // Check if the hour is a valid date string before parsing
                if (hour != null && hour.isNotEmpty) {
                  DateTime parsedHour = DateTime.parse(hour);
                  return parsedHour.isAfter(DateTime.now());
                } else {
                  return false; // Invalid date format
                }
              } catch (e) {
                // Handle the error (print a message, log it, etc.)
              
                return false; // Assume invalid dates should be filtered out
              }
            }).toList();
          }

          // Convert filtered DateTime objects back to String
          staffAvailabilityhours =
              allHours.map((hour) => hour.toString()).toList();
          if (staffAvailabilityhours.isEmpty) {
            ElegantNotification.error(
              animationDuration: const Duration(milliseconds: 600),
              width: 360,
              position: Alignment.bottomCenter,
              animation: AnimationType.fromBottom,
              title: Text('Error'),
              description: Text("Pas d'heures disponibles."),
              onDismiss: () {},
            ).show(context);
          }

          setState(() {});
          
        } else {
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      ElegantNotification.error(
        animationDuration: const Duration(milliseconds: 600),
        width: 360,
        position: Alignment.bottomCenter,
        animation: AnimationType.fromBottom,
        title: const Text('Error'),
        description:
            const Text('Failed to connect, incorrect identifier or password'),
        onDismiss: () {},
      ).show(context);
      return;
    }
  }

  Future<void> storeBooking(
      String date,
      String staffId,
      String serviceId,
      String hour,
      String clientId,
      String paymentStatus,
      String bookingStatus) async {
    try {
      final response =
          await http.post(Uri.parse('$domain2/api/storeBooking'), body: {
        'date': date,
        'staff_id': staffId,
        'service_id': serviceId,
        'hour': hour,
        'client_id': clientId,
        'payment_status': paymentStatus,
        'booking_status': bookingStatus,
        'coupon': '',
        'description': '',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle success, if needed
      } else {
        print('Error: ${response.statusCode}');
        // Handle the error
      }
    } catch (error) {
      print('Error: $error');
      // Handle the error
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();

    fetchAvailableStaff();
  }

  late SharedPreferences _prefsss;
  String selectedLanguage = '';
  Future<void> _loadLanguage() async {
    _prefsss = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefsss.getString('selectedLanguage') ?? 'Frensh';
    });
    at_salons = translate(
        "Aller vers le salon", Reservation_Arabic, Reservation_English);
    at_home = translate("Commandez le service a domicile", Reservation_Arabic,
        Reservation_English);
  }

  Future<void> _saveLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });
    await _prefsss.setString('selectedLanguage', language);
  }

  String translate(
      String key, Map<String, String> Arabic, Map<String, String> Eglish) {
    if (selectedLanguage == "English") {
      return Eglish[key] ?? key;
    } else if (selectedLanguage == "Arabic") {
      return Arabic[key] ?? key;
    } else {
      return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            translate("Resevation", Reservation_Arabic, Reservation_English)),
        backgroundColor: const Color(0xFFD91A5B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (at_salon) _buildCheckbox(at_salons),
              const SizedBox(height: 20.0),
              if (home) _buildCheckbox(at_home),
              const SizedBox(height: 20.0),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: selectedOption == at_home ? 144.0 : 0.0,
                child: Visibility(
                  visible: selectedOption == at_home,
                  child: _buildSection(
                    title: translate(
                        "Adresse", Reservation_Arabic, Reservation_English),
                    child: _buildTextField(
                      onChanged: (value) {
                        setState(() {
                          adress = value;
                        });
                        print(adress);
                      },
                      hintText: translate("Entrez votre adresse ici",
                          Reservation_Arabic, Reservation_English),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: selectedOption == at_home ? 20.0 : 0.0,
                  child: Visibility(
                    child: Container(),
                  )),

              buildStaffSelectionUI(),
              const SizedBox(height: 20.0),
              _buildSection2(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: staffAvailabilityDates.isEmpty
                              ? null // Disable onTap if the list is empty
                              : () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: staffAvailabilityDates.isEmpty
                                  ? Colors
                                      .grey // Set to grey if the list is empty
                                  : const Color(0xFFD91A5B),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, color: Colors.white),
                                SizedBox(width: 8.0),
                                Text(
                                  translate("Choisir Date", Reservation_Arabic,
                                      Reservation_English),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        loading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.pink),
                              )
                            : GestureDetector(
                                onTap: staffAvailabilityhours.isNotEmpty
                                    ? () => _showAvailableHours(
                                            context, staffAvailabilityhours,
                                            () {
                                          setState(() {});
                                        })
                                    : null,
                                child: Opacity(
                                  opacity: staffAvailabilityhours.isNotEmpty
                                      ? 1.0
                                      : 0.5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD91A5B),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.access_time,
                                            color: Colors.white),
                                        SizedBox(width: 8.0),
                                        Text(
                                          translate(
                                              "Choisir l'heure",
                                              Reservation_Arabic,
                                              Reservation_English),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${translate("Date choisi:", Reservation_Arabic, Reservation_English)}  ${selectedDate.toLocal().toString().substring(0, 10)} | ${selectedTime.format(context)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFD91A5B),
                            fontWeight: FontWeight
                                .bold, // Added fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Option Section

              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9), // Light gray background
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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(right: 20.0),
                          child: Text(
                            translate("Téléphone", Reservation_Arabic,
                                Reservation_English),
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD91A5B),
                            ),
                            textAlign: selectedLanguage == "Arabic"
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CountryCodePicker(
                                      onChanged: (CountryCode country) {
                                        setState(() {
                                          _selectedCountry = country;
                                        });
                                      },
                                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                      initialSelection: 'MA',
                                      favorite: ['+212', 'MA'],
                                      // optional. Shows only country name and flag
                                      showCountryOnly: false,
                                      // optional. Shows only country name and flag when popup is closed.
                                      showOnlyCountryWhenClosed: false,
                                      // optional. aligns the flag and the Text left
                                      alignLeft: false,
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.phone,
                                        controller: phoneController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate(
                                                'Veuillez entrer votre numéro de téléphone',
                                                Reservation_Arabic,
                                                Reservation_English);
                                          } else if (value.length < 9) {
                                            return translate(
                                                'Le numéro de téléphone doit comporter au moins 9 chiffres',
                                                Reservation_Arabic,
                                                Reservation_English);
                                            ;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: translate(
                                              'Entrez votre numéro de téléphone',
                                              Reservation_Arabic,
                                              Reservation_English),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24.0),
                                Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      translate("Nom", Reservation_Arabic,
                                          Reservation_English),
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD91A5B),
                                      ),
                                      textAlign: selectedLanguage == "Arabic"
                                          ? TextAlign.right
                                          : TextAlign.left,
                                    )),
                                const SizedBox(height: 12.0),
                                TextFormField(
                                  controller: nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return translate(
                                          'Veuillez entrer votre nom',
                                          Reservation_Arabic,
                                          Reservation_English);
                                    } else if (value.length < 6) {
                                      return translate(
                                          'Le nom doit comporter au moins 6 caractères',
                                          Reservation_Arabic,
                                          Reservation_English);
                                      ;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: translate(
                                        "Entrez votre nom",
                                        Reservation_Arabic,
                                        Reservation_English),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 24.0),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Text(
                              translate("Message", Reservation_Arabic,
                                  Reservation_English),
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD91A5B),
                              ),
                              textAlign: selectedLanguage == "Arabic"
                                  ? TextAlign.right
                                  : TextAlign.left,
                            )),
                        const SizedBox(height: 12.0),
                        TextField(
                          minLines: 2,
                          maxLines: 5,
                          controller: backupController,
                          decoration: InputDecoration(
                            hintText: translate("Entrez votre message ici",
                                Reservation_Arabic, Reservation_English),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        )
                      ])),

              const SizedBox(height: 20.0),

// Coupon Code Section
              /*   _buildSection(
                title: 'Coupon Code',
                child: _buildTextField(
                  onChanged: (value) {
                    setState(() {
                      couponCode = value;
                    });
                  },
                  hintText: 'Enter your coupon code here',
                ),
              ),
              const SizedBox(height: 20.0),*/

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  !reserving
                      ? ElevatedButton(
                          onPressed: () async {
                            if (!reserving) {
                              setState(() {
                                reserving = true;
                              });

                              String adress_ = '';
                              String adress_home = "null";

                              if (selectedOption == at_home) {
                                adress_ = "client";
                              } else if (selectedOption == at_salons) {
                                adress_ = "salon";
                                adress_home = adress;
                              }
                              if (adress_home == '') {
                                adress_home = "null";
                              }
                              print('Selected Time: $selectedTime');
                              print('Current Time: ${TimeOfDay.now()}');
                              print('Address: $adress_');
                              print('At Home: $at_home');
                              print('Home Address: $adress_home');
                              print(
                                  'Backup Controller Text: ${backupController.text}');
                              print(
                                  'Phone Controller Text: ${phoneController.text}');
                              print(_formKey.currentState!.validate());
                              if (_formKey.currentState!.validate() &&
                                  selectedTime != TimeOfDay.now() &&
                                  adress_ != '' &&
                                  !(adress_ == at_home &&
                                      adress_home == "null") &&
                                  nameController.text != '') {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? localId =
                                    prefs.getString('id').toString();
                                String formattedHour = selectedTime.hour
                                    .toString()
                                    .padLeft(2, '0');
                                String formattedMinute = selectedTime.minute
                                    .toString()
                                    .padLeft(2, '0');
                                String formattedTime =
                                    '$formattedHour:$formattedMinute';

                                Map<String, dynamic> bookingData = {
                                  "date": selectedDate
                                      .toLocal()
                                      .toString()
                                      .substring(2, 10),
                                  "staff_id": id_staff,
                                  "service_id": widget.serviceId,
                                  "hour": formattedTime + ':00',
                                  "client_id": localId.toString(),
                                  "payment_status": "Payé",
                                  "booking_status": "reçu",
                                  "coupon": "",
                                  "description": backupController.text,
                                  "at_address": adress_,
                                  "phone_number": phoneController.text,
                                  "address": adress_home,
                                };
                                logger.i('Booking Data:');
                                bookingData.forEach((key, value) {
                                 
                                });
                                final response = await http.post(
                                  Uri.parse('$domain2/api/storeBooking'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json',
                                    // Add any additional headers as needed
                                  },
                                  body: jsonEncode(bookingData),
                                );

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  /* ElegantNotification.success(
                            animationDuration:
                                const Duration(milliseconds: 600),
                            width: 360,
                            notificationPosition:
                                NotificationPosition.bottomCenter,
                            animation: AnimationType.fromBottom,
                            title: const Text('success'),
                            description:
                                const Text('Reservastion bien accomplis'),
                            onDismiss: () {},
                          ).show(context);*/
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // Prevent dialog from disappearing on tap outside
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        backgroundColor: Colors
                                            .pink, // Change to your desired pink color
                                        title: Text(
                                          translate(
                                              'Succès',
                                              Reservation_Arabic,
                                              Reservation_English),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Text(
                                          translate(
                                              'Réservation bien accomplie',
                                              Reservation_Arabic,
                                              Reservation_English),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              // primary: Colors.white,
                                              // onPrimary: Colors.pink,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Booked(),
                                                ),
                                              );
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: response.body,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                    // Use an error icon for failure
                                    webShowClose: true,
                                    webBgColor: "#F44336",
                                    webPosition: "center",
                                    timeInSecForIosWeb: 2,
                                  );
                                  print(
                                      'Failed to send booking data. Status code: ${response.statusCode}');
                                  print('Response body: ${response.body}');
                                }
                              } else {
                                ElegantNotification.error(
                                  animationDuration:
                                      const Duration(milliseconds: 600),
                                  width: 360,
                                  position: Alignment.bottomCenter,
                                  animation: AnimationType.fromBottom,
                                  title: const Text('Error'),
                                  description:
                                      const Text('Complete formulaire'),
                                  onDismiss: () {},
                                ).show(context);
                              }
                              setState(() {
                                reserving = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            // primary: const Color(0xFFD91A5B), // Pink color
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, // Bold text
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Adjust the radius as needed
                            ),
                            minimumSize: const Size(150.0,
                                50.0), // Adjust the width and height as needed
                            elevation: 5.0, // Add elevation (shadow)
                          ),
                          child: Text(
                            translate("Réserver maintenant", Reservation_Arabic,
                                Reservation_English),
                          ),
                        )
                      : CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.pink),
                        ),
                  const SizedBox(height: 12.0),
                  widget.promo != '0'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.promo.toString()} Dh",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD91A5B),
                              ),
                            ),
                            Text(
                              "${widget.price.toString()} Dh",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "${widget.price.toString()} Dh",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD91A5B),
                          ),
                        )
                  /*Text(
                    '${translate("Prix", Reservation_Arabic, Reservation_English)}: ${calculateTotalPrice()} Dh',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFFD91A5B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String calculateTotalPrice() {
    return widget.price;
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Light gray background
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD91A5B),
            ),
          ),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required ValueChanged<String> onChanged,
    required String hintText,
  }) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSection2({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
        ],
      ),
    );
  }

  Widget _buildCheckbox(String option) {
    bool isSelected = selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          selectedOption = option;
        });
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD91A5B) : Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  isSelected = value ?? false;
                  selectedOption = isSelected ? option : null;
                });
              },
              activeColor: const Color(0xFFD91A5B),
            ),
            const SizedBox(width: 8.0),
            Text(
              option,
              style: TextStyle(
                fontSize: 16.0,
                color: isSelected ? Colors.white : const Color(0xFFD91A5B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool preficate(DateTime day) {
    // If initialDate is provided, check if it's selectable
    if (day.isAtSameMomentAs(selectedDate)) {
      return staffAvailabilityDates.contains(selectedDate.toString());
    }

    // Check if the day is selectable
    return staffAvailabilityDates.contains(day.toString());
  }

  Future<void> _selectDate(BuildContext context) async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String formattedDate =
        dateFormat.format(DateTime.parse(staffAvailabilityDates[0]));
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(formattedDate).add(const Duration(days: 0)),
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
      selectableDayPredicate: preficate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFD91A5B),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD91A5B), // Button color
            ).copyWith(secondary: const Color(0xFFD91A5B)),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null &&
        staffAvailabilityDates.contains(pickedDate.toString())) {
      setState(() {
        selectedDate = pickedDate;
      });
      setState(() {
        loading = true;
      });
      await fetchAvailableHours();
      setState(() {
        loading = false;
      });
    } else {}
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFD91A5B),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD91A5B), // Button color
            ).copyWith(secondary: const Color(0xFFD91A5B)),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    } else {
      ElegantNotification.error(
        animationDuration: const Duration(milliseconds: 600),
        width: 360,
        position: Alignment.bottomCenter,
        animation: AnimationType.fromBottom,
        title: const Text('Error'),
        description: const Text(
            'Échec de la connexion, identifiant ou mot de passe incorrect'),
        onDismiss: () {},
      ).show(context);
    }
  }

  Widget buildStaffSelectionUI() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
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
            translate("Choisir un staff", Reservation_Arabic,
                    Reservation_English) +
                ' :',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD91A5B)),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: stf.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedStaffIndex == index;

              return GestureDetector(
                onTap: () async {
                  setState(() {
                    id_staff = stf[index].id;
                    selectedStaffIndex = isSelected ? null : index;
                  });
                  print("tapepd");

                  await fetchStaffAvailability(stf[index].id);
                },
                child: Container(
                  width: double.infinity,
                  //  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xFFD91A5B)
                        : Colors.white, // Change color here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(stf[index].avatarUrl),
                          ),
                          SizedBox(width: 10),
                          Container(
                              width: MediaQuery.of(context).size.width - 200,
                              child: Text(
                                stf[index].name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              )),
                        ],
                      ),
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) async {
                          setState(() {
                            id_staff = stf[index].id;
                            selectedStaffIndex = value! ? index : null;
                          });
                          print("tapepd");
                          await fetchStaffAvailability(stf[index].id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          /* SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedStaffIndex != null) {
                Staff selectedStaff = stf[selectedStaffIndex!];
                // Do something with the selected staff
                print(
                  'Selected Staff: ${selectedStaff.name}, ID: ${selectedStaff.id}',
                );
              } else {
                // Handle the case where no staff is selected
                print('No staff selected');
              }
            },
            child: Text('Confirm Selection'),
          ),*/
        ],
      ),
    );
  }

  String selectAvailableHourText() {
    if (selectedLanguage == "English") {
      return 'Select Available Hour';
    } else if (selectedLanguage == "Arabic") {
      return 'اختر الساعة المتاحة';
    } else if (selectedLanguage == "French") {
      return 'Sélectionnez l\'heure disponible';
    } else {
      return "Sélectionnez l\'heure disponible  ";
    }
  }

  void _showAvailableHours(
      BuildContext context, List<dynamic> availableHours, Function doit) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectAvailableHourText(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(availableHours.length, (index) {
                          String hour = availableHours[index];
                          return ListTile(
                            title: Text(hour.substring(0, 5)),
                            leading: Radio<String>(
                              value: hour,
                              groupValue: selectedHour,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedHour = value!;
                                  selectedTime = TimeOfDay(
                                      hour: int.parse(
                                          selectedHour.substring(0, 2)),
                                      minute: int.parse(
                                          selectedHour.substring(3, 5)));
                                });
                              },
                            ),
                            onTap: () {
                              selectedHour = hour;
                              setState(() {});
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedHour = selectedHour;
                        selectedTime = TimeOfDay(
                            hour: int.parse(selectedHour.substring(0, 2)),
                            minute: int.parse(selectedHour.substring(3, 5)));
                      });
                      print('Selected hour: $selectedHour');
                      doit();
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
