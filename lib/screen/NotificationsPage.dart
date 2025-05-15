// import 'package:flutter/material.dart';
// import 'package:mobile_service_hub/screen/Bookingform.dart';
// import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
// import '../main.dart';
// import '../widget/bottom_nav_bar.dart';
// import '../models/notification_model.dart';
// import '../widget/notification_widgets/notification_item.dart';
// import '../widget/notification_widgets/provider_details_card.dart';
// import '../widget/notification_widgets/client_details_card.dart';
// import '../widget/booking_widgets/booking_details_card.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({Key? key}) : super(key: key);

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   late List<NotificationModel> notifications;

//   @override
//   void initState() {
//     super.initState();
    
//     notifications = [
//       NotificationModel(
//         id: '1',
//         title: 'New Provider Available',
//         message: 'Sarah yaseen is now available for appointments',
//         time: '10 minutes ago',
//         isRead: false,
//         type: NotificationType.provider,
//         providerData: {
//           'name': ' Sarah yaseen',
//           'email': 'sarah.yaseen@example.com',
//           'phone': '+1 555-123-4567',
//           'specialty': 'Cardiologist',
//           'experience': '15 years',
//           'location': 'Main Clinic, Floor 2',
//           'rating': '4.8',
//           'availability': 'Mon-Fri, 9AM-5PM',
//         },
//       ),
//       NotificationModel(
//         id: '2',
//         title: 'Booking Confirmed',
//         message: 'Your booking with Dr. Sarah has been confirmed for tomorrow at 2:00 PM',
//         time: '2 hours ago',
//         isRead: false,
//         type: NotificationType.booking,
//         bookingData: {
//           'name': 'User Name',
//           'service': 'Consultation',
//           'provider': 'Dr. Sarah',
//           'location': 'Main Clinic',
//           'date': '02/05/2025',
//           'time': '2:00 PM',
//         },
//       ),
//       NotificationModel(
//         id: '3',
//         title: 'Appointment Reminder',
//         message: 'Your appointment is scheduled in 24 hours',
//         time: '3 hours ago',
//         isRead: true,
//         type: NotificationType.reminder,
//       ),
//       NotificationModel(
//         id: '4',
//         title: 'New Provider Added',
//         message: 'Dr. Michael Smith is now available for consultations',
//         time: '2 days ago',
//         isRead: true,
//         type: NotificationType.provider,
//         providerData: {
//           'name': 'Dr. Michael Smith',
//           'email': 'michael.smith@example.com',
//           'phone': '+1 555-987-6543',
//           'specialty': 'Dermatologist',
//           'experience': '8 years',
//           'location': 'Downtown Clinic',
//           'rating': '4.6',
//           'availability': 'Wed-Sun, 10AM-6PM',
//         },
//       ),
//       NotificationModel(
//         id: '5',
//         title: 'Booking Cancelled',
//         message: 'Your booking with Dr. John has been cancelled',
//         time: '1 day ago',
//         isRead: true,
//         type: NotificationType.booking,
//         bookingData: {
//           'name': 'User Name',
//           'service': 'Check-up',
//           'provider': 'Dr. John',
//           'location': 'Downtown Clinic',
//           'date': '28/04/2025',
//           'time': '11:30 AM',
//         },
//       ),
//       NotificationModel(
//         id: '6',
//         title: 'Special Offer',
//         message: 'Get 20% off on your next booking',
//         time: '2 days ago',
//         isRead: true,
//         type: NotificationType.promotion,
//       ),
//       NotificationModel(
//         id: '7',
//         title: 'New Service Available',
//         message: 'Check out our new services available at your location',
//         time: '3 days ago',
//         isRead: true,
//         type: NotificationType.info,
//       ),
//       NotificationModel(
//         id: '8',
//         title: 'New Booking Request',
//         message: 'John Smith requested a consultation appointment',
//         time: '30 minutes ago',
//         isRead: false,
//         type: NotificationType.clientRequest,
//         clientData: {
//           'name': 'John Smith',
//           'email': 'john.smith@example.com',
//           'phone': '+1 555-234-5678',
//           'service': 'Consultation',
//           'date': '10/05/2025',
//           'time': '3:30 PM',
//           'notes': 'First-time client seeking consultation',
//         },
//       ),
//     ];
//   }

//   void markAsRead(String id) {
//     setState(() {
//       final index = notifications.indexWhere((notification) => notification.id == id);
//       if (index != -1) {
//         notifications[index] = notifications[index].copyWith(isRead: true);
//       }
//     });
//   }

//   void markAllAsRead() {
//     setState(() {
//       notifications = notifications.map((notification) => notification.copyWith(isRead: true)).toList();
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('All notifications marked as read')),
//     );
//   }

