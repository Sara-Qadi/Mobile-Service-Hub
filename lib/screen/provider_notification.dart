
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/screen/ProviderClientsTableView.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationService.getProviderNotifications().listen((updatedNotifications) {
      if (mounted) {
        setState(() {
          notifications = updatedNotifications;
          isLoading = false;
        });
      }
    });
  }

  void _onAccept(NotificationModel notification) async {
    if (notification.bookingId == null || notification.clientData == null) return;

    await _notificationService.updateBookingStatus(notification.bookingId!, 'accepted');
    await _notificationService.markAsRead(notification.id);

    try {
      final client = notification.clientData!;
      await FirebaseFirestore.instance.collection('bookingnow').add({
        'name': client['name'] ?? '',
        'service': client['service'] ?? '',
        'provider': _notificationService.currentUserId ?? '',
        'location': client['location'] ?? '',
        'date': client['date'] ?? '',
        'time': client['time'] ?? '',
        'serviceId': client['serviceId'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final String clientId = notification.clientId ?? '';
      if (clientId.isNotEmpty) {
        await _notificationService.sendNotificationToClient(
          clientId: clientId,
          message: 'Your booking request has been accepted',
          bookingData: Map<String, dynamic>.from(client),
          type: 'booking'
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request accepted and added to schedule')),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnhancedProviderClientsTableView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to booking table: $e')),
      );
    }
  }

  void _onReject(NotificationModel notification) async {
    if (notification.bookingId == null || notification.clientData == null) return;
    
    await _notificationService.updateBookingStatus(notification.bookingId!, 'rejected');
    await _notificationService.markAsRead(notification.id);
    
    final String clientId = notification.clientId ?? '';
    if (clientId.isNotEmpty) {
      await _notificationService.sendNotificationToClient(
        clientId: clientId,
        message: 'Your booking request has been rejected',
        bookingData: Map<String, dynamic>.from(notification.clientData!),
        type: 'booking_rejected'
      );
    }
    
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
            onPressed: () async {
              await _notificationService.markAllAsRead(notifications);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationItemWidget(
                      notification: notification,
                      onTap: (id) async {
                        await _notificationService.markAsRead(id);

                        if (notification.type == NotificationType.clientRequest && notification.clientData != null) {
                          _showClientRequestDetailsPopup(context, notification);
                        }
                      },
                      onDelete: (id) async {
                        await _notificationService.deleteNotification(id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification deleted')),
                        );
                      },
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