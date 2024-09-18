import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spa/screens/boocked.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ReservationPage extends StatefulWidget {
  final Reservation reservation;

  ReservationPage({required this.reservation});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late SharedPreferences _prefs;
  String selectedLanguage = '';
  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = _prefs.getString('selectedLanguage') ?? 'Frensh';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedLanguage == "English"
              ? "Reservation ${widget.reservation.reservationNumber}"
              : selectedLanguage == "Arabic"
                  ? "تفاصيل الحجز"
                  : "Réservation ${widget.reservation.reservationNumber}",
          style: TextStyle(color: Color(0xFFD91A5B)), // Set title text color
        ),
        iconTheme: IconThemeData(color: Color(0xFFD91A5B)), // Set icon color
        backgroundColor:
            Colors.transparent, // Set app bar background color to transparent
        elevation: 0, // Remove the shadow under the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            /* Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(0xFFD91A5B)), // Adjust color as needed
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        selectedLanguage == "English"
                            ? "Reservation Information"
                            : selectedLanguage == "Arabic"
                                ? "معلومات الحجز"
                                : "Informations de la réservation",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                    ),
                    _buildDetailRow(
                      Icons.confirmation_number,
                      selectedLanguage == "English"
                          ? "Reservation Number"
                          : selectedLanguage == "Arabic"
                              ? "رقم الحجز"
                              : "Numéro de réservation",
                      '${widget.reservation.reservationNumber}',
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.check,
                      selectedLanguage == "English"
                          ? "Status"
                          : selectedLanguage == "Arabic"
                              ? "الحالة"
                              : "Statut",
                      widget.reservation.bookingStatus,
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.payment,
                      selectedLanguage == "English"
                          ? "Payment Status"
                          : selectedLanguage == "Arabic"
                              ? "حالة الدفع"
                              : "Statut de paiement",
                      widget.reservation.payment_status,
                      containerWidth,
                    ),
                  ],
                )),*/

            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(0xFFD91A5B)), // Adjust color as needed
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        selectedLanguage == "English"
                            ? "Customer Details"
                            : selectedLanguage == "Arabic"
                                ? "تفاصيل العميل"
                                : "Détails du salon",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                    ),
                    _buildDetailRow2(
                      Icons.store, // Icon for salon
                      selectedLanguage == "English"
                          ? "Name"
                          : selectedLanguage == "Arabic"
                              ? "الاسم"
                              : "Nom",
                      widget.reservation.SalonName, // Salon name
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow2(
                      Icons.phone,
                      selectedLanguage == "English"
                          ? "Phone"
                          : selectedLanguage == "Arabic"
                              ? "الهاتف"
                              : "Téléphone",
                      widget.reservation.SalonTelephone,
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    /* _buildDetailRow2(
                      Icons.email,
                      selectedLanguage == "English"
                          ? "Email"
                          : selectedLanguage == "Arabic"
                              ? "البريد الإلكتروني"
                              : "Email",
                      widget.reservation.emailStaff,
                      containerWidth,
                    ),
                    SizedBox(height: 8),*/
                    _buildDetailRow4(
                      Icons.location_on,
                      selectedLanguage == "English"
                          ? "Address"
                          : selectedLanguage == "Arabic"
                              ? "العنوان"
                              : "Adresse",
                      widget.reservation.adress,
                      containerWidth,
                    ),
                  ],
                )),
            SizedBox(height: 24),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(0xFFD91A5B)), // Adjust color as needed
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        selectedLanguage == "English"
                            ? "Reservation Details"
                            : selectedLanguage == "Arabic"
                                ? "تفاصيل الحجز"
                                : "Détails de la réservation",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD91A5B),
                        ),
                      ),
                    ),
                    _buildDetailRow4(
                      Icons.description,
                      selectedLanguage == "English"
                          ? "Service name"
                          : selectedLanguage == "Arabic"
                              ? "الوصف"
                              : "Nom de service",
                      extractPlainText(widget.reservation.description),
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow3(
                      Icons.confirmation_number,
                      selectedLanguage == "English"
                          ? "Reservation Number"
                          : selectedLanguage == "Arabic"
                              ? "رقم الحجز"
                              : "Numéro de réservation",
                      '${widget.reservation.reservationNumber}',
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow3(
                      Icons.check,
                      selectedLanguage == "English"
                          ? "Status"
                          : selectedLanguage == "Arabic"
                              ? "الحالة"
                              : "Status",
                      widget.reservation.bookingStatus,
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    /* _buildDetailRow3(
                      Icons.payment,
                      selectedLanguage == "English"
                          ? "Payment Status"
                          : selectedLanguage == "Arabic"
                              ? "حالة الدفع"
                              : "Statut de paiement",
                      widget.reservation.payment_status,
                      containerWidth,
                    ),
                    SizedBox(height: 8),*/
                    _buildDetailRow3(
                      Icons.date_range,
                      selectedLanguage == "English"
                          ? "Date"
                          : selectedLanguage == "Arabic"
                              ? "التاريخ"
                              : "Date",
                      formatDateString(widget.reservation.date)
                          .toString()
                          .substring(0, 10),
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow3(
                      Icons.access_time,
                      selectedLanguage == "English"
                          ? "Start Time"
                          : selectedLanguage == "Arabic"
                              ? "وقت البدء"
                              : "Heure de début",
                      widget.reservation.start_at.toString().substring(11, 16),
                      containerWidth,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow5(
                      Icons.attach_money,
                      selectedLanguage == "English"
                          ? "Price"
                          : selectedLanguage == "Arabic"
                              ? "السعر"
                              : "Prix",
                      widget.reservation.price + " Dh",
                      containerWidth,
                    ),
                  ],
                )),
            /*  SizedBox(height: 24),
            //   _buildSection('Additional Information', null),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(0xFFD91A5B)), // Adjust color as needed
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      selectedLanguage == "English"
                          ? "Additional Information"
                          : selectedLanguage == "Arabic"
                              ? "معلومات إضافية"
                              : "Informations supplémentaires",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD91A5B),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ])),*/
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, double widt) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFD91A5B)),
        SizedBox(width: 10),
        Container(
            width: widt * 0.4,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        Container(
            width: widt * 0.4 - 16,
            child: Text(
              ": " + value,
              style: TextStyle(fontSize: 16),
            )),
      ],
    );
  }

  Widget _buildDetailRow2(
      IconData icon, String label, String value, double widt) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFD91A5B)),
        SizedBox(width: 10),
        Container(
            width: widt * 0.2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        Container(
            width: widt * 0.6 - 16,
            child: AutoSizeText(
              ": " + value,
              maxLines: 1,
              style: TextStyle(fontSize: 16),
            )),
      ],
    );
  }

  Widget _buildDetailRow3(
      IconData icon, String label, String value, double widt) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFD91A5B)),
        SizedBox(width: 10),
        Container(
          width: widt * 0.4,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            width: widt * 0.4 - 50,
            child: Text(
              ": " + value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow5(
      IconData icon, String label, String value, double widt) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFD91A5B)),
        SizedBox(width: 10),
        Container(
          width: widt * 0.4,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
              width: widt * 0.4 - 50,
              child: widget.reservation.promo.toString() != '0'
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.reservation.promo.toString()} Dh",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD91A5B),
                          ),
                        ),
                        Text(
                          "${widget.reservation.price.toString()} Dh",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "${widget.reservation.price.toString()} Dh",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD91A5B),
                      ),
                    )),
        ),
      ],
    );
  }

  Widget _buildDetailRow4(
      IconData icon, String label, String value, double widt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFFD91A5B)),
            SizedBox(width: 10),
            Text(
              label + " : ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Expanded(
                child: Container(
                    width: widt * 0.4 - 50,
                    child: Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16),
                    ))),
          ],
        ),
      ],
    );
  }

  String extractPlainText(String htmlContent) {
    var document = parse(htmlContent);
    return parse(document.body!.text).documentElement!.text;
  }

  String formatDateString(String dateString) {
    // Parse the input string into a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the DateTime object into a desired string format
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    return formattedDate;
  }
}