//   void deleteNotification(String id) {
//     setState(() {
//       notifications.removeWhere((notification) => notification.id == id);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Notification deleted')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Notifications',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => markAllAsRead(),
//             child: Text(
//               'Mark all as read',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: notifications.isEmpty
//           ? _buildEmptyState(context)
//           : ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 return NotificationItemWidget(
//                   notification: notifications[index],
//                   onTap: (id) {
//                     markAsRead(id);
                    
//                     final notification = notifications.firstWhere((n) => n.id == id);
                    
//                     if (notification.type == NotificationType.provider && notification.providerData != null) {
//                       _showProviderDetailsPopup(context, notification.providerData!);
//                     } else if (notification.type == NotificationType.clientRequest && notification.clientData != null) {
//                       _showClientRequestDetailsPopup(context, notification.clientData!);
//                     } else {
//                       _showNotificationDetail(context, notification);
//                     }
//                   },
//                   onDelete: deleteNotification,
//                 );
//               },
//             ),
//       bottomNavigationBar: const BottomNavBar(currentIndex: 2),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           const Text(
//             'No Notifications',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'You don\'t have any notifications at the moment',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showProviderDetailsPopup(BuildContext context, Map<String, String> providerData) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Provider Details',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ProviderDetailsCard(providerData: providerData),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: const Text("Confirm Rejection"),
//                               content: const Text("Are you sure you want to reject this provider?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: const Text("CANCEL"),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('Provider rejected')),
//                                     );
//                                   },
//                                   child: const Text("REJECT", style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red.shade400,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Reject',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const BookingForm()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Accept',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showClientRequestDetailsPopup(BuildContext context, Map<String, String> clientData) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Client Request',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ClientDetailsCard(clientData: clientData),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: const Text("Confirm Rejection"),
//                               content: const Text("Are you sure you want to reject this booking request?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: const Text("CANCEL"),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('Booking request rejected')),
//                                     );
//                                   },
//                                   child: const Text("REJECT", style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red.shade400,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Reject',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Booking request accepted')),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Accept',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showNotificationDetail(BuildContext context, NotificationModel notification) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           height: MediaQuery.of(context).size.height * 0.75,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     notification.title,
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text("Confirm"),
//                                 content: const Text("Are you sure you want to delete this notification?"),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.of(context).pop(),
//                                     child: const Text("CANCEL"),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                       Navigator.of(context).pop();
//                                       deleteNotification(notification.id);
//                                     },
//                                     child: const Text("DELETE", style: TextStyle(color: Colors.red)),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 notification.time,
//                 style: TextStyle(color: Colors.grey.shade600),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 notification.message,
//                 style: const TextStyle(fontSize: 16, height: 1.5),
//               ),
//               const SizedBox(height: 20),
//               if (notification.type == NotificationType.booking && notification.bookingData != null)
//                 BookingDetailsCard(bookingData: notification.bookingData!),
//               const Spacer(),
//               if (notification.type == NotificationType.booking)
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookingTimesTableView(
//                             bookingData: notification.bookingData ?? {},
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text(
//                       'View Full Booking Details',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//  }


// // // import 'package:flutter/material.dart';
// // // import 'package:mobile_service_hub/screen/Bookingform.dart';
// // // import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import '../main.dart';
// // // import '../widget/bottom_nav_bar.dart';
// // // import '../models/notification_model.dart';
// // // import '../widget/notification_widgets/notification_item.dart';
// // // import '../widget/notification_widgets/provider_details_card.dart';
// // // import '../widget/notification_widgets/client_details_card.dart';
// // // import '../widget/booking_widgets/booking_details_card.dart';

// // // class NotificationsScreen extends StatefulWidget {
// // //   const NotificationsScreen({Key? key}) : super(key: key);

// // //   @override
// // //   State<NotificationsScreen> createState() => _NotificationsScreenState();
// // // }

// // // class _NotificationsScreenState extends State<NotificationsScreen> {
// // //   late Stream<QuerySnapshot> _notificationsStream;
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   final String? _userId = FirebaseAuth.instance.currentUser?.uid;
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _initNotificationsStream();
// // //   }

// // //   void _initNotificationsStream() {
// // //     // Initialize notifications stream based on current user ID
// // //     if (_userId != null) {
// // //       _notificationsStream = _firestore
// // //           .collection('notifications')
// // //           .where('userId', isEqualTo: _userId)
// // //           .orderBy('timestamp', descending: true)
// // //           .snapshots();
// // //     } else {
// // //       // If user ID is null, use an empty stream
// // //       _notificationsStream = _firestore
// // //           .collection('notifications')
// // //           .where('userId', isEqualTo: 'no-user')  // This condition returns no documents
// // //           .snapshots();
// // //     }
// // //   }

// // //   Future<void> markAsRead(String notificationId) async {
// // //     try {
// // //       await _firestore
// // //           .collection('notifications')
// // //           .doc(notificationId)
// // //           .update({'isRead': true});
// // //     } catch (e) {
// // //       print('Error marking notification as read: $e');
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Error updating notification status')),
// // //       );
// // //     }
// // //   }

// // //   Future<void> markAllAsRead() async {
// // //     try {
// // //       // Get all unread notifications for current user
// // //       final batch = _firestore.batch();
// // //       final unreadNotifications = await _firestore
// // //           .collection('notifications')
// // //           .where('userId', isEqualTo: _userId)
// // //           .where('isRead', isEqualTo: false)
// // //           .get();

// // //       // Update all notifications in a single batch operation
// // //       for (var doc in unreadNotifications.docs) {
// // //         batch.update(doc.reference, {'isRead': true});
// // //       }

// // //       await batch.commit();
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('All notifications marked as read')),
// // //       );
// // //     } catch (e) {
// // //       print('Error marking all notifications as read: $e');
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Error updating notification status')),
// // //       );
// // //     }
// // //   }

// // //   Future<void> deleteNotification(String notificationId) async {
// // //     try {
// // //       await _firestore
// // //           .collection('notifications')
// // //           .doc(notificationId)
// // //           .delete();
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Notification deleted')),
// // //       );
// // //     } catch (e) {
// // //       print('Error deleting notification: $e');
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Error deleting notification')),
// // //       );
// // //     }
// // //   }

// // //   // Convert Firestore document to NotificationModel
// // //   NotificationModel _documentToNotificationModel(DocumentSnapshot document) {
// // //     final data = document.data() as Map<String, dynamic>;
    
// // //     // Convert timestamp from Firestore to string
// // //     final Timestamp timestamp = data['timestamp'] as Timestamp;
// // //     final DateTime dateTime = timestamp.toDate();
    
// // //     // Calculate time elapsed since notification creation
// // //     final difference = DateTime.now().difference(dateTime);
// // //     String timeAgo;
    
// // //     if (difference.inMinutes < 60) {
// // //       timeAgo = '${difference.inMinutes} minutes ago';
// // //     } else if (difference.inHours < 24) {
// // //       timeAgo = '${difference.inHours} hours ago';
// // //     } else {
// // //       timeAgo = '${difference.inDays} days ago';
// // //     }

// // //     // Extract notification type
// // //     NotificationType type;
// // //     switch (data['type']) {
// // //       case 'provider':
// // //         type = NotificationType.provider;
// // //         break;
// // //       case 'booking':
// // //         type = NotificationType.booking;
// // //         break;
// // //       case 'reminder':
// // //         type = NotificationType.reminder;
// // //         break;
// // //       case 'promotion':
// // //         type = NotificationType.promotion;
// // //         break;
// // //       case 'info':
// // //         type = NotificationType.info;
// // //         break;
// // //       case 'clientRequest':
// // //         type = NotificationType.clientRequest;
// // //         break;
// // //       default:
// // //         type = NotificationType.info;
// // //     }

// // //     // Additional data based on notification type
// // //     Map<String, String>? providerData;
// // //     Map<String, String>? bookingData;
// // //     Map<String, String>? clientData;

// // //     if (data['providerData'] != null) {
// // //       providerData = Map<String, String>.from(data['providerData']);
// // //     }

// // //     if (data['bookingData'] != null) {
// // //       bookingData = Map<String, String>.from(data['bookingData']);
// // //     }

// // //     if (data['clientData'] != null) {
// // //       clientData = Map<String, String>.from(data['clientData']);
// // //     }

// // //     return NotificationModel(
// // //       id: document.id,
// // //       title: data['title'] ?? '',
// // //       message: data['message'] ?? '',
// // //       time: timeAgo,
// // //       isRead: data['isRead'] ?? false,
// // //       type: type,
// // //       providerData: providerData,
// // //       bookingData: bookingData,
// // //       clientData: clientData,
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text(
// // //           'Notifications',
// // //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => markAllAsRead(),
// // //             child: const Text(
// // //               'Mark All as Read',
// // //               style: TextStyle(
// // //                 color: Colors.white,
// // //                 fontWeight: FontWeight.w500,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //       body: StreamBuilder<QuerySnapshot>(
// // //         stream: _notificationsStream,
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             return const Center(child: CircularProgressIndicator());
// // //           }

// // //           if (snapshot.hasError) {
// // //             return Center(
// // //               child: Text('Error: ${snapshot.error}'),
// // //             );
// // //           }

// // //           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //             return _buildEmptyState(context);
// // //           }

// // //           // Convert documents to list of NotificationModel
// // //           final notifications = snapshot.data!.docs.map((doc) {
// // //             return _documentToNotificationModel(doc);
// // //           }).toList();

// // //           return ListView.builder(
// // //             itemCount: notifications.length,
// // //             itemBuilder: (context, index) {
// // //               return NotificationItemWidget(
// // //                 notification: notifications[index],
// // //                 onTap: (id) {
// // //                   markAsRead(id);
                  
// // //                   final notification = notifications.firstWhere((n) => n.id == id);
                  
// // //                   if (notification.type == NotificationType.provider && notification.providerData != null) {
// // //                     _showProviderDetailsPopup(context, notification.providerData!);
// // //                   } else if (notification.type == NotificationType.clientRequest && notification.clientData != null) {
// // //                     _showClientRequestDetailsPopup(context, notification.clientData!);
// // //                   } else {
// // //                     _showNotificationDetail(context, notification);
// // //                   }
// // //                 },
// // //                 onDelete: deleteNotification,
// // //               );
// // //             },
// // //           );
// // //         },
// // //       ),
// // //       bottomNavigationBar: const BottomNavBar(currentIndex: 2),
// // //     );
// // //   }

// // //   Widget _buildEmptyState(BuildContext context) {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
// // //           const SizedBox(height: 16),
// // //           const Text(
// // //             'No Notifications',
// // //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //           ),
// // //           const SizedBox(height: 8),
// // //           const Text(
// // //             'You have no notifications at this time',
// // //             style: TextStyle(color: Colors.grey),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   void _showProviderDetailsPopup(BuildContext context, Map<String, String> providerData) {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //       ),
// // //       builder: (context) {
// // //         return Padding(
// // //           padding: const EdgeInsets.all(20),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   const Text(
// // //                     'Service Provider Details',
// // //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //                   ),
// // //                   IconButton(
// // //                     icon: const Icon(Icons.close),
// // //                     onPressed: () => Navigator.pop(context),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 16),
// // //               ProviderDetailsCard(providerData: providerData),
// // //               const SizedBox(height: 16),
// // //               Row(
// // //                 children: [
// // //                   Expanded(
// // //                     child: ElevatedButton(
// // //                       onPressed: () async {
// // //                         Navigator.pop(context);
// // //                         showDialog(
// // //                           context: context,
// // //                           builder: (BuildContext context) {
// // //                             return AlertDialog(
// // //                               title: const Text("Confirm Rejection"),
// // //                               content: const Text("Are you sure you want to reject this service provider?"),
// // //                               actions: [
// // //                                 TextButton(
// // //                                   onPressed: () => Navigator.of(context).pop(),
// // //                                   child: const Text("Cancel"),
// // //                                 ),
// // //                                 TextButton(
// // //                                   onPressed: () async {
// // //                                     Navigator.of(context).pop();
                                    
// // //                                     try {
// // //                                       // Update provider status in Firestore
// // //                                       await _firestore
// // //                                           .collection('providers')
// // //                                           .doc(providerData['id'])
// // //                                           .update({'status': 'rejected'});
                                          
// // //                                       ScaffoldMessenger.of(context).showSnackBar(
// // //                                         const SnackBar(content: Text('Service provider rejected')),
// // //                                       );
// // //                                     } catch (e) {
// // //                                       print('Error rejecting provider: $e');
// // //                                       ScaffoldMessenger.of(context).showSnackBar(
// // //                                         const SnackBar(content: Text('Error rejecting service provider')),
// // //                                       );
// // //                                     }
// // //                                   },
// // //                                   child: const Text("Reject", style: TextStyle(color: Colors.red)),
// // //                                 ),
// // //                               ],
// // //                             );
// // //                           },
// // //                         );
// // //                       },
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Colors.red.shade400,
// // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // //                       ),
// // //                       child: const Text(
// // //                         'Reject',
// // //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 12),
// // //                   Expanded(
// // //                     child: ElevatedButton(
// // //                       onPressed: () async {
// // //                         Navigator.pop(context);
                        
// // //                         try {
// // //                           // Update provider status in Firestore
// // //                           await _firestore
// // //                               .collection('providers')
// // //                               .doc(providerData['id'])
// // //                               .update({'status': 'approved'});
                              
// // //                           // Navigate to booking form
// // //                           Navigator.push(
// // //                             context,
// // //                             MaterialPageRoute(builder: (context) => const BookingForm()),
// // //                           );
// // //                         } catch (e) {
// // //                           print('Error approving provider: $e');
// // //                           ScaffoldMessenger.of(context).showSnackBar(
// // //                             const SnackBar(content: Text('Error approving service provider')),
// // //                           );
// // //                         }
// // //                       },
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Colors.teal,
// // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // //                       ),
// // //                       child: const Text(
// // //                         'Accept',
// // //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   void _showClientRequestDetailsPopup(BuildContext context, Map<String, String> clientData) {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //       ),
// // //       builder: (context) {
// // //         return Padding(
// // //           padding: const EdgeInsets.all(20),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   const Text(
// // //                     'Client Request',
// // //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //                   ),
// // //                   IconButton(
// // //                     icon: const Icon(Icons.close),
// // //                     onPressed: () => Navigator.pop(context),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 16),
// // //               ClientDetailsCard(clientData: clientData),
// // //               const SizedBox(height: 16),
// // //               Row(
// // //                 children: [
// // //                   Expanded(
// // //                     child: ElevatedButton(
// // //                       onPressed: () async {
// // //                         Navigator.pop(context);
// // //                         showDialog(
// // //                           context: context,
// // //                           builder: (BuildContext context) {
// // //                             return AlertDialog(
// // //                               title: const Text("Confirm Rejection"),
// // //                               content: const Text("Are you sure you want to reject this booking request?"),
// // //                               actions: [
// // //                                 TextButton(
// // //                                   onPressed: () => Navigator.of(context).pop(),
// // //                                   child: const Text("Cancel"),
// // //                                 ),
// // //                                 TextButton(
// // //                                   onPressed: () async {
// // //                                     Navigator.of(context).pop();
                                    
// // //                                     try {
// // //                                       // Update booking status in Firestore
// // //                                       await _firestore
// // //                                           .collection('bookings')
// // //                                           .doc(clientData['bookingId'])
// // //                                           .update({'status': 'rejected'});
                                          
// // //                                       // Send notification to client (can be added later)
                                      
// // //                                       ScaffoldMessenger.of(context).showSnackBar(
// // //                                         const SnackBar(content: Text('Booking request rejected')),
// // //                                       );
// // //                                     } catch (e) {
// // //                                       print('Error rejecting booking: $e');
// // //                                       ScaffoldMessenger.of(context).showSnackBar(
// // //                                         const SnackBar(content: Text('Error rejecting booking request')),
// // //                                       );
// // //                                     }
// // //                                   },
// // //                                   child: const Text("Reject", style: TextStyle(color: Colors.red)),
// // //                                 ),
// // //                               ],
// // //                             );
// // //                           },
// // //                         );
// // //                       },
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Colors.red.shade400,
// // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // //                       ),
// // //                       child: const Text(
// // //                         'Reject',
// // //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 12),
// // //                   Expanded(
// // //                     child: ElevatedButton(
// // //                       onPressed: () async {
// // //                         Navigator.pop(context);
                        
// // //                         try {
// // //                           // Update booking status in Firestore
// // //                           await _firestore
// // //                               .collection('bookings')
// // //                               .doc(clientData['bookingId'])
// // //                               .update({'status': 'approved'});
                          
// // //                           // Send notification to client (can be added later)
                          
// // //                           ScaffoldMessenger.of(context).showSnackBar(
// // //                             const SnackBar(content: Text('Booking request accepted')),
// // //                           );
// // //                         } catch (e) {
// // //                           print('Error approving booking: $e');
// // //                           ScaffoldMessenger.of(context).showSnackBar(
// // //                             const SnackBar(content: Text('Error accepting booking request')),
// // //                           );
// // //                         }
// // //                       },
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Colors.teal,
// // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // //                       ),
// // //                       child: const Text(
// // //                         'Accept',
// // //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   void _showNotificationDetail(BuildContext context, NotificationModel notification) {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //       ),
// // //       builder: (context) {
// // //         return Container(
// // //           padding: const EdgeInsets.all(20),
// // //           height: MediaQuery.of(context).size.height * 0.75,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text(
// // //                     notification.title,
// // //                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //                   ),
// // //                   Row(
// // //                     children: [
// // //                       IconButton(
// // //                         icon: const Icon(Icons.delete, color: Colors.red),
// // //                         onPressed: () {
// // //                           showDialog(
// // //                             context: context,
// // //                             builder: (BuildContext context) {
// // //                               return AlertDialog(
// // //                                 title: const Text("Confirm"),
// // //                                 content: const Text("Are you sure you want to delete this notification?"),
// // //                                 actions: [
// // //                                   TextButton(
// // //                                     onPressed: () => Navigator.of(context).pop(),
// // //                                     child: const Text("Cancel"),
// // //                                   ),
// // //                                   TextButton(
// // //                                     onPressed: () {
// // //                                       Navigator.of(context).pop();
// // //                                       Navigator.of(context).pop();
// // //                                       deleteNotification(notification.id);
// // //                                     },
// // //                                     child: const Text("Delete", style: TextStyle(color: Colors.red)),
// // //                                   ),
// // //                                 ],
// // //                               );
// // //                             },
// // //                           );
// // //                         },
// // //                       ),
// // //                       IconButton(
// // //                         icon: const Icon(Icons.close),
// // //                         onPressed: () => Navigator.pop(context),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 6),
// // //               Text(
// // //                 notification.time,
// // //                 style: TextStyle(color: Colors.grey.shade600),
// // //               ),
// // //               const SizedBox(height: 20),
// // //               Text(
// // //                 notification.message,
// // //                 style: const TextStyle(fontSize: 16, height: 1.5),
// // //               ),
// // //               const SizedBox(height: 20),
// // //               if (notification.type == NotificationType.booking && notification.bookingData != null)
// // //                 BookingDetailsCard(bookingData: notification.bookingData!),
// // //               const Spacer(),
// // //               if (notification.type == NotificationType.booking)
// // //                 SizedBox(
// // //                   width: double.infinity,
// // //                   child: ElevatedButton(
// // //                     onPressed: () {
// // //                       Navigator.pop(context);
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(
// // //                           builder: (context) => BookingTimesTableView(
// // //                             bookingData: notification.bookingData ?? {},
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: Colors.teal,
// // //                       padding: const EdgeInsets.symmetric(vertical: 16),
// // //                     ),
// // //                     child: const Text(
// // //                       'View Full Booking Details',
// // //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// // //                     ),
// // //                   ),
// // //                 ),
// // //             ],
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }


// // import 'package:flutter/material.dart';
// // import 'package:mobile_service_hub/screen/Bookingform.dart';
// // import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
// // import '../main.dart';
// // import '../widget/bottom_nav_bar.dart';
// // import '../models/notification_model.dart';
// // import '../widget/notification_widgets/notification_item.dart';
// // import '../widget/notification_widgets/provider_details_card.dart';
// // import '../widget/notification_widgets/client_details_card.dart';
// // import '../widget/booking_widgets/booking_details_card.dart';
// // import '../services/notification_service.dart';

// // class NotificationsScreen extends StatefulWidget {
// //   const NotificationsScreen({Key? key}) : super(key: key);

// //   @override
// //   State<NotificationsScreen> createState() => _NotificationsScreenState();
// // }

// // class _NotificationsScreenState extends State<NotificationsScreen> {
// //   final NotificationService _notificationService = NotificationService();
  
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           'Notifications',
// //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () async {
// //               await _notificationService.markAllAsRead();
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('All notifications marked as read')),
// //               );
// //             },
// //             child: const Text(
// //               'Mark all as read',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       body: StreamBuilder<List<NotificationModel>>(
// //         stream: _notificationService.getNotifications(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
          
// //           if (snapshot.hasError) {
// //             return Center(
// //               child: Text(
// //                 'Error: ${snapshot.error}',
// //                 style: const TextStyle(color: Colors.red),
// //               ),
// //             );
// //           }
          
// //           final notifications = snapshot.data ?? [];
          
// //           if (notifications.isEmpty) {
// //             return _buildEmptyState(context);
// //           }
          
// //           return ListView.builder(
// //             itemCount: notifications.length,
// //             itemBuilder: (context, index) {
// //               return NotificationItemWidget(
// //                 notification: notifications[index],
// //                 onTap: (id) async {
// //                   await _notificationService.markAsRead(id);
                  
// //                   final notification = notifications.firstWhere((n) => n.id == id);
                  
// //                   if (notification.type == NotificationType.provider) {
// //                     // If providerData already exists in notification model
// //                     if (notification.providerData != null) {
// //                       _showProviderDetailsPopup(context, notification.providerData!);
// //                     } else if (notification.providerId != null) {
// //                       // Otherwise fetch provider data from Firestore
// //                       final providerData = await _notificationService.getRelatedData(notification);
// //                       if (providerData != null) {
// //                         _showProviderDetailsPopup(
// //                           context, 
// //                           Map<String, String>.from(providerData)
// //                         );
// //                       }
// //                     }
// //                   } else if (notification.type == NotificationType.clientRequest) {
// //                     // If clientData already exists in notification model
// //                     if (notification.clientData != null) {
// //                       _showClientRequestDetailsPopup(context, notification.clientData!);
// //                     } else if (notification.clientId != null) {
// //                       // Otherwise fetch client data from Firestore
// //                       final clientData = await _notificationService.getRelatedData(notification);
// //                       if (clientData != null) {
// //                         _showClientRequestDetailsPopup(
// //                           context, 
// //                           Map<String, String>.from(clientData)
// //                         );
// //                       }
// //                     }
// //                   } else {
// //                     _showNotificationDetail(context, notification);
// //                   }
// //                 },
// //                 onDelete: (id) async {
// //                   await _notificationService.deleteNotification(id);
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(content: Text('Notification deleted')),
// //                   );
// //                 },
// //               );
// //             },
// //           );
// //         },
// //       ),
// //       bottomNavigationBar: const BottomNavBar(currentIndex: 2),
// //     );
// //   }

// //   Widget _buildEmptyState(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
// //           const SizedBox(height: 16),
// //           const Text(
// //             'No Notifications',
// //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 8),
// //           const Text(
// //             'You don\'t have any notifications at the moment',
// //             style: TextStyle(color: Colors.grey),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showProviderDetailsPopup(BuildContext context, Map<String, String> providerData) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text(
// //                     'Provider Details',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   IconButton(
// //                     icon: const Icon(Icons.close),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               ProviderDetailsCard(providerData: providerData),
// //               const SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         showDialog(
// //                           context: context,
// //                           builder: (BuildContext context) {
// //                             return AlertDialog(
// //                               title: const Text("Confirm Rejection"),
// //                               content: const Text("Are you sure you want to reject this provider?"),
// //                               actions: [
// //                                 TextButton(
// //                                   onPressed: () => Navigator.of(context).pop(),
// //                                   child: const Text("CANCEL"),
// //                                 ),
// //                                 TextButton(
// //                                   onPressed: () {
// //                                     Navigator.of(context).pop();
// //                                     ScaffoldMessenger.of(context).showSnackBar(
// //                                       const SnackBar(content: Text('Provider rejected')),
// //                                     );
// //                                   },
// //                                   child: const Text("REJECT", style: TextStyle(color: Colors.red)),
// //                                 ),
// //                               ],
// //                             );
// //                           },
// //                         );
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.red.shade400,
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                       ),
// //                       child: const Text(
// //                         'Reject',
// //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (context) => const BookingForm()),
// //                         );
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.teal,
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                       ),
// //                       child: const Text(
// //                         'Accept',
// //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void _showClientRequestDetailsPopup(BuildContext context, Map<String, String> clientData) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text(
// //                     'Client Request',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   IconButton(
// //                     icon: const Icon(Icons.close),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               ClientDetailsCard(clientData: clientData),
// //               const SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         showDialog(
// //                           context: context,
// //                           builder: (BuildContext context) {
// //                             return AlertDialog(
// //                               title: const Text("Confirm Rejection"),
// //                               content: const Text("Are you sure you want to reject this booking request?"),
// //                               actions: [
// //                                 TextButton(
// //                                   onPressed: () => Navigator.of(context).pop(),
// //                                   child: const Text("CANCEL"),
// //                                 ),
// //                                 TextButton(
// //                                   onPressed: () {
// //                                     Navigator.of(context).pop();
// //                                     ScaffoldMessenger.of(context).showSnackBar(
// //                                       const SnackBar(content: Text('Booking request rejected')),
// //                                     );
// //                                   },
// //                                   child: const Text("REJECT", style: TextStyle(color: Colors.red)),
// //                                 ),
// //                               ],
// //                             );
// //                           },
// //                         );
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.red.shade400,
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                       ),
// //                       child: const Text(
// //                         'Reject',
// //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(content: Text('Booking request accepted')),
// //                         );
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.teal,
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                       ),
// //                       child: const Text(
// //                         'Accept',
// //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void _showNotificationDetail(BuildContext context, NotificationModel notification) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) {
// //         return Container(
// //           padding: const EdgeInsets.all(20),
// //           height: MediaQuery.of(context).size.height * 0.75,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     notification.title,
// //                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   Row(
// //                     children: [
// //                       IconButton(
// //                         icon: const Icon(Icons.delete, color: Colors.red),
// //                         onPressed: () {
// //                           showDialog(
// //                             context: context,
// //                             builder: (BuildContext context) {
// //                               return AlertDialog(
// //                                 title: const Text("Confirm"),
// //                                 content: const Text("Are you sure you want to delete this notification?"),
// //                                 actions: [
// //                                   TextButton(
// //                                     onPressed: () => Navigator.of(context).pop(),
// //                                     child: const Text("CANCEL"),
// //                                   ),
// //                                   TextButton(
// //                                     onPressed: () async {
// //                                       Navigator.of(context).pop();
// //                                       Navigator.of(context).pop();
// //                                       await _notificationService.deleteNotification(notification.id);
// //                                       ScaffoldMessenger.of(context).showSnackBar(
// //                                         const SnackBar(content: Text('Notification deleted')),
// //                                       );
// //                                     },
// //                                     child: const Text("DELETE", style: TextStyle(color: Colors.red)),
// //                                   ),
// //                                 ],
// //                               );
// //                             },
// //                           );
// //                         },
// //                       ),
// //                       IconButton(
// //                         icon: const Icon(Icons.close),
// //                         onPressed: () => Navigator.pop(context),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 6),
// //               Text(
// //                 notification.time,
// //                 style: TextStyle(color: Colors.grey.shade600),
// //               ),
// //               const SizedBox(height: 20),
// //               Text(
// //                 notification.message,
// //                 style: const TextStyle(fontSize: 16, height: 1.5),
// //               ),
// //               const SizedBox(height: 20),
// //               if (notification.type == NotificationType.booking && notification.bookingData != null)
// //                 BookingDetailsCard(bookingData: notification.bookingData!),
// //               const Spacer(),
// //               if (notification.type == NotificationType.booking)
// //                 FutureBuilder<Map<String, dynamic>?>(
// //                   future: notification.bookingData != null 
// //                       ? Future.value(notification.bookingData) 
// //                       : _notificationService.getRelatedData(notification),
// //                   builder: (context, snapshot) {
// //                     final bookingData = snapshot.data != null 
// //                         ? Map<String, String>.from(snapshot.data!) 
// //                         : notification.bookingData ?? {};
                    
