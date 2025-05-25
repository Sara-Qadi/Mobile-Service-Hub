// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:flutter/material.dart';
// // // // import '../widget/booking_widgets/booking_details_card.dart';
// // // // import '../widget/booking_widgets/booking_form_fields.dart';
// // // // import '../widget/bottom_nav_bar.dart';
// // // // import 'Bookingform.dart';
// // // // import 'Bookingtimestableview.dart';

// // // // class BookingConfirmation extends StatelessWidget {
// // // //   final String name;
// // // //   final String location;
// // // //   final String time;
// // // //   final String date;
// // // //   final String service;
// // // //   final String provider;
// // // //   final String serviceId;

// // // //   const BookingConfirmation({
// // // //     Key? key,
// // // //     required this.name,
// // // //     required this.location,
// // // //     required this.time,
// // // //     required this.date,
// // // //     required this.service,
// // // //     required this.provider,
// // // //     required this.serviceId,
// // // //   }) : super(key: key);


// // // //   Future<String?> _saveBookingToFirebase() async {
// // // //     try {
// // // //       final docRef = await FirebaseFirestore.instance.collection('bookingnow').add({
// // // //         'name': name,
// // // //         'location': location,
// // // //         'time': time,
// // // //         'date': date,
// // // //         'service': service,
// // // //         'provider': provider,
// // // //         'serviceId': serviceId,
// // // //         'timestamp': FieldValue.serverTimestamp(),
// // // //       });
      
// // // //       return docRef.id;
// // // //     } catch (e) {
// // // //       print('Error saving booking to Firebase: $e');
// // // //       return null;
// // // //     }
// // // //   }

// // // //   Future<void> _deleteCancelledBooking(BuildContext context) async {
// // // //     try {
// // // //       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
// // // //           .collection('bookingnow')
// // // //           .where('name', isEqualTo: name)
// // // //           .where('location', isEqualTo: location)
// // // //           .where('time', isEqualTo: time)
// // // //           .where('date', isEqualTo: date)
// // // //           .where('service', isEqualTo: service)
// // // //           .where('provider', isEqualTo: provider)
// // // //           .limit(1)
// // // //           .get();

// // // //       if (querySnapshot.docs.isNotEmpty) {
// // // //         await querySnapshot.docs.first.reference.delete();
// // // //         print('Booking deleted successfully');
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error deleting booking: $e');
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Failed to cancel booking')),
// // // //       );
// // // //     }
// // // //   }

// // // //   void _showCancelConfirmationDialog(BuildContext context) {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (BuildContext context) {
// // // //         return AlertDialog(
// // // //           title: const Text('Confirm Cancellation'),
// // // //           content: const Text('Are you sure you want to cancel your booking?'),
// // // //           actions: <Widget>[
// // // //             TextButton(
// // // //               onPressed: () {
// // // //                 Navigator.of(context).pop(); 
// // // //               },
// // // //               child: const Text(
// // // //                 'Go Back',
// // // //                 style: TextStyle(color: Colors.grey),
// // // //               ),
// // // //             ),
// // // //             TextButton(
// // // //               onPressed: () {
// // // //                 _deleteCancelledBooking(context);
                
// // // //                 Navigator.of(context).pop(); 
// // // //                 // Navigator.pushAndRemoveUntil(
// // // //                 //   context,
// // // //                 //   MaterialPageRoute(builder: (context) => const BookingForm()),
// // // //                 //   (route) => false,
// // // //                 // );
// // // //               },
// // // //               child: const Text(
// // // //                 'Confirm Cancellation',
// // // //                 style: TextStyle(color: Colors.red),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     _saveBookingToFirebase();

// // // //     final Map<String, String> bookingData = {
// // // //       'name': name,
// // // //       'service': service,
// // // //       'provider': provider,
// // // //       'location': location,
// // // //       'date': date,
// // // //       'time': time,
// // // //       'serviceId': serviceId,
// // // //     };

// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text(
// // // //           'Booking',
// // // //           style: TextStyle(
// // // //             fontSize: 22,
// // // //             fontWeight: FontWeight.bold,
// // // //           ),
// // // //         ),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(20.0),
// // // //           child: Column(
// // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // //             children: [
// // // //               const Text(
// // // //                 'Your Booking is DONE!',
// // // //                 style: TextStyle(
// // // //                   fontSize: 24,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //                 textAlign: TextAlign.center,
// // // //               ),
// // // //               const SizedBox(height: 16),
// // // //               const Text(
// // // //                 'Thank you for trusting us',
// // // //                 style: TextStyle(
// // // //                   fontSize: 18,
// // // //                 ),
// // // //                 textAlign: TextAlign.center,
// // // //               ),
// // // //               const SizedBox(height: 30),
// // // //               BookingDetailsCard(
// // // //                 bookingData: bookingData,
// // // //                 title: 'Booking Information',
// // // //               ),
// // // //               const SizedBox(height: 30),
// // // //               ActionButton(
// // // //                 text: 'Go to Booking Details',
// // // //                 onPressed: () {
// // // //                   Navigator.push(
// // // //                     context,
// // // //                     MaterialPageRoute(
// // // //                       builder: (context) => BookingTimesTableView(
// // // //                         bookingData: bookingData,
// // // //                       ),
// // // //                     ),
// // // //                   );
// // // //                 },
// // // //                 backgroundColor: Colors.teal,
// // // //                 textColor: Colors.white,
// // // //               ),
// // // //               const SizedBox(height: 16),
// // // //               ActionButton(
// // // //                 text: 'Cancel Booking',
// // // //                 onPressed: () => _showCancelConfirmationDialog(context),
// // // //                 isOutlined: true,
// // // //                 textColor: Colors.grey,
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //       bottomNavigationBar: const BottomNavBar(currentIndex: 1),
// // // //     );
// // // //   }
// // // // }


// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import '../widget/booking_widgets/booking_details_card.dart';
// // // import '../widget/booking_widgets/booking_form_fields.dart';
// // // import '../widget/bottom_nav_bar.dart';
// // // import 'Bookingform.dart';
// // // import 'Bookingtimestableview.dart';

// // // class BookingConfirmation extends StatefulWidget {
// // //   final String name;
// // //   final String location;
// // //   final String time;
// // //   final String date;
// // //   final String service;
// // //   final String provider;
// // //   final String serviceId;

// // //   const BookingConfirmation({
// // //     Key? key,
// // //     required this.name,
// // //     required this.location,
// // //     required this.time,
// // //     required this.date,
// // //     required this.service,
// // //     required this.provider,
// // //     required this.serviceId,
// // //   }) : super(key: key);

// // //   @override
// // //   State<BookingConfirmation> createState() => _BookingConfirmationState();
// // // }

// // // class _BookingConfirmationState extends State<BookingConfirmation> {
// // //   String? _bookingId;
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _saveBookingToFirebase();
// // //   }

// // //   Future<void> _saveBookingToFirebase() async {
// // //     try {
// // //       final docRef = await FirebaseFirestore.instance.collection('bookingnow').add({
// // //         'name': widget.name,
// // //         'location': widget.location,
// // //         'time': widget.time,
// // //         'date': widget.date,
// // //         'service': widget.service,
// // //         'provider': widget.provider, // هذا سيكون provider ID
// // //         'serviceId': widget.serviceId,
// // //         'timestamp': FieldValue.serverTimestamp(),
// // //       });
      
// // //       setState(() {
// // //         _bookingId = docRef.id;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       print('Error saving booking to Firebase: $e');
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }

// // //   Future<void> _deleteCancelledBooking(BuildContext context) async {
// // //     if (_bookingId == null) return;
    
// // //     try {
// // //       await FirebaseFirestore.instance
// // //           .collection('bookingnow')
// // //           .doc(_bookingId)
// // //           .delete();
      
// // //       print('Booking deleted successfully');
// // //     } catch (e) {
// // //       print('Error deleting booking: $e');
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Failed to cancel booking')),
// // //       );
// // //     }
// // //   }

