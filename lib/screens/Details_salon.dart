import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/stars_reviews.dart';
import 'package:spa/page_transltion/service_details_tr.dart';
import 'package:spa/screens/Details.dart';
import 'package:spa/screens/book.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:html/parser.dart' show parse;
import 'package:share_plus/share_plus.dart';
import 'package:spa/screens/chat_details.dart';
import 'package:spa/Models/comment.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/signUp_view.dart';

class SalonDetails extends StatefulWidget {
  final String id;
  SalonDetails({key, required this.id});

  @override
  _SalonDetailsState createState() => _SalonDetailsState();
}

class _SalonDetailsState extends State<SalonDetails> {
  List<Review> reviews = [];
  bool isStarred = false;
  SwiperController swiperController = SwiperController();
  Timer? timer;
  int currentIndex = 0;
  String email = '';
  String phone = '';
  double latitude = 3;
  double longitude = 3;
  String adress = '';
  String genre = '';
  String logo = '';
  String Tottal_review = '0';
  String avrage_review = '0';
  List<Map<String, dynamic>> availabilityData = [];
  bool isOpenNow = false;
  String name = '';
  String description = '';
  List<String> images = [];

  List<String> sectionChoices = [];

  String selectedSection = 'Details';
  List<Service2> yourServiceList = [];
  Future<void> _fetchAndStoreServiceDetails() async {
    try {
      final response =
          await http.post(Uri.parse('$domain2/api/getSalonsFromMaps'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['salons'] != null) {
          List<dynamic> salonList = data['salons'];

          // Find the salon with id = 1
          Map<String, dynamic>? targetSalon;

          for (var salon in salonList) {
            print(widget.id);
            if (salon['id'].toString() == widget.id) {
              targetSalon = salon;
              break;
            }
          }

          if (targetSalon != null) {
            setState(() {
              email = targetSalon!['address'];
              name = targetSalon['name'];
              logo = "$domain2/storage/" + targetSalon['logo'].toString();
              adress = targetSalon['address'];
              genre = targetSalon['genre'];
              description = extractPlainText(targetSalon['description']);
              Tottal_review =
                  targetSalon['reviews']["total_reviews"].toString();
              avrage_review =
                  targetSalon['reviews']["average_rating"].toString();
              phone = targetSalon['phone_number'];
              availabilityData = List<Map<String, dynamic>>.from(
                  targetSalon['disponibility'] ?? []);
              images = List<String>.from(targetSalon['media'].map((item) {
                return item['original_url'];
              }));
              if (images.isEmpty) {
                images
                    .add("https://spabooking.pro/assets/no-image-18732f44.png");
              }
              if (targetSalon['address_map'].toString() != 'null') {
                final Map<String, dynamic> addressMap =
                    json.decode(targetSalon['address_map']);

                latitude = double.parse(addressMap['lat']);
                longitude = double.parse(addressMap['lon']);
              }
            });
            print('Email: $email');
            print('Address: $adress');
            print('Phone: $phone');
            print('Description: $description');
            print('Latitude: $latitude');
            print('Longitude: $longitude');
            print('Images: $images');
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

    isSalonOpenNow();

    try {
      final response = await http.get(
        Uri.parse('$domain2/api/getServiceBySalonId/${widget.id}'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['services'] != null) {
          List<dynamic> services = data['services'];

          List<Service2> latestServices = services.map((service) {
            List<dynamic> mediaList = service['media'] as List<dynamic>;

            String mainImage =
                mediaList.isNotEmpty ? mediaList[0]['original_url'] : '';

            List<String> sideImages = mediaList
                .where((media) => media['original_url'] != null)
                .map((media) => media['original_url'].toString())
                .toList();

            String stars = (service['reviews'] != null &&
                    service['reviews']['average_rating'] != null)
                ? service['reviews']['average_rating'].toString()
                : "0.0";
            print(
              "salon id is : " + service['id'].toString(),
            );
            return Service2(
              promo: service['discount_price'] ?? '0',
              price: service['price'],
              name: service['name'],
              id: service['id'],
              mainImage: mainImage,
              sideImages: sideImages,
              location: service['duration'],
              stars: double.parse(stars),
              type: service['genre'],
            );
          }).toList();

          setState(() {
            yourServiceList = latestServices;
          });

          print('Latest services: $latestServices');
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
      final response = await http.post(
        Uri.parse('$domain2/api/getAllReviewBySalonId'),
        body: {'salon_id': widget.id},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> revie = json.decode(response.body);

        print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
        List<Review> storedReviews = revie.map((review) {
          return Review(
            avatar:
                "https://static.vecteezy.com/system/resources/previews/019/896/008/original/male-user-avatar-icon-in-flat-design-style-person-signs-illustration-png.png",
            // Replace with the actual avatar field
            comment: review['review'],
            stars: int.parse(review['rate'].toString()),
            commentDate: review['created_at'],
            commentOwner: review['user']['name'],
          );
        }).toList();

        setState(() {
          reviews = storedReviews;
        });
        print('Stored Reviews: $storedReviews');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? localId = prefs.getString('id').toString();
      final response = await http.post(
        Uri.parse('$domain2/api/getFavoriteByClientAndSalonId'),
        body: {
          "client_id": localId.toString(),
          "type": "salon",
          "salon_id": widget.id.toString()
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isStarred = true;
        });
      } else {
        print('Error 9: ${response.statusCode}');
      }
    } catch (error) {
      print('Error 8: $error');
    }
  }

  String details = 'Détails';
  String Services = 'Services';
  String Galerie = "Galerie";
  String Reviews = "Avis";
  @override
  void initState() {
    super.initState();
    print("salon ID = " + widget.id.toString());
    _loadLanguage();

    _fetchAndStoreServiceDetails();
    startAutoSlide();
  }

  @override
  void dispose() {
    swiperController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startAutoSlide() {
    timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      if (currentIndex < images.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      swiperController.move(currentIndex);
    });
  }

  Widget _buildCustomIcon(IconData iconData) {
    return Stack(
      children: [
        Icon(iconData, color: Colors.white),
        Positioned(
          child: Icon(Icons.circle, color: Color(0xFFD91A5B), size: 8.0),
          left: 8.0,
          top: 8.0,
        ),
      ],
    );
  }

  late SharedPreferences _prefsss;
  String selectedLanguage = '';
  Future<void> _loadLanguage() async {
    _prefsss = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefsss.getString('selectedLanguage') ?? 'Frensh';
    });
    details = selectedLanguage == "English"
        ? translate('Détails', service_details_English)
        : selectedLanguage == "Arabic"
            ? translate('Détails', service_details_Arabic)
            : 'Détails';
    selectedSection = details;
    Services = selectedLanguage == "English"
        ? translate('Services', service_details_English)
        : selectedLanguage == "Arabic"
            ? translate('Services', service_details_Arabic)
            : 'Services';
    Galerie = selectedLanguage == "English"
        ? translate('Galerie', service_details_English)
        : selectedLanguage == "Arabic"
            ? translate('Galerie', service_details_Arabic)
            : 'Galerie';
    Reviews = selectedLanguage == "English"
        ? translate('Avis', service_details_English)
        : selectedLanguage == "Arabic"
            ? translate('Avis', service_details_Arabic)
            : 'Avis';
    sectionChoices = [
      details,
      Services,
      Galerie,
      Reviews,
    ];
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
      floatingActionButton: (selectedSection != Services)
          ? Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedSection = Services;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          // primary: const Color(0xFFD91A5B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: Text(
                          selectedLanguage == "English"
                              ? translate(
                                  'Liste des services', service_details_English)
                              : selectedLanguage == "Arabic"
                                  ? translate('Liste des services',
                                      service_details_Arabic)
                                  : 'Liste des services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      )),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String? localId = prefs.getString('id');
                          if (localId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(idsalon: widget.id, name: name),
                              ),
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
                                      color: Color(
                                          0xFFD91A5B), // Add border color here
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
                                            icon: Icon(Icons
                                                .login), // Add the login icon
                                            label: Text(selectedLanguage ==
                                                    "English"
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
                          /*  showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BottomSheetForm(
                                idsalon: widget.id,
                              );
                            },
                          );*/
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
                              ? translate(
                                  'Contacter le salon', service_details_English)
                              : selectedLanguage == "Arabic"
                                  ? translate('Contacter le salon',
                                      service_details_Arabic)
                                  : 'Contacter le salon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      )),
                ],
              ),
            )
          : Container(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              /*  decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFD91A5B),
                    width: 2.0,
                  ),
                ),
              ),*/
              child: Swiper(
                controller: swiperController,
                itemBuilder: (BuildContext context, int index) {
                  return CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: (context, url, error) => CachedNetworkImage(
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
                  );
                },
                itemCount: images.length,
                control: const SwiperControl(
                  color: Color(0xFFD91A5B),
                  size: 30.0,
                  iconPrevious: Icons.arrow_back,
                  iconNext: Icons.arrow_forward,
                ),
                pagination: const SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                    color: Color.fromARGB(
                        255, 228, 161, 183), // Set inactive dot color
                    activeColor:
                        Color(0xFFD91A5B), // Set active dot color to pink
                    activeSize: 10.0,
                    size: 8.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.26,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 40,
                          height: 40,
                          /* decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),*/
                          child: Center(
                              child: CachedNetworkImage(
                            imageUrl: logo,
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
                          ))),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical:
                                5), // Set padding to 10 horizontal and 5 vertical

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              10), // Set border radius to 10
                        ),
                        child: Row(
                          children: [
                            buildGenderText(genre),
                            buildGenderIcons(genre)
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isOpenNow ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              isOpenNow
                                  ? selectedLanguage == "English"
                                      ? translate(
                                          'Ouvert', service_details_English)
                                      : selectedLanguage == "Arabic"
                                          ? translate(
                                              'Ouvert', service_details_Arabic)
                                          : 'Ouvert'
                                  : selectedLanguage == "English"
                                      ? translate(
                                          'Fermé', service_details_English)
                                      : selectedLanguage == "Arabic"
                                          ? translate(
                                              'Fermé', service_details_Arabic)
                                          : 'Fermé',
                              style: TextStyle(
                                color: isOpenNow ? Colors.white : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                                width: 4), // Add space between text and icon
                            Icon(
                              isOpenNow ? Icons.check_circle : Icons.lock,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
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
            ),
          ),
          Positioned(
            top: 35.0,
            left: 60,
            right: 100,
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
          Positioned(
            top: 40.0,
            right: 10.0,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isStarred = !isStarred;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        isStarred ? Colors.transparent : Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        isStarred ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFD91A5B),
                        size: 30,
                      ),
                      onPressed: () async {
                        if (!isStarred) {
                          await storeFavorite();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Add some spacing between the icons
                GestureDetector(
                  onTap: () {
                    // Replace 'your_link_here' with the actual link you want to share
                    Share.share('https://spabooking.pro/');
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Color(0xFFD91A5B),
                        size: 30,
                      ),
                      onPressed: () {
                        // Replace 'your_link_here' with the actual link you want to share
                        Share.share('https://spabooking.pro/');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: sectionChoices
                      .map(
                        (choice) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSection = choice;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            margin: const EdgeInsets.only(
                                right: 8.0), // Add margin for spacing
                            decoration: BoxDecoration(
                              color: choice == selectedSection
                                  ? const Color(0xFFD91A5B)
                                  : const Color.fromARGB(255, 217, 217,
                                      217), // Set grey color when unselected
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              choice,
                              style: TextStyle(
                                color: choice == selectedSection
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          if (selectedSection == details)
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.36 + 50,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSection(
                      title: selectedLanguage == "English"
                          ? translate('Description', service_details_English)
                          : selectedLanguage == "Arabic"
                              ? translate('Description', service_details_Arabic)
                              : 'Description',
                      content: description,
                    ),
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
                            Reviews,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD91A5B),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.spa,
                                      color: Color(0xFFD91A5B)),
                                  Text(
                                      '  ${selectedLanguage == "English" ? translate('Avis totaux', service_details_English) : selectedLanguage == "Arabic" ? translate('Avis totaux', service_details_Arabic) : 'Avis totaux'}: $Tottal_review '),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color(0xFFD91A5B)),
                                  Text(
                                      '  ${selectedLanguage == "English" ? translate('Moyenne', service_details_English) : selectedLanguage == "Arabic" ? translate('Moyenne', service_details_Arabic) : 'Moyenne'}: $avrage_review'),
                                ],
                              ),
                              const SizedBox()
                            ],
                          ),
                          const SizedBox(height: 12.0),
                        ],
                      ),
                    ),
                    _buildSection(
                      title: selectedLanguage == "English"
                          ? translate('Contactez-nous', service_details_English)
                          : selectedLanguage == "Arabic"
                              ? translate(
                                  'Contactez-nous', service_details_Arabic)
                              : 'Contactez-nous',
                      content: [
                        //_buildContactRow(Icons.email, "Email doesn't exist"),
                        _buildContactRow(Icons.phone, phone),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildContactRow(
                            Icons.message,
                            selectedLanguage == "English"
                                ? translate('Envoyer un message',
                                    service_details_English)
                                : selectedLanguage == "Arabic"
                                    ? translate('Envoyer un message',
                                        service_details_Arabic)
                                    : 'Envoyer un message'),
                      ],
                    ),
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
                          // Display availability for each day of the week
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  buildAvailabilityText(day),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildSection(
                      title: selectedLanguage == "English"
                          ? translate('localisation', service_details_English)
                          : selectedLanguage == "Arabic"
                              ? translate(
                                  'localisation', service_details_Arabic)
                              : 'localisation',
                      content: [
                        _buildLocationMap(),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildLocationRow(
                          Icons.location_on,
                          adress, // Replace with your actual address
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          if (selectedSection == Services)
            Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.36 + 50,
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
                )),
          if (selectedSection == Galerie)
            Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.36 + 50,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Adjust the margin as needed
                  child: Column(
                    children: [
                      if (images.isNotEmpty)
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: images.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _calculateCrossAxisCount(context),
                              mainAxisSpacing: 14.0,
                              crossAxisSpacing: 14.0,
                            ),
                            itemBuilder: (context, index) {
                              String imageUrl = images[index];
                              return GestureDetector(
                                onTap: () {
                                  // Show the larger image in a dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 300.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    /*  height: MediaQuery.of(context).size.width /
                                    _calculateCrossAxisCount(context),*/
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                )),
          if (selectedSection == Reviews)
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.36 + 50,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildReviewListView(),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    // Adjust the breakpoint value as needed
    double breakpoint = 600.0;

    // Determine the cross-axis count based on screen width
    int crossAxisCount = MediaQuery.of(context).size.width < breakpoint ? 2 : 3;

    return crossAxisCount;
  }

  Widget _buildServiceListView() {
    if (yourServiceList.isEmpty) {
      // Display a placeholder widget when no data is available
      return Center(
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
              'No available services',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFD91A5B),
              ),
            ),
          ],
        ),
      ));
    } else {
      // Display the list of services when data is available
      return ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: yourServiceList.length,
        itemBuilder: (context, index) {
          var service = yourServiceList[index];

          return _buildServiceListTile(
            promo: service.promo,
            imageUrl: service.mainImage,
            nonService: service.name,
            timeStarting: service.location,
            price: service.price,
            averageRating: service.type,
            id: service.id,
          );
        },
      );
    }
  }

  Widget _buildServiceListTile({
    required String imageUrl,
    required String nonService,
    required String timeStarting,
    required String price,
    required String promo,
    required String averageRating,
    required int id,
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
          ListTile(
            onTap: () {
              // Handle service item click
            },
            contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 5.0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                width: 70.0,
                height: 70.0,
                fit: BoxFit.cover,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    nonService,
                    style: const TextStyle(
                      color: Color(0xFFD91A5B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 3, // Set the maximum number of lines
                    softWrap: true, // Allow the text to wrap to the next line
                    overflow: TextOverflow
                        .ellipsis, // Display ellipsis (...) if the text overflows
                  ),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
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
                ]),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                Text(
                  'Duration: ${timeStarting.substring(0, 1)} h ${timeStarting.substring(2)} min',
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    buildGenderTextsimple(averageRating.replaceAll(',', '')),
                    const SizedBox(width: 4.0),
                    buildGenderIcons(averageRating.replaceAll(',', ''))
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 30,
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
                                    serviceId: id.toString(),
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
                                  color: Color(
                                      0xFFD91A5B), // Add border color here
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
                                        label:
                                            Text(selectedLanguage == "English"
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
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Details(
                                  ID: id,
                                  backgroundImageUrl: imageUrl,
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
                          ? translate("Voir détails", service_details_English)
                          : selectedLanguage == "Arabic"
                              ? translate(
                                  "Voir détails", service_details_Arabic)
                              : "Voir détails",
                      style: TextStyle(
                        color: Color(0xFFD91A5B),
                        fontSize: 16.0,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    dynamic content,
    String additionalContent = '',
  }) {
    return Container(
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
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD91A5B),
            ),
          ),
          const SizedBox(height: 12.0),
          _buildContent(content),
          const SizedBox(height: 12.0),
          if (additionalContent.isNotEmpty)
            Text(
              additionalContent,
              style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic content) {
    if (content is String) {
      return Text(
        content,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey[800],
        ),
      );
    } else if (content is List<Widget>) {
      return Column(
        children: content,
      );
    }
    return Container();
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD91A5B)),
        const SizedBox(width: 12.0),
        Text(
          text,
          style: TextStyle(fontSize: 12.0, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildAvailabilityRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$day:',
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8.0),
        // Rounded container for hours
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFD91A5B),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            (day == 'Saturday')
                ? '08:00 - 14:00'
                : (day != 'Sunday')
                    ? '08:00 - 20:00'
                    : 'Not Available',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMap() {
    return SizedBox(
      height: 200.0, // Set the height as needed
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.5333312, -7.583331), // Example coordinates
          zoom: 5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('your_location_marker'),
            position: LatLng(latitude, longitude), // Example coordinates
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'This is your location',
            ),
          ),
        },
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String address) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD91A5B)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            address, // Replace with your actual address
            style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.directions, color: Color(0xFFD91A5B)),
          onPressed: () {
            // Handle direction button press
          },
        ),
      ],
    );
  }

  Widget _buildReviewListView() {
    // Calculate the average rating
    double averageRating = reviews.isNotEmpty
        ? (reviews.map((review) => review.stars).reduce((a, b) => a + b) /
                reviews.length)
            .floorToDouble()
        : 0;
    double averageRat = reviews.isNotEmpty
        ? (reviews.map((review) => review.stars).reduce((a, b) => a + b) /
            reviews.length)
        : 0;
    averageRat.toStringAsFixed(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD91A5B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedLanguage == "English"
                        ? translate('Note moyenne : ', service_details_English)
                        : selectedLanguage == "Arabic"
                            ? translate(
                                'Note moyenne : ', service_details_Arabic)
                            : 'Note moyenne : ',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  StarRating(rating: averageRating),
                  Text(
                    " ${averageRat.toStringAsFixed(1)}  ( ${reviews.length.toString()} ) ",
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )),
            Center(
                child: ElevatedButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? localId = prefs.getString('id');
                if (localId != null) {
                  _showRatingDialog();
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
              icon: Icon(Icons.comment, color: Colors.white),
              label: Text(
                selectedLanguage == "English"
                    ? translate(
                        "Ajoutez votre commentaire", service_details_English)
                    : selectedLanguage == "Arabic"
                        ? translate(
                            "Ajoutez votre commentaire", service_details_Arabic)
                        : "Ajoutez votre commentaire",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                // primary: Color(0xFFD91A5B),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  reviews.map((review) => _buildReviewItem(review)).toList(),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomRatingDialog(
          name: name,
          id: widget.id,
          setst: () {
            _fetchAndStoreServiceDetails();
          },
        );
      },
    );
  }

  Widget _buildReviewItem(Review review) {
    return Center(
        child: Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        review.avatar), // Replace with your actual image URL
                    radius: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    review.commentOwner,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < review.stars
                        ? const Color(0xFFD91A5B)
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            DateFormat('dd MMM yyyy').format(
              DateTime.parse(review.commentDate),
            ),
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        ],
      ),
    ));
  }

  Widget buildAvailabilityText(String day) {
    Map<String, dynamic> L = {};

    var availability = availabilityData.firstWhere(
        (availability) => availability['day'] == day,
        orElse: () => L);

    if (availability != null) {
      String startTime = availability['start_at'].toString();
      String endTime = availability['end_at'].toString();

      return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFD91A5B),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            startTime.toString() != "null"
                ? '${startTime.toString().substring(0, 5)} - ${endTime.toString().substring(0, 5)}'
                : 'No data available',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ));
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

  bool generateText(String day) {
    Map<String, dynamic> L = {};

    var availability = availabilityData.firstWhere(
        (availability) => availability['day'] == day,
        orElse: () => L);

    if (availability != null) {
      String startTime = availability['start_at'].toString();
      String endTime = availability['end_at'].toString();

      return startTime.toString() != "null" ? true : false;
    } else {
      return false;
    }
  }

  String extractPlainText(String htmlContent) {
    var document = parse(htmlContent);
    return parse(document.body!.text).documentElement!.text;
  }

  isSalonOpenNow() {
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
        setState(() {
          isOpenNow = false;
        });
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
      if (getCurrentDayNameInFrench() == day &&
          currentTime.hour > startTime.hour &&
          currentTime.hour < endTime.hour) {
        print(
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " +
                endTime.hour.toString());
        setState(() {
          isOpenNow = true;
        });
        return true;
      } else {
        // Salon is not open now
        setState(() {
          isOpenNow = false;
        });
      }

      //  return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
    }
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

  Future<void> storeFavorite() async {
    setState(() {
      isStarred = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localId = prefs.getString('id').toString();
    Map<String, String> headers = {
      "client_id": localId.toString(),
      "salon_id": widget.id.toString(),
      "type": "salon",
    };

    // Make the API call
    try {
      final response = await http.post(
        Uri.parse('$domain2/api/storeFavorite'),
        body: {
          "client_id": localId.toString(),
          "salon_id": widget.id.toString(),
          "type": "salon",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isStarred = true;
        });
        print("API call successful");
      } else {
        // API call failed, handle the error
        print(
            "API call failed with status code ${response.statusCode} : ${response.body} ");
      }
    } catch (e) {
      // Handle exceptions or network errors
      print("Error during API call: $e");
    }
  }

  removefav() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? localId = prefs.getString('id').toString();
      final response = await http.post(
        Uri.parse('$domain2/api/getFavoriteByClientAndSalonId'),
        body: {
          "client_id": localId.toString(),
          "type": "salon",
          "salon_id": widget.id.toString()
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isStarred = true;
        });
      } else {
        print('Error 9: ${response.statusCode}');
      }
    } catch (error) {
      print('Error 8: $error');
    }
  }
}

class Service2 {
  final String name;
  final int id;
  final String mainImage;
  final List<String> sideImages;
  final String location;
  final double stars;
  final String type;
  final String price;
  final String promo;

  Service2({
    required this.name,
    required this.id,
    required this.mainImage,
    required this.sideImages,
    required this.location,
    required this.stars,
    required this.type,
    required this.price,
    required this.promo,
  });
}

class Review {
  final String avatar;
  final String comment;
  final int stars;
  final String commentDate;
  final String commentOwner;

  Review({
    required this.avatar,
    required this.comment,
    required this.stars,
    required this.commentDate,
    required this.commentOwner,
  });
}