// //                     return SizedBox(
// //                       width: double.infinity,
// //                       child: ElevatedButton(
// //                         onPressed: () {
// //                           Navigator.pop(context);
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => BookingTimesTableView(
// //                                 bookingData: bookingData,
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.teal,
// //                           padding: const EdgeInsets.symmetric(vertical: 16),
// //                         ),
// //                         child: const Text(
// //                           'View Full Booking Details',
// //                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mobile_service_hub/screen/Bookingform.dart';
// import '../widget/bottom_nav_bar.dart';
// import '../models/notification_model.dart';
// import '../widget/notification_widgets/notification_item.dart';
// import '../widget/notification_widgets/provider_details_card.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({Key? key}) : super(key: key);

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   List<NotificationModel> notifications = [];

//   @override
//   void initState() {
//     super.initState();
//     _listenToNotifications();
//   }

//   void _listenToNotifications() {
//     FirebaseFirestore.instance
//         .collection('notifications')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       setState(() {
//         notifications = snapshot.docs.map((doc) {
//           final data = doc.data();
//           final timestamp = data['timestamp'] as Timestamp?;
//           final timeAgo = _getTimeAgo(timestamp?.toDate());

//           return NotificationModel(
//             id: doc.id,
//             title: data['type'] == 'provider_signup'
//                 ? 'New Provider Request'
//                 : 'Notification',
//             message: '${data['providerName'] ?? 'A provider'} has signed up for approval',
//             time: timeAgo,
//             isRead: data['status'] == 'read',
//             type: NotificationType.provider,
//             providerData: {
//               'name': data['providerName'] ?? '',
//               'providerId': data['providerId'] ?? '',
//               'email': '',
//               'phone': '',
//               'specialty': '',
//               'experience': '',
//               'location': '',
//               'rating': '',
//               'availability': '',
//             },
//           );
//         }).toList();
//       });
//     });
//   }

//   String _getTimeAgo(DateTime? dateTime) {
//     if (dateTime == null) return 'some time ago';
//     final now = DateTime.now();
//     final diff = now.difference(dateTime);

//     if (diff.inSeconds < 60) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
//     if (diff.inHours < 24) return '${diff.inHours} hours ago';
//     return '${diff.inDays} days ago';
//   }

//   void markAsRead(String id) async {
//     await FirebaseFirestore.instance.collection('notifications').doc(id).update({
//       'status': 'read',
//     });
//   }

//   void markAllAsRead() async {
//     final batch = FirebaseFirestore.instance.batch();
//     for (final notification in notifications) {
//       final docRef =
//           FirebaseFirestore.instance.collection('notifications').doc(notification.id);
//       batch.update(docRef, {'status': 'read'});
//     }
//     await batch.commit();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('All notifications marked as read')),
//     );
//   }

//   void deleteNotification(String id) async {
//     await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Notification deleted')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Notifications',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => markAllAsRead(),
//             child: const Text(
//               'Mark all as read',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: notifications.isEmpty
//           ? _buildEmptyState(context)
//           : ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 return NotificationItemWidget(
//                   notification: notification,
//                   onTap: (id) {
//                     markAsRead(id);
//                     if (notification.type == NotificationType.provider &&
//                         notification.providerData != null) {
//                       _showProviderDetailsPopup(
//                         context,
//                         notification.providerData!,
//                         notification.id,
//                       );
//                     }
//                   },
//                   onDelete: deleteNotification,
//                 );
//               },
//             ),
//       bottomNavigationBar: const BottomNavBar(currentIndex: 2),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           const Text(
//             'No Notifications',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'You don\'t have any notifications at the moment',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showProviderDetailsPopup(
//     BuildContext context,
//     Map<String, String> providerData,
//     String notificationId,
//   ) {
//     final providerId = providerData['providerId'];

//     if (providerId == null || providerId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Provider ID is missing')),
//       );
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Provider Details',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ProviderDetailsCard(providerData: providerData),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//   final confirmed = await showDialog<bool>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Confirm Rejection'),
//       content: const Text('Are you sure you want to reject this service provider?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(false),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           onPressed: () => Navigator.of(context).pop(true),
//           child: const Text('Reject'),
//         ),
//       ],
//     ),
//   );

//   if (confirmed == true) {
//     Navigator.of(context).pop(); 
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(providerId)
//         .update({'status': 'rejected'});
//     await FirebaseFirestore.instance
//         .collection('notifications')
//         .doc(notificationId)
//         .update({'status': 'read'});
//   }
// },

//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red.shade400,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Reject',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         Navigator.pop(context);
//                         await FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(providerId)
//                             .update({'status': 'approved'});
//                         await FirebaseFirestore.instance
//                             .collection('notifications')
//                             .doc(notificationId)
//                             .update({'status': 'read'});
                    
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Accept',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }




