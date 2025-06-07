import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widget/bottom_nav_bar.dart';
import '../models/notification_model.dart';
import '../widget/notification_widgets/notification_item.dart';
import '../widget/notification_widgets/provider_details_card.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
 List<NotificationModel> notifications = [];
 void _showReportDetailsDialog(BuildContext context, NotificationModel notification) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Service Report'),
      content: Text(notification.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        )
      ],
    ),
  );
}


  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        notifications = snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = data['timestamp'] as Timestamp?;
          final timeAgo = _getTimeAgo(timestamp?.toDate());

return NotificationModel(
  id: doc.id,
  title: data['type'] == 'provider_signup'
      ? 'New Provider Request'
      : data['type'] == 'service_report'
          ? 'Service Reported'
          : 'Notification',
  message: data['type'] == 'provider_signup'
      ? '${data['providerName'] ?? 'A provider'} has signed up for approval'
      : data['type'] == 'service_report'
          ? 'Service "${data['serviceName'] ?? 'Unknown'}" was reported for ${data['reason'] ?? 'unknown reason'}'
          : '',
  time: timeAgo,
  isRead: data['status'] == 'read',
  type: data['type'] == 'provider_signup'
      ? NotificationType.provider
      : NotificationType.service_report,
  providerData: data['type'] == 'provider_signup'
      ? {
          'name': data['providerName'] ?? '',
          'providerId': data['providerId'] ?? '',
          'email': '',
          'phone': '',
          'specialty': '',
          'experience': '',
          'location': '',
          'rating': '',
          'availability': '',
        }
      : null,
);

        }).toList();
      });
    });
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'some time ago';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  void markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update({
      'status': 'read',
    });
  }

  void markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final notification in notifications) {
      final docRef =
          FirebaseFirestore.instance.collection('notifications').doc(notification.id);
      batch.update(docRef, {'status': 'read'});
    }
    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void deleteNotification(String id) async {
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
            onPressed: () => markAllAsRead(),
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
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
            onTap: (id) {
  markAsRead(id);
  if (notification.type == NotificationType.provider &&
      notification.providerData != null) {
    _showProviderDetailsPopup(
      context,
      notification.providerData!,
      notification.id,
    );
  } else if (notification.type == NotificationType.service_report) {
    _showReportDetailsDialog(context, notification);
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

  void _showProviderDetailsPopup(
    BuildContext context,
    Map<String, String> providerData,
    String notificationId,
  ) {
    final providerId = providerData['providerId'];

    if (providerId == null || providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider ID is missing')),
      );
      return;
    }

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
                    'Provider Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProviderDetailsCard(providerData: providerData),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Rejection'),
      content: const Text('Are you sure you want to reject this service provider?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Reject'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    Navigator.of(context).pop(); 
    await FirebaseFirestore.instance
        .collection('users')
        .doc(providerId)
        .update({'status': 'rejected'});
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'status': 'read'});
  }
},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(providerId)
                            .update({'status': 'approved'});
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(notificationId)
                            .update({'status': 'read'});
                    
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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