import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/constents.dart';
import 'package:spa/page_transltion/home_tr.dart';
import 'package:http/http.dart' as http;
import 'package:spa/constents.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomRatingDialog extends StatefulWidget {
  final String id;
  final String name;
  Function setst;
  CustomRatingDialog(
      {required this.id, required this.name, required this.setst});

  @override
  _CustomRatingDialogState createState() => _CustomRatingDialogState();
}

class _CustomRatingDialogState extends State<CustomRatingDialog> {
  double serviceClientRating = 0.0;
  double ambianceRating = 0.0;
  double propreteRating = 0.0;
  double noteGlobaleRating = 0.0;
  double newRating = 0.0;
  TextEditingController commentaireController = TextEditingController();
  late SharedPreferences _prefsss;
  String selectedLanguage = '';
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

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
    return AlertDialog(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Color(0xFFD91A5B)), // Add border color here
      ),
      title: Text(
        widget.name,
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFFD91A5B)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRatingRow(
              translate("Service Client", home_Arabic, home_English),
              serviceClientRating, (rating) {
            setState(() {
              serviceClientRating = rating;
            });
          }),
          _buildRatingRow(
              translate("Ambiance", home_Arabic, home_English), ambianceRating,
              (rating) {
            setState(() {
              ambianceRating = rating;
            });
          }),
          _buildRatingRow(
              translate("Propreté", home_Arabic, home_English), propreteRating,
              (rating) {
            setState(() {
              propreteRating = rating;
            });
          }),
          _buildRatingRow(translate("Note Globale", home_Arabic, home_English),
              noteGlobaleRating, (rating) {
            setState(() {
              noteGlobaleRating = rating;
            });
          }),
          SizedBox(height: 10),
          TextField(
            maxLines: 4,
            minLines: 1,
            controller: commentaireController,
            decoration: InputDecoration(
              labelText:
                  translate("Votre commentaire...", home_Arabic, home_English),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(translate("Annuler", home_Arabic, home_English)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (commentaireController.text == '') {
              Fluttertoast.showToast(
                msg: "Écrivez un commentaire s'il vous plaît",
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
                // Use a checkmark icon for success
                webShowClose: true,
                webBgColor: "#4CAF50",
                webPosition: "center",
                timeInSecForIosWeb: 2,
              );
            } else {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? localId = prefs.getString('id').toString();
              double serviceClientRatingValue = serviceClientRating;
              double ambianceRatingValue = ambianceRating;
              double propreteRatingValue = propreteRating;
              double noteGlobaleRatingValue = noteGlobaleRating;

// Calculate the average
              int averageRating = ((serviceClientRatingValue +
                          ambianceRatingValue +
                          propreteRatingValue +
                          noteGlobaleRatingValue) /
                      4)
                  .round()
                  .clamp(0, 5)
                  .toInt();
              Map<String, dynamic> requestData = {
                "review": commentaireController.text,
                "rate": averageRating.toString(),
                "salon_id": widget.id, // Replace with the actual salon_id
                "user_id": localId, // Replace with the actual user_id
              };

              // Replace "{{url}}" with the actual URL
              String apiUrl = "$domain2/api/storeReview";
              Navigator.pop(context);

              try {
                // Make the API call
                http.Response response = await http.post(
                  Uri.parse(apiUrl),
                  body: requestData,
                );

                print(response.statusCode);
                if (response.statusCode == 200 ||
                    response.statusCode == 201 ||
                    response.statusCode == 201) {
                  print("API Call Successful");
                  Fluttertoast.showToast(
                    msg: 'Votre avis a été enregistré avec succès',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    toastLength: Toast.LENGTH_LONG,
                    // Use a checkmark icon for success
                    webShowClose: true,
                    webBgColor: "#4CAF50",
                    webPosition: "center",
                    timeInSecForIosWeb: 2,
                  );
                } else {
                  print(
                      "API Call Failed with status code: ${response.statusCode}");
                  Fluttertoast.showToast(
                    msg: 'Erreur: ${response.body}',
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
                }
              } catch (error) {
                print("Error during API call: $error");
                Fluttertoast.showToast(
                  msg: 'Erreur: $error',
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
              }
              widget.setst();
              print("Service Client Rating: $serviceClientRating");
              print("Ambiance Rating: $ambianceRating");
              print("Propreté Rating: $propreteRating");
              print("Note Globale Rating: $noteGlobaleRating");
              print("Commentaire: ${commentaireController.text}");
            }
          },
          style: ElevatedButton.styleFrom(
            // primary: Color(0xFFD91A5B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(translate("Envoyer", home_Arabic, home_English)),
        ),
      ],
    );
  }

  Widget _buildRatingRow(
      String title, double rating, Function(double) onRatingChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          StarRating2(
            rating: rating,
            onRatingChanged: onRatingChanged,
          ),
        ],
      ),
    );
  }
}

class StarRating2 extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const StarRating2({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 20.0,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: onRatingChanged,
    );
  }
}
