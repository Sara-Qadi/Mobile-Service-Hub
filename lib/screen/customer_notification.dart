import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingconfirmation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/notification_widgets/notification_item.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  List<NotificationModel> notifications = [];
  final NotificationService _notificationService = NotificationService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationService.getClientNotifications().listen((updatedNotifications) {
      if (mounted) {
        setState(() {
          notifications = updatedNotifications;
          isLoading = false;
        });
      }
    });
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

                        if (notification.type == NotificationType.booking && notification.bookingData != null) {
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
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
}