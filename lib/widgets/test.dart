import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) {
  runApp(
    const MaterialApp(
      home: PaginationTest(),
    ),
  );
}

class PaginationTest extends StatefulWidget {
  const PaginationTest({super.key});

  @override
  State<PaginationTest> createState() => _PaginationTestState();
}

class _PaginationTestState extends State<PaginationTest> {
  List<Map<String, dynamic>> options = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchInitialData(); // Fetch both pages on initialization
  }

  Future<void> fetchInitialData() async {
    // Load both page 1 and page 2 on initialization
    await fetchData(1); // Fetch page 1
    await fetchData(2); // Fetch page 2
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ExpansionTile(
                  title: Text(option['label']),
                  leading: option['icon'] != null
                      ? Image.network(option['icon'], width: 50, height: 50)
                      : const Icon(Icons.image),
                  children: option['services'].map<Widget>((service) {
                    return ListTile(
                      title: Text(service['name']),
                      subtitle: Text('Price: ${service['price']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