// // //   void _showCancelConfirmationDialog(BuildContext context) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (BuildContext context) {
// // //         return AlertDialog(
// // //           title: const Text('Confirm Cancellation'),
// // //           content: const Text('Are you sure you want to cancel your booking?'),
// // //           actions: <Widget>[
// // //             TextButton(
// // //               onPressed: () {
// // //                 Navigator.of(context).pop(); 
// // //               },
// // //               child: const Text(
// // //                 'Go Back',
// // //                 style: TextStyle(color: Colors.grey),
// // //               ),
// // //             ),
// // //             TextButton(
// // //               onPressed: () {
// // //                 _deleteCancelledBooking(context);
// // //                 Navigator.of(context).pop(); 
// // //               },
// // //               child: const Text(
// // //                 'Confirm Cancellation',
// // //                 style: TextStyle(color: Colors.red),
// // //               ),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (_isLoading) {
// // //       return Scaffold(
// // //         appBar: AppBar(
// // //           title: const Text(
// // //             'Booking',
// // //             style: TextStyle(
// // //               fontSize: 22,
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           ),
// // //         ),
// // //         body: const Center(
// // //           child: CircularProgressIndicator(),
// // //         ),
// // //       );
// // //     }

// // //     final Map<String, String> bookingData = {
// // //       'name': widget.name,
// // //       'service': widget.service,
// // //       'provider': widget.provider, // هذا سيكون provider ID
// // //       'location': widget.location,
// // //       'date': widget.date,
// // //       'time': widget.time,
// // //       'serviceId': widget.serviceId,
// // //       'id': _bookingId ?? '', // إضافة الـ ID
// // //     };

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text(
// // //           'Booking',
// // //           style: TextStyle(
// // //             fontSize: 22,
// // //             fontWeight: FontWeight.bold,
// // //           ),
// // //         ),
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(20.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               const Text(
// // //                 'Your Booking is DONE!',
// // //                 style: TextStyle(
// // //                   fontSize: 24,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               const Text(
// // //                 'Thank you for trusting us',
// // //                 style: TextStyle(
// // //                   fontSize: 18,
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //               const SizedBox(height: 30),
// // //               BookingDetailsCard(
// // //                 bookingData: bookingData,
// // //                 title: 'Booking Information',
// // //               ),
// // //               const SizedBox(height: 30),
// // //               ActionButton(
// // //                 text: 'Go to Booking Details',
// // //                 onPressed: () {
// // //                   Navigator.push(
// // //                     context,
// // //                     MaterialPageRoute(
// // //                       builder: (context) => BookingTimesTableView(
// // //                         bookingData: bookingData,
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //                 backgroundColor: Colors.teal,
// // //                 textColor: Colors.white,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               ActionButton(
// // //                 text: 'Cancel Booking',
// // //                 onPressed: () => _showCancelConfirmationDialog(context),
// // //                 isOutlined: true,
// // //                 textColor: Colors.grey,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //       bottomNavigationBar: const BottomNavBar(currentIndex: 1),
// // //     );
// // //   }
// // // }


// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import '../widget/booking_widgets/booking_details_card.dart';
// // import '../widget/booking_widgets/booking_form_fields.dart';
// // import '../widget/bottom_nav_bar.dart';
// // import 'Bookingform.dart';
// // import 'Bookingtimestableview.dart';

// // class BookingConfirmation extends StatefulWidget {
// //   final String name;
// //   final String location;
// //   final String time;
// //   final String date;
// //   final String service;
// //   final String provider; // This is provider ID
// //   final String serviceId;

// //   const BookingConfirmation({
// //     Key? key,
// //     required this.name,
// //     required this.location,
// //     required this.time,
// //     required this.date,
// //     required this.service,
// //     required this.provider,
// //     required this.serviceId,
// //   }) : super(key: key);

// //   @override
// //   State<BookingConfirmation> createState() => _BookingConfirmationState();
// // }

// // class _BookingConfirmationState extends State<BookingConfirmation> {
// //   String? _bookingId;
// //   bool _isLoading = true;
// //   String _providerName = ''; // Store resolved provider name

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeBooking();
// //   }

// //   Future<void> _initializeBooking() async {
// //     // Resolve provider name first
// //     await _resolveProviderName();
// //     // Then save booking
// //     await _saveBookingToFirebase();
// //   }

// //   Future<void> _resolveProviderName() async {
// //     try {
// //       if (widget.provider.isNotEmpty) {
// //         final userDoc = await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(widget.provider)
// //             .get()
// //             .timeout(const Duration(seconds: 10));

// //         if (userDoc.exists) {
// //           final data = userDoc.data();
// //           _providerName = _extractFullName(data);
// //         } else {
// //           _providerName = widget.provider; // Fallback to ID
// //         }
// //       } else {
// //         _providerName = 'Unknown Provider';
// //       }
// //     } catch (e) {
// //       print('Error resolving provider name: $e');
// //       _providerName = widget.provider; // Fallback to ID
// //     }
// //   }

// //   String _extractFullName(Map<String, dynamic>? data) {
// //     if (data == null) return '';
    
// //     String firstName = data['firstName']?.toString() ?? '';
// //     String lastName = data['lastName']?.toString() ?? '';
    
// //     if (firstName.isNotEmpty && lastName.isNotEmpty) {
// //       return '$firstName $lastName';
// //     } else if (firstName.isNotEmpty) {
// //       return firstName;
// //     } else if (lastName.isNotEmpty) {
// //       return lastName;
// //     } else {
// //       return data['name']?.toString() ?? '';
// //     }
// //   }

// //   Future<void> _saveBookingToFirebase() async {
// //     try {
// //       final docRef = await FirebaseFirestore.instance.collection('bookingnow').add({
// //         'name': widget.name,
// //         'location': widget.location,
// //         'time': widget.time,
// //         'date': widget.date,
// //         'service': widget.service,
// //         'provider': widget.provider, // Keep as provider ID in database
// //         'serviceId': widget.serviceId,
// //         'timestamp': FieldValue.serverTimestamp(),
// //       });
      
// //       setState(() {
// //         _bookingId = docRef.id;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       print('Error saving booking to Firebase: $e');
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _deleteCancelledBooking(BuildContext context) async {
// //     if (_bookingId == null) return;
    
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection('bookingnow')
// //           .doc(_bookingId)
// //           .delete();
      
// //       print('Booking deleted successfully');
      
      
// //       Navigator.of(context).pushAndRemoveUntil(
// //         MaterialPageRoute(builder: (context) => BookingForm(service: {},)), // Replace with your home page
// //         (Route<dynamic> route) => false,
// //       );
// //     } catch (e) {
// //       print('Error deleting booking: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Failed to cancel booking')),
// //       );
// //     }
// //   }

// //   void _showCancelConfirmationDialog(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: const Text('Confirm Cancellation'),
// //           content: const Text('Are you sure you want to cancel your booking?'),
// //           actions: <Widget>[
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.of(context).pop(); 
// //               },
// //               child: const Text(
// //                 'Go Back',
// //                 style: TextStyle(color: Colors.grey),
// //               ),
// //             ),
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.of(context).pop(); 
// //                 _deleteCancelledBooking(context);
// //               },
// //               child: const Text(
// //                 'Confirm Cancellation',
// //                 style: TextStyle(color: Colors.red),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading) {
// //       return Scaffold(
// //         appBar: AppBar(
// //           title: const Text(
// //             'Booking',
// //             style: TextStyle(
// //               fontSize: 22,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //         body: const Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }

// //     final Map<String, String> bookingData = {
// //       'name': widget.name,
// //       'service': widget.service,
// //       'provider': _providerName, // Use resolved provider name for display
// //       'location': widget.location,
// //       'date': widget.date,
// //       'time': widget.time,
// //       'serviceId': widget.serviceId,
// //       'id': _bookingId ?? '',
// //       'providerId': widget.provider, // Keep provider ID for reference
// //     };

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           'Booking',
// //           style: TextStyle(
// //             fontSize: 22,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Text(
// //                 'Your Booking is DONE!',
// //                 style: TextStyle(
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 16),
// //               const Text(
// //                 'Thank you for trusting us',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 30),
// //               BookingDetailsCard(
// //                 bookingData: bookingData,
// //                 title: 'Booking Information',
// //               ),
// //               const SizedBox(height: 30),
// //               ActionButton(
// //                 text: 'Go to Booking Details',
// //                 onPressed: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (context) => BookingTimesTableView(
// //                         bookingData: bookingData,
// //                       ),
// //                     ),
// //                   );
// //                 },
// //                 backgroundColor: Colors.teal,
// //                 textColor: Colors.white,
// //               ),
// //               const SizedBox(height: 16),
// //               ActionButton(
// //                 text: 'Cancel Booking',
// //                 onPressed: () => _showCancelConfirmationDialog(context),
// //                 isOutlined: true,
// //                 textColor: Colors.grey,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       bottomNavigationBar: const BottomNavBar(currentIndex: 1),
// //     );
// //   }
// // }




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../widget/booking_widgets/booking_details_card.dart';
// import '../widget/booking_widgets/booking_form_fields.dart';
// import '../widget/bottom_nav_bar.dart';
// import 'Bookingform.dart';
// import 'Bookingtimestableview.dart';

// class BookingConfirmation extends StatefulWidget {
//   final String name;
//   final String location;
//   final String time;
//   final String date;
//   final String service;
//   final String provider; // This is provider ID
//   final String serviceId;

//   const BookingConfirmation({
//     Key? key,
//     required this.name,
//     required this.location,
//     required this.time,
//     required this.date,
//     required this.service,
//     required this.provider,
//     required this.serviceId,
//   }) : super(key: key);

//   @override
//   State<BookingConfirmation> createState() => _BookingConfirmationState();
// }

// class _BookingConfirmationState extends State<BookingConfirmation> {
//   String? _bookingId;
//   bool _isLoading = true;
//   String _providerName = ''; // Store resolved provider name
  
//   // Cache system like in BookingTimesTableView
//   static Map<String, String> _providerNames = {}; 
//   bool _hasError = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeBooking();
//   }

//   Future<void> _initializeBooking() async {
//     try {
//       // Resolve provider name first using the same method as BookingTimesTableView
//       await _resolveProviderName();
//       // Then save booking
//       await _saveBookingToFirebase();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//         _errorMessage = 'Failed to initialize booking: $e';
//       });
//     }
//   }

//   Future<void> _resolveProviderName() async {
//     try {
//       if (widget.provider.isNotEmpty) {
//         _providerName = await _getProviderName(widget.provider);
//       } else {
//         _providerName = 'Unknown Provider';
//       }
//     } catch (e) {
//       print('Error resolving provider name: $e');
//       _providerName = widget.provider; // Fallback to ID
//     }
//   }

//   // Same method as in BookingTimesTableView
//   Future<String> _getProviderName(String providerId) async {
//     // Check cache first
//     if (_providerNames.containsKey(providerId)) {
//       return _providerNames[providerId]!;
//     }

//     try {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(providerId)
//           .get()
//           .timeout(const Duration(seconds: 10));

//       if (userDoc.exists) {
//         final data = userDoc.data();
//         String fullName = _extractFullName(data);
//         _providerNames[providerId] = fullName;
//         return fullName;
//       }

//       // If not found, save ID as is
//       _providerNames[providerId] = providerId;
//       return providerId;
//     } catch (e) {
//       print('Error fetching provider name for ID $providerId: $e');
//       _providerNames[providerId] = providerId;
//       return providerId;
//     }
//   }

//   // Same method as in BookingTimesTableView
//   String _extractFullName(Map<String, dynamic>? data) {
//     if (data == null) return '';
    
//     String firstName = data['firstName']?.toString() ?? '';
//     String lastName = data['lastName']?.toString() ?? '';
    
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '$firstName $lastName';
//     } else if (firstName.isNotEmpty) {
//       return firstName;
//     } else if (lastName.isNotEmpty) {
//       return lastName;
//     } else {
//       return data['name']?.toString() ?? '';
//     }
//   }

//   Future<void> _saveBookingToFirebase() async {
//     try {
//       final docRef = await FirebaseFirestore.instance.collection('bookingnow').add({
//         'name': widget.name,
//         'location': widget.location,
//         'time': widget.time,
//         'date': widget.date,
//         'service': widget.service,
//         'provider': widget.provider, // Keep as provider ID in database
//         'serviceId': widget.serviceId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
      
//       setState(() {
//         _bookingId = docRef.id;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error saving booking to Firebase: $e');
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//         _errorMessage = 'Failed to save booking: $e';
//       });
//     }
//   }

//   Future<void> _deleteCancelledBooking(BuildContext context) async {
//     if (_bookingId == null) return;
    
//     try {
//       await FirebaseFirestore.instance
//           .collection('bookingnow')
//           .doc(_bookingId)
//           .delete();
      
//       print('Booking deleted successfully');
      
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => BookingForm(service: {},)), // Replace with your home page
//         (Route<dynamic> route) => false,
//       );
//     } catch (e) {
//       print('Error deleting booking: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to cancel booking')),
//       );
//     }
//   }

//   void _showCancelConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Cancellation'),
//           content: const Text('Are you sure you want to cancel your booking?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); 
//               },
//               child: const Text(
//                 'Go Back',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); 
//                 _deleteCancelledBooking(context);
//               },
//               child: const Text(
//                 'Confirm Cancellation',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _retryInitialization() {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//     });
//     _initializeBooking();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Booking',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
//               ),
//               SizedBox(height: 16),
//               Text('Loading booking details...'),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_hasError) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Booking',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 100,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Error Loading Booking',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _errorMessage,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _retryInitialization,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                 ),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final Map<String, String> bookingData = {
//       'name': widget.name,
//       'service': widget.service,
//       'provider': _providerName, // Use resolved provider name for display
//       'location': widget.location,
//       'date': widget.date,
//       'time': widget.time,
//       'serviceId': widget.serviceId,
//       'id': _bookingId ?? '',
//       'providerId': widget.provider, // Keep provider ID for reference
//     };

//     var actionButton = ActionButton(
//                 text: 'Cancel Booking',
//                 onPressed: () => _showCancelConfirmationDialog(context),
//                 isOutlined: true,
//                 textColor: Colors.grey,
//               );
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Booking',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Your Booking is DONE!',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Thank you for trusting us',
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               BookingDetailsCard(
//                 bookingData: bookingData,
//                 title: 'Booking Information',
//               ),
//               const SizedBox(height: 30),
//               ActionButton(
//   text: 'Go to Booking Details',
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => BookingTimesTableView(
//           bookingData: bookingData,
//         ),
//       ),
//     );
//   },
//   backgroundColor: Colors.teal,
//   textColor: Colors.white,
// ),
// const SizedBox(height: 16),
//               const SizedBox(height: 16),
//               actionButton,
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const BottomNavBar(currentIndex: 1),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widget/booking_widgets/booking_details_card.dart';
import '../widget/booking_widgets/booking_form_fields.dart';
import '../widget/bottom_nav_bar.dart';
import 'Bookingform.dart';
import 'Bookingtimestableview.dart';

class BookingConfirmation extends StatefulWidget {
  final String name;
  final String location;
  final String time;
  final String date;
  final String service;
  final String provider; // This is provider ID
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

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  String? _bookingId;
  bool _isLoading = true;
  String _providerName = ''; // Store resolved provider name
  
  // Cache system like in BookingTimesTableView
  static Map<String, String> _providerNames = {}; 
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeBooking();
  }

  Future<void> _initializeBooking() async {
    try {
      // Step 1: Resolve provider name first
      await _resolveProviderName();
      
      // Step 2: Save booking to Firebase with the resolved provider name
      await _saveBookingToFirebase();
      
      print('Booking initialized successfully');
      print('Provider ID: ${widget.provider}');
      print('Provider Name: $_providerName');
      
    } catch (e) {
      print('Error in _initializeBooking: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to initialize booking: $e';
      });
    }
  }

  Future<void> _resolveProviderName() async {
    try {
      if (widget.provider.isNotEmpty) {
        print('Resolving provider name for ID: ${widget.provider}');
        _providerName = await _getProviderName(widget.provider);
        print('Resolved provider name: $_providerName');
      } else {
        print('Provider ID is empty');
        _providerName = 'Unknown Provider';
      }
    } catch (e) {
      print('Error resolving provider name: $e');
      _providerName = widget.provider; // Fallback to ID
    }
  }

  // Same method as in BookingTimesTableView with enhanced logging
  Future<String> _getProviderName(String providerId) async {
    print('Getting provider name for ID: $providerId');
    
    // Check cache first
    if (_providerNames.containsKey(providerId)) {
      print('Found in cache: ${_providerNames[providerId]}');
      return _providerNames[providerId]!;
    }

    try {
      print('Fetching from Firestore...');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        print('User document data: $data');
        
        String fullName = _extractFullName(data);
        print('Extracted full name: $fullName');
        
        _providerNames[providerId] = fullName;
        return fullName;
      } else {
        print('User document does not exist for ID: $providerId');
      }

      // If not found, save ID as is
      _providerNames[providerId] = providerId;
      return providerId;
    } catch (e) {
      print('Error fetching provider name for ID $providerId: $e');
      _providerNames[providerId] = providerId;
      return providerId;
    }
  }

  // Same method as in BookingTimesTableView
  String _extractFullName(Map<String, dynamic>? data) {
    if (data == null) {
      print('Data is null');
      return '';
    }
    
    String firstName = data['firstName']?.toString() ?? '';
    String lastName = data['lastName']?.toString() ?? '';
    String nameField = data['name']?.toString() ?? '';
    
    print('firstName: $firstName, lastName: $lastName, name: $nameField');
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (nameField.isNotEmpty) {
      return nameField;
    } else {
      return '';
    }
  }

  Future<void> _saveBookingToFirebase() async {
    try {
      print('Saving booking to Firebase...');
      print('Provider ID: ${widget.provider}');
      print('Provider Name: $_providerName');
      
      final docRef = await FirebaseFirestore.instance.collection('bookingnow').add({
        'name': widget.name,
        'location': widget.location,
        'time': widget.time,
        'date': widget.date,
        'service': widget.service,
        'provider': widget.provider, // Keep as provider ID in database
        'providerName': _providerName, // Also save resolved name for easier querying
        'serviceId': widget.serviceId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('Booking saved with ID: ${docRef.id}');
      
      setState(() {
        _bookingId = docRef.id;
        _isLoading = false;
      });
    } catch (e) {
      print('Error saving booking to Firebase: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to save booking: $e';
      });
    }
  }

  Future<void> _deleteCancelledBooking(BuildContext context) async {
    if (_bookingId == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('bookingnow')
          .doc(_bookingId)
          .delete();
      
      print('Booking deleted successfully');
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => BookingForm(service: {},)), // Replace with your home page
        (Route<dynamic> route) => false,
      );
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
                Navigator.of(context).pop(); 
                _deleteCancelledBooking(context);
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

  void _retryInitialization() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _initializeBooking();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
              SizedBox(height: 16),
              Text('Loading booking details...'),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Booking',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryInitialization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Create booking data with resolved provider name
    final Map<String, String> bookingData = {
      'name': widget.name,
      'service': widget.service,
      'provider': _providerName.isNotEmpty ? _providerName : widget.provider, // Use resolved name if available
      'location': widget.location,
      'date': widget.date,
      'time': widget.time,
      'serviceId': widget.serviceId,
      'id': _bookingId ?? '',
      'providerId': widget.provider, // Keep provider ID for reference
    };

    print('Final booking data for display: $bookingData');

    var actionButton = ActionButton(
                text: 'Cancel Booking',
                onPressed: () => _showCancelConfirmationDialog(context),
                isOutlined: true,
                textColor: Colors.grey,
              );
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
              const SizedBox(height: 16),
              actionButton,
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}