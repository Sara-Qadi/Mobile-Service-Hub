// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/notification_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  
//   // Get current user ID
//   String? get currentUserId => _auth.currentUser?.uid;

//   // Reference to notifications collection
//   CollectionReference get _notificationsRef => 
//       _firestore.collection('notifications');

//   // Get notifications for current user
//   Stream<List<NotificationModel>> getNotifications() {
//     if (currentUserId == null) {
//       // Return empty list if no user is logged in
//       return Stream.value([]);
//     }
    
//     return _notificationsRef
//         .where('userId', isEqualTo: currentUserId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => NotificationModel.fromFirestore(doc))
//               .toList();
//         });
//   }

//   // Mark notification as read
//   Future<void> markAsRead(String notificationId) async {
//     return _notificationsRef
//         .doc(notificationId)
//         .update({'isRead': true});
//   }

//   // Mark all notifications as read
//   Future<void> markAllAsRead() async {
//     if (currentUserId == null) return;
    
//     QuerySnapshot querySnapshot = await _notificationsRef
//         .where('userId', isEqualTo: currentUserId)
//         .where('isRead', isEqualTo: false)
//         .get();
    
//     WriteBatch batch = _firestore.batch();
    
//     querySnapshot.docs.forEach((doc) {
//       batch.update(doc.reference, {'isRead': true});
//     });
    
//     return batch.commit();
//   }

//   // Delete notification
//   Future<void> deleteNotification(String notificationId) async {
//     return _notificationsRef.doc(notificationId).delete();
//   }

//   // Create new notification (useful for testing)
//   Future<Future<DocumentReference<Object?>>> createNotification(NotificationModel notification) async {
//     return _notificationsRef.add(notification.toFirestore());
//   }

//   // Get notification details (provider, booking, client)
//   Future<Map<String, dynamic>?> getRelatedData(NotificationModel notification) async {
//     try {
//       switch (notification.type) {
//         case NotificationType.provider:
//           if (notification.providerId != null) {
//             final providerDoc = await _firestore
//                 .collection('providers')
//                 .doc(notification.providerId)
//                 .get();
            
//             if (providerDoc.exists) {
//               final data = providerDoc.data() as Map<String, dynamic>;
              
//               // Convert to string map for UI
//               return Map<String, String>.from(
//                 data.map((key, value) => MapEntry(key, value.toString()))
//               );
//             }
//           }
//           break;
          
//         case NotificationType.booking:
//         case NotificationType.reminder:
//           if (notification.bookingId != null) {
//             final bookingDoc = await _firestore
//                 .collection('bookings')
//                 .doc(notification.bookingId)
//                 .get();
            
//             if (bookingDoc.exists) {
//               final data = bookingDoc.data() as Map<String, dynamic>;
              
//               // Convert to string map for UI
//               return Map<String, String>.from(
//                 data.map((key, value) => MapEntry(key, value.toString()))
//               );
//             }
//           }
//           break;
          
//         case NotificationType.clientRequest:
//           if (notification.clientId != null) {
//             final clientDoc = await _firestore
//                 .collection('clients')
//                 .doc(notification.clientId)
//                 .get();
            
//             if (clientDoc.exists) {
//               final data = clientDoc.data() as Map<String, dynamic>;
              
//               // Convert to string map for UI
//               return Map<String, String>.from(
//                 data.map((key, value) => MapEntry(key, value.toString()))
//               );
//             }
//           }
//           break;
          
//         default:
//           // No related data to fetch
//           return null;
//       }
//     } catch (e) {
//       print('Error fetching related data: $e');
//     }
    
//     return null;
//   }
// }