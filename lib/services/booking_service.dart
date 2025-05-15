// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/booking_model.dart';

// class BookingService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Get all services
//   Future<List<Map<String, dynamic>>> getServices() async {
//     try {
//       QuerySnapshot servicesSnapshot = await _firestore.collection('Services').get();
//       return servicesSnapshot.docs.map((doc) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         return {
//           'id': doc.id,
//           'name': data['name'] ?? 'Unknown Service',
//           'price': data['price'] ?? 0,
//         };
//       }).toList();
//     } catch (e) {
//       print('Error getting services: $e');
//       return [];
//     }
//   }

//   // Get service provider details
//   Future<Map<String, dynamic>> getServiceProvider(String providerId) async {
//     try {
//       DocumentSnapshot providerDoc = await _firestore.collection('Providers').doc(providerId).get();
//       Map<String, dynamic> data = providerDoc.data() as Map<String, dynamic>;
//       return {
//         'id': providerDoc.id,
//         'name': data['name'] ?? 'Unknown Provider',
//       };
//     } catch (e) {
//       print('Error getting provider: $e');
//       return {'id': providerId, 'name': 'Unknown Provider'};
//     }
//   }

//   // Create a new booking
//   Future<String> createBooking({
//     required String clientId,
//     required String providerId,
//     required String serviceId,
//     required DateTime bookingDateTime,
//     required String location,
//     required double amount,
//     String paymentMethod = 'Cash',
//     String paymentStatus = 'paid',
//     String notes = '',
//   }) async {
//     try {
//       DocumentReference docRef = await _firestore.collection('Bookings').add({
//         'clientId': clientId,
//         'providerId': providerId,
//         'serviceId': serviceId,
//         'date': Timestamp.fromDate(bookingDateTime),
//         'location': location,
//         'status': 'confirmed',
//         'payment': {
//           'amount': amount,
//           'method': paymentMethod,
//           'status': paymentStatus,
//         },
//         'notes': notes,
//         'createdAt': Timestamp.now(),
//       });
      
//       return docRef.id;
//     } catch (e) {
//       print('Error creating booking: $e');
//       throw Exception('Failed to create booking');
//     }
//   }

//   // Cancel a booking
//   Future<void> cancelBooking(String bookingId) async {
//     try {
//       await _firestore.collection('Bookings').doc(bookingId).delete();
//     } catch (e) {
//       print('Error cancelling booking: $e');
//       throw Exception('Failed to cancel booking');
//     }
//   }

//   // Get booking details
//   Future<BookingModel?> getBookingById(String bookingId) async {
//     try {
//       DocumentSnapshot bookingDoc = await _firestore.collection('Bookings').doc(bookingId).get();
      
//       if (!bookingDoc.exists) {
//         return null;
//       }
      
//       BookingModel booking = BookingModel.fromFirestore(bookingDoc);
      
//       // Get related data
//       DocumentSnapshot clientDoc = await _firestore.collection('Users').doc(booking.clientId).get();
//       if (clientDoc.exists) {
//         Map<String, dynamic> clientData = clientDoc.data() as Map<String, dynamic>;
//         booking.clientName = clientData['name'] ?? 'Unknown Client';
//       }
      
//       DocumentSnapshot providerDoc = await _firestore.collection('Providers').doc(booking.providerId).get();
//       if (providerDoc.exists) {
//         Map<String, dynamic> providerData = providerDoc.data() as Map<String, dynamic>;
//         booking.providerName = providerData['name'] ?? 'Unknown Provider';
//       }
      
//       DocumentSnapshot serviceDoc = await _firestore.collection('Services').doc(booking.serviceId).get();
//       if (serviceDoc.exists) {
//         Map<String, dynamic> serviceData = serviceDoc.data() as Map<String, dynamic>;
//         booking.serviceName = serviceData['name'] ?? 'Unknown Service';
//       }
      
//       return booking;
//     } catch (e) {
//       print('Error getting booking: $e');
//       return null;
//     }
//   }
  
//   // Get all client bookings
//   Future<List<BookingModel>> getClientBookings(String clientId) async {
//     try {
//       QuerySnapshot bookingsSnapshot = await _firestore
//           .collection('Bookings')
//           .where('clientId', isEqualTo: clientId)
//           .orderBy('date', descending: true)
//           .get();
          
//       List<BookingModel> bookings = [];
      
//       for (var doc in bookingsSnapshot.docs) {
//         BookingModel booking = BookingModel.fromFirestore(doc);
//         bookings.add(booking);
//       }
      
//       return bookings;
//     } catch (e) {
//       print('Error getting client bookings: $e');
//       return [];
//     }
//   }
// }