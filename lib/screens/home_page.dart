import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/Models/Drawer.dart';
import 'package:spa/Models/cities.dart';
import 'package:spa/Models/city_cart.dart';
import 'package:spa/Models/service.dart';
import 'package:spa/Models/place_list.dart';
import 'package:spa/Models/services_view.dart';
import 'package:spa/page_transltion/drawer_tr.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:spa/screens/List_salon.dart';
import 'package:spa/screens/login_view.dart';
import 'package:spa/screens/search_map.dart';
import 'package:spa/screens/searchqueries.dart';
import 'package:spa/screens/services_list.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controllertext = TextEditingController();

  bool isListVisible = true;
  // late AnimationController _controller;
  // late Animation<double> _animation;
  bool isListVisible2 = true;
  // late AnimationController _controller2;
  // late Animation<double> _animation2;
  bool isSearchVisible = false;
  List<City> Allcities = [];
  List<String> selectedOptions = [];
  List<String> images = ["", "", ""];
  List<String> titles = ["", "", ""];
  List<String> buttons = ["", "", ""];
  List<String> links = ["", "", ""];

  // List of options with labels and icons
  List<Map<String, dynamic>> options = [];

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  List<Map<String, dynamic>> updatedOptions = [];
  List<PLaces2> placeses = [];
  List<PLaces2> Recomanded = [];
  List<PLaces2> All_services = [];
  TextEditingController controller = TextEditingController();
  final SwiperController _swiperController = SwiperController();

  final List<Service> services = [];
  getSlides() async {
    List<String> imageUrls = [];
    List<String> titless = [];
    List<String> buttonss = [];
    List<String> lo = [];
    try {
      final response = await http.get(
        Uri.parse('$domain2/api/getSlides'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['slides'] != null) {
          List<dynamic> slides = data['slides'];

          for (var slide in slides) {
            List<dynamic> mediaList = slide['media'];
            titless.add(slide["title"]);
            buttonss.add(slide["title_button"]);
            lo.add(slide["link"]);
            for (var media in mediaList) {
              String imageUrl = media['original_url'].toString();
              imageUrls.add(imageUrl);
            }
          }
          setState(() {
            images = imageUrls;
            titles = titless;
            buttons = buttonss;
            links = lo;
          });
        } else {
          print('Error 4 : Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    setState(() {});
  }

  getSalons() async {
    try {
      final response = await http.get(
        Uri.parse('$domain2/api/getSalons'),
        headers: {
          "page": "1",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['salons'] != null) {
          List<dynamic> salons = data['salons'];

          salons.sort((a, b) {
            DateTime dateA = DateTime.parse(a['created_at']);
            DateTime dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA); // Sort in descending order
          });

          List<PLaces2> latestPlaces = salons
              .map((salon) {
                // Check if 'media' is present and not empty
                List<dynamic> mediaList = salon['media'] as List<dynamic>;
                String mainImage = mediaList.isNotEmpty ? mediaList[0]['original_url'] : '';

                // Extract all side images from 'original_url' in 'media'
                List<String> sideImages = mediaList.map((media) => media['original_url'].toString()).toList();
                if (sideImages.isEmpty) {
                  sideImages.add("https://spabooking.pro/assets/no-image-18732f44.png");
                }
                String stars = (salon['reviews'] != null && salon['reviews']['average_rating'] != null) ? salon['reviews']['average_rating'].toString() : "0.0";

                // Convert salon data to PLaces2 format
                return PLaces2(
                  promo: salon['discount_price'] ?? '0',
                  Price: "0",
                  name: salon['name'].toString(),
                  id: salon['id'],
                  mainImage: mainImage,
                  sideImages: sideImages,
                  location: salon['city'].toString(),
                  stars: double.parse(stars),
                  type: salon['genre'].toString(),
                );
              })
              .toList()
              .take(8)
              .toList();

          setState(() {
            placeses = latestPlaces;
          });

// Optionally, you can print or use the latest placeses
        } else {
          print('Error 5 : Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    setState(() {});
  }

  getRecommended() async {
    try {
      final response = await http.get(Uri.parse('$domain2/api/getRecommendedSalons'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['recommended_salons'] != null) {
          List<dynamic> salons = data['recommended_salons'];

          List<PLaces2> latestPlaces = salons
              .map((salon) {
                List<dynamic> mediaList = salon['media'] as List<dynamic>;

                String mainImage = mediaList.isNotEmpty ? mediaList[0]['original_url'] : '';

                // Extract all side images from 'original_url' in 'media'
                List<String> sideImages = mediaList.where((media) => media['original_url'] != null).map((media) => media['original_url'].toString()).toList();

                String stars = (salon['reviews'] != null && salon['reviews']['average_rating'] != null) ? salon['reviews']['average_rating'].toString() : "0.0";

                // Convert salon data to PLaces2 format
                return PLaces2(
                  promo: salon['discount_price'] ?? '0',
                  Price: "0",
                  name: salon['name'],
                  id: salon['id'],
                  mainImage: mainImage,
                  sideImages: sideImages,
                  location: salon['city'].toString(),
                  stars: double.parse(stars),
                  type: salon['genre'],
                );
              })
              .toList()
              .take(8)
              .toList();

          setState(() {
            Recomanded = latestPlaces;
          });

          // Optionally, you can print or use the latest places
        } else {
          print('Error  33 : Invalid response structure');
        }
      } else {
        print('Error 2: ${response.statusCode}');
      }
    } catch (error) {
      print('Error 3: $error');
    }
    setState(() {});
  }

  Future<void> getcities() async {
    try {
      final response = await http.get(
        Uri.parse('$domain2/api/getAllCities'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['city'] != null) {
          List<dynamic> citiesData = data['city'];

          List<City> cities = citiesData.map((cityData) {
            return City(
              id: cityData['id'],
              name: cityData['name'],
              image: cityData['image'] != null ? ("$domain2/storage/" + (cityData['image'].toString())) : "https://demofree.sirv.com/nope-not-here.jpg",
            );
          }).toList();
          setState(() {
            Allcities = cities;
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
    setState(() {});
    // Return an empty list if there is an error
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _fetchAndStoreSalons() async {
    // fetchCategories();

    await getSlides();
    await getSalons();
    await getRecommended();
    await getcities();

   await fetchInitialData();
    setState(() {});
  }

  Future<List<PLaces2>?> finilize(int id) async {
    List<PLaces2>? services = await getServicesByCategoryId(id);

    if (services != null) {
      // Iterate through the list of services
      for (PLaces2 service in services) {
        try {
          final response = await http.get(
            Uri.parse('$domain2/api/getServiceById/${service.id}'),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final Map<String, dynamic> serviceData = json.decode(response.body);

            service.mainImage = serviceData['service']['image'];

            List<dynamic>? mediaList = serviceData['service']['media'];

            if (mediaList != null) {
              // Filter out null original URLs and extract side images
              List<String> sideImages = mediaList.where((media) => media['original_url'] != null).map((media) => media['original_url'].toString()).toList();

              service.sideImages = sideImages;
            } else {
              // Handle the case where mediaList is null
              print('Error: Media list is null');
            }
          }
        } catch (error) {
          print('Error fetching service details 2: $error');
        }
      }

      // Return the updated list of services
      return services;
    }
    setState(() {});
    return null;
  }

  Future<List<PLaces2>?> getServicesByCategoryId(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$domain2/api/getServicesByCategoryId/$categoryId'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['services'] != null) {
          List<dynamic> servicesData = data['services'];
          List<PLaces2> latestPlaces = servicesData.map((service) {
            return PLaces2(
              promo: service['discount_price'] ?? '0',
              name: service['name'],
              id: service['id'],
              mainImage: "",
              sideImages: [],
              location: service['duration'],
              stars: 0,
              Price: service['price'],
              type: service['genre'],
            );
          }).toList();

          return latestPlaces;
        } else {
          logger.d('Error 2 : Invalid response structure');
        }
      } else {
        logger.d('Error mmm : ${response.statusCode} $categoryId');
        logger.d('Error mmm : ${response.body} ');
      }
    } catch (error) {
      logger.d('Error: $error');
      // Throw an exception or handle the error appropriately
    }
    setState(() {});
    return null;
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$domain2/api/getCategories'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['categories'] != null) {
          List<dynamic> categoryList = data['categories'];

          for (var category in categoryList) {
            String iconUrl = category['media'].isNotEmpty ? ("$domain2/storage/" + category['media'][0]['original_url']) : 'Default Icon URL';

            Map<String, dynamic> categoryOption = {
              'id': category['id'],
              'label': category['name'],
              'icon': iconUrl,
              'services': [],
            };

            updatedOptions.add(categoryOption);
          }

          // Update the 'options' field with categories
          setState(() {
            options = updatedOptions;
          });

          // Fetch services for each category
          await fetchServicesForCategories();
        } else {
          print('Error 1 : Invalid response structure');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
    setState(() {});
  }

  Future<void> fetchServicesForCategories() async {
    List<Map<String, dynamic>> updatedOptionsCopy = List.from(updatedOptions);

    for (var categoryOption in updatedOptionsCopy) {
      try {
        // Fetch services for the current category
        List<PLaces2>? services = await finilize(categoryOption['id']);

        List<Map<String, dynamic>> servicesJson = services?.map((service) {
              return {
                'name': service.name,
                'id': service.id,
                'mainImage': service.mainImage,
                'sideImages': service.sideImages,
                'location': service.location,
                'stars': service.stars,
                'type': service.type,
                'price': service.Price,
                'discount_price': service.promo
              };
            }).toList() ??
            [];

        // Find the category in updatedOptions and update its 'services' field
        int index = updatedOptions.indexWhere((element) => element['id'] == categoryOption['id']);
        if (index != -1) {
          updatedOptions[index]['services'] = servicesJson;
          setState(() {
            options = updatedOptions;
          });
        }
      } catch (error) {
        logger.e('Error fetching services for category: $error');
      }
    }
    setState(() {});
  }

  // void printFormattedJson(String jsonString) {
  //   final parsedJson = jsonDecode(jsonString);
  //   final formattedJsonString = const JsonEncoder.withIndent('  ').convert(parsedJson);
  //   // logger.d(formattedJsonString);
  // }

  Future<void> fetchInitialData() async {
    // Load both page 1 and page 2 on initialization
    await fetchData(1); // Fetch page 1
    await fetchData(2); // Fetch page 2
    await fetchData(3); // Fetch page 2
  }

  Future<void> fetchData(int page) async {
    if (isLoading) return; // Prevent multiple requests

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://app.spabooking.pro/api/getServices?page=$page'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseMap = json.decode(response.body);
        List<dynamic> services = responseMap['services']['data'];

        List<Map<String, dynamic>> servicesJson = List<Map<String, dynamic>>.from(
          services.map((service) {
            List<String> sideImages = [];
            if (service['media'] != null) {
              sideImages = List<String>.from(service['media'].map((image) {
                return image['original_url'];
              }));
            }
            List<Map<String, dynamic>> categories = List<Map<String, dynamic>>.from(
              service['service_categories'].map((category) {
                String categoryId = category['category']['id'].toString();
                String categoryName = category['category']['name'];
                String iconUrl = '';
                if (category['category']['media'] != null && category['category']['media'].isNotEmpty) {
                  iconUrl = category['category']['media'][0]['original_url'];
                }
                return {
                  'categoryId': categoryId,
                  'categoryName': categoryName,
                  'icon': iconUrl,
                };
              }),
            );

            return {
              'name': service['name'],
              'id': service['id'],
              'mainImage': sideImages.isNotEmpty ? sideImages[0] : '',
              'sideImages': sideImages,
              'location': service['duration'],
              'stars': service['accepted'],
              'type': service['genre'],
              'price': service['price'],
              'categories': categories,
              'discount_price': service['discount_price'],
            };
          }),
        );

        Map<String, Map<String, dynamic>> categoryMap = {};

        // Add services under the appropriate category, ensuring each category name is shown once
        for (var service in servicesJson) {
          for (var category in service['categories']) {
            String categoryName = category['categoryName'];
            if (!categoryMap.containsKey(categoryName)) {
              categoryMap[categoryName] = {
                'id': category['categoryId'],
                'label': categoryName,
                'icon': category['icon'],
                'services': [],
              };
            }
            // Add the service only if it's not already added to the category
            if (!categoryMap[categoryName]!['services'].contains(service)) {
              categoryMap[categoryName]!['services'].add(service);
            }
          }
        }

        List<Map<String, dynamic>> newOptions = [];
        categoryMap.forEach((categoryName, categoryOption) {
          newOptions.add({
            'id': categoryOption['id'],
            'label': categoryOption['label'],
            'icon': categoryOption['icon'],
            // Limit the services to only 3
            'services': categoryOption['services'].take(3).toList(),
          });
        });

        setState(() {
          options.addAll(newOptions); // Append new data to the existing list
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //  fetchData() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$domain2/api/getServices?page=2'), //  {/*?page=1 */}
  //     );

  //     // logger.d(response.body);

  //     // printFormattedJson(response.body);

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Map<String, dynamic> responseMap = json.decode(response.body);
  //       List<dynamic> services = responseMap['services']['data']
  //       ;

  //       logger.i(response.body);

  //       List<Map<String, dynamic>> servicesJson = List<Map<String, dynamic>>.from(services.map((service) {
  //         List<String> sideImages = [];
  //         if (service['media'] != null) {
  //           sideImages = List<String>.from(service['media'].map((image) {
  //             return image['original_url'];
  //           }));
  //         }
  //         List<Map<String, dynamic>> categories = List<Map<String, dynamic>>.from(service['service_categories'].map((category) {
  //           String categoryId = category['category']['id'].toString();
  //           String categoryName = category['category']['name'];

  //           // Check if 'media' is not empty before accessing the URL
  //           String iconUrl = '';
  //           if (category['category']['media'] != null && category['category']['media'].isNotEmpty) {
  //             iconUrl = category['category']['media'][0]['original_url'];
  //           }

  //           return {
  //             'categoryId': categoryId,
  //             'categoryName': categoryName,
  //             'icon': iconUrl,
  //           };
  //         }));

  //         return {
  //           'name': service['name'],
  //           'id': service['id'],
  //           'mainImage': sideImages.isNotEmpty ? sideImages[0] : '',
  //           'sideImages': sideImages,
  //           'location': service['duration'],
  //           'stars': service['accepted'],
  //           'type': service['genre'],
  //           'price': service['price'],
  //           'categories': categories,
  //           'discount_price': service['discount_price']
  //         };
  //       }));

  //       Map<String, Map<String, dynamic>> categoryMap = {};

  //       servicesJson.forEach((service) {
  //         service['categories'].forEach((category) {
  //           String categoryId = category['categoryId'].toString(); // Convert to string
  //           if (!categoryMap.containsKey(categoryId)) {
  //             categoryMap[categoryId] = {
  //               'id': categoryId,
  //               'label': category['categoryName'],
  //               'icon': category['icon'], // Replace with the actual icon URL
  //               'services': [],
  //             };
  //           }
  //           categoryMap[categoryId]!['services'].add(service);
  //         });
  //       });

  //       // Create the final options list
  //       List<Map<String, dynamic>> optionsss = [];
  //       categoryMap.forEach((categoryId, categoryOption) {
  //         optionsss.add({
  //           'id': categoryId,
  //           'label': categoryOption['label'],
  //           'icon': categoryOption['icon'],
  //           'services': categoryOption['services'],
  //         });
  //       });

  //       // Print the result for verification
  //       /*  optionsss.forEach((option) {
  //         print('Category: ${option['label']}');
  //         option['services'].forEach((service) {
  //           print('- Service: ${service['name']}');
  //           // Add other service details as needed
  //         });
  //       });*/

  //       // Set the options state
  //       setState(() {
  //         options = optionsss;
  //       });
  //     } else {
  //       print('Failed to load data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  //   setState(() {});
  // }

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

    _fetchAndStoreSalons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(
                  color: Color(0xFFD91A5B), // Border color
                ),
              ),
              title: const Text(
                'Voulez-vous quitter l\'application ?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD91A5B)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Dismiss with 'Non'
                        },
                        // icon: const Icon(Icons.login), // 'Non' button icon
                        label: const Text('Non'),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Exit with 'Oui'
                        },
                        // icon: const Icon(Icons.person_add), // 'Oui' button icon
                        label: const Text('Oui'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        )) ??
        false; // Return false if the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // int crossAxisCount = calculateCrossAxisCount(context);

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await _showExitDialog(context);
        return exitConfirmed;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: Center(
            child: Image.asset(
              "Assets/1-removebg-preview.png",
              height: 30,
              color: const Color(0xFFD91A5B),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Color(0xFFD91A5B),
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.map,
                color: Color(0xFFD91A5B),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyMap()),
                );
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Color(0xFFD91A5B)),
        ),
        drawer: CustomDrawer(
            currentPage: selectedLanguage == "English"
                ? translate('Accueil', drawer_English)
                : selectedLanguage == "Arabic"
                    ? translate('Accueil', drawer_Arabic)
                    : 'Accueil'),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    //   color: Color(0xFFD91A5B),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        height: size.height * 0.25,
                        width: size.width * 0.98,
                        child: Swiper(
                          controller: _swiperController,
                          itemBuilder: (BuildContext context, int index) {
                            return SCrol(context)[index];
                          },
                          itemCount: images.length,
                          pagination: const SwiperPagination(
                            builder: DotSwiperPaginationBuilder(
                              color: Color.fromARGB(255, 228, 161, 183),
                              activeColor: Color(0xFFD91A5B),
                              activeSize: 10.0,
                              size: 8.0,
                            ),
                          ),
                          autoplay: true, // Auto-swipe enabled
                          duration: 500, // Auto-swipe duration in milliseconds
                          /*  control: SwiperControl(
                            iconNext: Icons.arrow_forward,
                            iconPrevious: Icons.arrow_back,
                            size: 30.0,
                            color: Colors.white,
                          ),*/
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: (size.width * 0.9) - 100,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: const Color(0xFFD91A5B), // Set border color
                                width: 1.0, // Set border width
                              ),
                            ),
                            child: TextField(
                              controller: _controllertext,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: selectedLanguage == "English"
                                    ? translate('Recherche...', home_English)
                                    : selectedLanguage == "Arabic"
                                        ? translate('Recherche...', home_Arabic)
                                        : 'Recherche...',
                                hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFFD91A5B)),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear, color: Color(0xFFD91A5B)),
                                  onPressed: () {
                                    setState(() {
                                      _controllertext.clear();
                                    });
                                  },
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              onChanged: (value) {
                                // Add your search logic here
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchQueries(
                                          Text: removeLastSpace(_controllertext.text),
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(
                            options.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  options[index]['label'],
                                  style: TextStyle(
                                    color: !selectedOptions.contains(options[index]['label']) ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: selectedOptions.contains(options[index]['label']),
                                onSelected: (bool selected) {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FilteredGridPage(
                                          Cat_Id: options[index]['id'].toString(),
                                          title: options[index]['label'],
                                        ),
                                      ),
                                    );
                                  });
                                },
                                avatar: CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: !selectedOptions.contains(options[index]['label']) ? Colors.transparent : Colors.transparent,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.7,
                                    heightFactor: 0.7,
                                    child: Image.network(
                                      options[index]['icon'],
                                      color: selectedOptions.contains(options[index]['label']) ? Colors.white : Colors.pink,
                                    ),
                                  ),
                                ),
                                elevation: !selectedOptions.contains(options[index]['label']) ? 4.0 : 0.0,
                                backgroundColor: selectedOptions.contains(options[index]['label']) ? const Color(0xFFD91A5B) : Colors.white,
                                selectedColor: const Color(0xFFD91A5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                    color: Color(0xFFD91A5B),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                /*    Container(
                  height: 5,
                  width: double.infinity,
                  color: Colors.grey,
                ),*/
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpandableListWidget(
                        isNew: true,
                        title: "Nouveaux",
                        places: placeses,
                      ),
                      ExpandableListWidget(
                        isNew: false,
                        title: "Recommander",
                        places: Recomanded,
                      ),
                      /*   */
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      children: [
                        Column(
                          children: options.map((option) {
                            List<PLaces2> services = (option['services'] as List<dynamic>).map((service) {
                              double price = (service['price'] is String)
                                  ? double.parse(service['price'])
                                  : (service['price'] is int)
                                      ? (service['price'] as int).toDouble()
                                      : service['price'] ?? 0.0;

                              return PLaces2(
                                promo: service['discount_price'] ?? '0',
                                name: service['name'].toString(),
                                id: service['id'],
                                mainImage: service['mainImage'],
                                sideImages: List<String>.from(service['sideImages']),
                                location: service['location'],
                                stars: double.parse(service['stars'].toString()),
                                type: service['type'],
                                Price: price.toString(),
                              );
                            }).toList();

                            return Column(
                              children: [
                                ServiceView(
                                  Cat_Id: option['id'].toString(),
                                  icon: option['icon'],
                                  isNew: false,
                                  title: option['label'],
                                  places: services,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  child: const Text(
                    'Explorer avec les villes',
                    style: TextStyle(
                      color: Color(0xFFD91A5B),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'YourCustomFont', // Replace with your custom font
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 120.0,
                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 5.0, 5.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: Allcities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 150,
                            child: CityCart(city: Allcities[index]),
                          ));
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProductCard(BuildContext context, Map<String, String> data) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              data['imagePath'] ?? '',
              height: 150,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data['description'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> SCrol(BuildContext context) {
    if (images.isEmpty) {
      return [
        Container(
          color: Colors.white,
        ),
      ];
    }

    return List.generate(images.length, (index) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          image: DecorationImage(
            image: CachedNetworkImageProvider(images[index]),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(
              width: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    titles[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String url = links[index];
                      print(url);
                      try {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } catch (e) {
                        throw 'Could not launch $url';
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        // primary: const Color(0xFFD91A5B),
                        // onPrimary: Colors.white,
                        ),
                    child: Text(buttons[index]),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
            ),
          ],
        ),
      );
    });
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth > 600) {
      crossAxisCount = 3; // Large screen, show 3 services in a line
    } else {
      crossAxisCount = 2; // Normal phone, show 2 services in a line
    }

    return crossAxisCount;
  }

/*
  Widget _buildList(String title, bool isNew) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleListVisibility,
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.pink,
                  ),
                ),
                Icon(
                  isListVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 30,
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            height: 275,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: placeses.length,
              itemBuilder: (context, index) {
                final place = placeses[index];
                return _buildPlaceCard(place, isNew);
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        Divider(
          color: Colors.pink.withOpacity(0.5),
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
        SizedBox(height: 10),
        Container(
          height: 275,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: placeses.length,
            itemBuilder: (context, index) {
              final place = placeses[index];
              return _buildPlaceCard(place, isNew);
            },
          ),
        ),
        SizedBox(height: 20),
        Divider(
          color:
              Colors.pink.withOpacity(0.5), // Add a pink divider with opacity
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }*/
}

class YourContentWidget extends StatelessWidget {
  final String content;

  const YourContentWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(fontSize: 18),
    );
  }
}

class Session {
  final Icon icon;
  final String date;
  final String object;
  final String city;

  Session({
    required this.icon,
    required this.date,
    required this.object,
    required this.city,
  });
}

class Doctor {
  final String name;
  final String Tel;
  final String imageUrl;

  Doctor({required this.name, required this.Tel, required this.imageUrl});
}

String removeLastSpace(String input) {
  if (input.isNotEmpty && input.endsWith(' ')) {
    return input.substring(0, input.length - 1);
  }
  return input;
}
