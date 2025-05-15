
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/screen/Bookingconfirmation.dart';

import '../models/notification_model.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/notification_widgets/notification_item.dart';
import '../widget/notification_widgets/client_details_card.dart';
class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderNotificationsScreen> createState() => _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState extends State<ProviderNotificationsScreen> {
List<NotificationModel> notifications = [];
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _listenToNotifications();
    }
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('providerId', isEqualTo: currentUser!.uid)
.orderBy('time', descending: true)

        .snapshots()
        .listen((snapshot) {
      setState(() {
        notifications = snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
      });
    });
  }

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    for (var notification in notifications) {
      batch.update(FirebaseFirestore.instance.collection('notifications').doc(notification.id), {'isRead': true});
    }
    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  Future<void> deleteNotification(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'status': status});
  }

void _onAccept(NotificationModel notification) async {
  if (notification.bookingId == null || notification.clientData == null) return;

  await _updateBookingStatus(notification.bookingId!, 'accepted');
  await markAsRead(notification.id);

  // Add to bookingnow table for provider
  try {
    final client = notification.clientData!;
    await FirebaseFirestore.instance.collection('bookingnow').add({
      'name': client['name'] ?? '',
      'service': client['service'] ?? '',
      'provider': currentUser?.uid ?? '',
      'location': client['location'] ?? '',
      'date': client['date'] ?? '',
      'time': client['time'] ?? '',
      'serviceId': client['serviceId'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add notification for the client about booking confirmation
    await FirebaseFirestore.instance.collection('notifications').add({
      'clientId': client['clientId'],   // Make sure this exists in clientData
      'providerId': currentUser?.uid ?? '',
      'type': 'booking',  // or NotificationType.booking if you save enums as strings
      'bookingId': notification.bookingId,
      'bookingData': {
        'name': client['name'] ?? '',
        'service': client['service'] ?? '',
        'provider': currentUser?.uid ?? '',
        'location': client['location'] ?? '',
        'date': client['date'] ?? '',
        'time': client['time'] ?? '',
        'serviceId': client['serviceId'] ?? '',
      },
      'isRead': false,
      'time': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request accepted and added to schedule')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add to booking or notification: $e')),
    );
  }
}



void _onReject(NotificationModel notification) async {
  if (notification.bookingId == null) return;
  await _updateBookingStatus(notification.bookingId!, 'rejected');
  await markAsRead(notification.id);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Booking request rejected')),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItemWidget(
                  notification: notification,
                  onTap: (id) async {
                    await markAsRead(id);

                    if (notification.type == NotificationType.clientRequest && notification.clientData != null) {
                      _showClientRequestDetailsPopup(context, notification);
                    }
                    // You can add more logic here for other notification types
                  },
                  onDelete: deleteNotification,
                );
              },
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any notifications at the moment',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showClientRequestDetailsPopup(BuildContext context, NotificationModel notification) {
    final clientData = notification.clientData ?? {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Client Request',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClientDetailsCard(clientData: clientData),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Rejection"),
                              content: const Text("Are you sure you want to reject this booking request?"),
                              actions: [
                                TextButton(
                                  child: const Text("No"),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: const Text("Yes"),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          _onReject(notification);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onAccept(notification);
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}