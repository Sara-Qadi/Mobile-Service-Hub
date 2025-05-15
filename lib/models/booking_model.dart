// import 'package:cloud_firestore/cloud_firestore.dart';

// class BookingModel {
//   final String id;
//   final String clientId;
//   final String providerId;
//   final String serviceId;
//   final Timestamp date;
//   final String location;
//   final String status;
//   final Map<String, dynamic> payment;
//   final String notes;
//   final Timestamp createdAt;
  
//   String? clientName;
//   String? providerName;
//   String? serviceName;

//   BookingModel({
//     required this.id,
//     required this.clientId,
//     required this.providerId,
//     required this.serviceId,
//     required this.date,
//     required this.location,
//     required this.status,
//     required this.payment,
//     required this.notes,
//     required this.createdAt,
//     this.clientName,
//     this.providerName,
//     this.serviceName,
//   });

//   factory BookingModel.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
//     return BookingModel(
//       id: doc.id,
//       clientId: data['clientId'] ?? '',
//       providerId: data['providerId'] ?? '',
//       serviceId: data['serviceId'] ?? '',
//       date: data['date'] ?? Timestamp.now(),
//       location: data['location'] ?? '',
//       status: data['status'] ?? 'pending',
//       payment: data['payment'] ?? {'amount': 0, 'method': '', 'status': ''},
//       notes: data['notes'] ?? '',
//       createdAt: data['createdAt'] ?? Timestamp.now(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'clientId': clientId,
//       'providerId': providerId,
//       'serviceId': serviceId,
//       'date': date,
//       'location': location,
//       'status': status,
//       'payment': payment,
//       'notes': notes,
//       'createdAt': createdAt,
//     };
//   }

//   String getFormattedDate() {
//     DateTime dateTime = date.toDate();
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }

//   String getFormattedTime() {
//     DateTime dateTime = date.toDate();
//     String hour = dateTime.hour.toString().padLeft(2, '0');
//     String minute = dateTime.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }

//   Map<String, String> toBookingData() {
//     return {
//       'id': id,
//       'name': clientName ?? 'Client: $clientId',
//       'provider': providerName ?? 'Provider: $providerId',
//       'service': serviceName ?? 'Service: $serviceId',
//       'date': getFormattedDate(),
//       'time': getFormattedTime(),
//       'location': location,
//       'status': status,
//       'amount': payment['amount'].toString(),
//       'paymentMethod': payment['method'],
//       'paymentStatus': payment['status'],
//       'notes': notes,
//     };
//   }
// }