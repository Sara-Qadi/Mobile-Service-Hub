import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingconfirmation.dart';
import '../models/notification_model.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/notification_widgets/notification_item.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
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
        .where('clientId', isEqualTo: currentUser!.uid)
              .where('type', isEqualTo: 'booking')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        print('Notification for clientId ${doc['clientId']}, providerId ${doc['providerId']}');
      }
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
      batch.update(
        FirebaseFirestore.instance.collection('notifications').doc(notification.id),
        {'isRead': true},
      );
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

                    if (notification.type == NotificationType.booking && notification.bookingData != null) {
                      // Show confirmation snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking is confirmed!'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      final booking = notification.bookingData!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingConfirmation(
                            name: booking['name'] ?? '',
                            location: booking['location'] ?? '',
                            time: booking['time'] ?? '',
                            date: booking['date'] ?? '',
                            service: booking['service'] ?? '',
                            provider: booking['provider'] ?? '',
                            serviceId: booking['serviceId'] ?? '',
                          ),
                        ),
                      );
                    }
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
          const Text('No Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any notifications at the moment',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
