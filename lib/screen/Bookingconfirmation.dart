import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widget/booking_widgets/booking_details_card.dart';
import '../widget/booking_widgets/booking_form_fields.dart';
import '../widget/bottom_nav_bar.dart';
import 'Bookingform.dart';
import 'Bookingtimestableview.dart';

class BookingConfirmation extends StatelessWidget {
  final String name;
  final String location;
  final String time;
  final String date;
  final String service;
  final String provider;
  final String serviceId;

  const BookingConfirmation({
    Key? key,
    required this.name,
    required this.location,
    required this.time,
    required this.date,
    required this.service,
    required this.provider,
    required this.serviceId,
  }) : super(key: key);


  Future<String?> _saveBookingToFirebase() async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('bookingnow').add({
        'name': name,
        'location': location,
        'time': time,
        'date': date,
        'service': service,
        'provider': provider,
        'serviceId': serviceId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      print('Error saving booking to Firebase: $e');
      return null;
    }
  }

  Future<void> _deleteCancelledBooking(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookingnow')
          .where('name', isEqualTo: name)
          .where('location', isEqualTo: location)
          .where('time', isEqualTo: time)
          .where('date', isEqualTo: date)
          .where('service', isEqualTo: service)
          .where('provider', isEqualTo: provider)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        print('Booking deleted successfully');
      }
    } catch (e) {
      print('Error deleting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel booking')),
      );
    }
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel your booking?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteCancelledBooking(context);
                
                Navigator.of(context).pop(); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingForm()),
                  (route) => false,
                );
              },
              child: const Text(
                'Confirm Cancellation',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _saveBookingToFirebase();

    final Map<String, String> bookingData = {
      'name': name,
      'service': service,
      'provider': provider,
      'location': location,
      'date': date,
      'time': time,
      'serviceId': serviceId,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Booking is DONE!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank you for trusting us',
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              BookingDetailsCard(
                bookingData: bookingData,
                title: 'Booking Information',
              ),
              const SizedBox(height: 30),
              ActionButton(
                text: 'Go to Booking Details',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingTimesTableView(
                        bookingData: bookingData,
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.teal,
                textColor: Colors.white,
              ),
              const SizedBox(height: 16),
              ActionButton(
                text: 'Cancel Booking',
                onPressed: () => _showCancelConfirmationDialog(context),
                isOutlined: true,
                textColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}