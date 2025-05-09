import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingform.dart';
import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
import '../main.dart';
import '../widget/bottom_nav_bar.dart';
import '../models/notification_model.dart';
import '../widget/notification_widgets/notification_item.dart';
import '../widget/notification_widgets/provider_details_card.dart';
import '../widget/notification_widgets/client_details_card.dart';
import '../widget/booking_widgets/booking_details_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> notifications;

  @override
  void initState() {
    super.initState();
    
    notifications = [
      NotificationModel(
        id: '1',
        title: 'New Provider Available',
        message: 'Sarah yaseen is now available for appointments',
        time: '10 minutes ago',
        isRead: false,
        type: NotificationType.provider,
        providerData: {
          'name': ' Sarah yaseen',
          'email': 'sarah.yaseen@example.com',
          'phone': '+1 555-123-4567',
          'specialty': 'Cardiologist',
          'experience': '15 years',
          'location': 'Main Clinic, Floor 2',
          'rating': '4.8',
          'availability': 'Mon-Fri, 9AM-5PM',
        },
      ),
      NotificationModel(
        id: '2',
        title: 'Booking Confirmed',
        message: 'Your booking with Dr. Sarah has been confirmed for tomorrow at 2:00 PM',
        time: '2 hours ago',
        isRead: false,
        type: NotificationType.booking,
        bookingData: {
          'name': 'User Name',
          'service': 'Consultation',
          'provider': 'Dr. Sarah',
          'location': 'Main Clinic',
          'date': '02/05/2025',
          'time': '2:00 PM',
        },
      ),
      NotificationModel(
        id: '3',
        title: 'Appointment Reminder',
        message: 'Your appointment is scheduled in 24 hours',
        time: '3 hours ago',
        isRead: true,
        type: NotificationType.reminder,
      ),
      NotificationModel(
        id: '4',
        title: 'New Provider Added',
        message: 'Dr. Michael Smith is now available for consultations',
        time: '2 days ago',
        isRead: true,
        type: NotificationType.provider,
        providerData: {
          'name': 'Dr. Michael Smith',
          'email': 'michael.smith@example.com',
          'phone': '+1 555-987-6543',
          'specialty': 'Dermatologist',
          'experience': '8 years',
          'location': 'Downtown Clinic',
          'rating': '4.6',
          'availability': 'Wed-Sun, 10AM-6PM',
        },
      ),
      NotificationModel(
        id: '5',
        title: 'Booking Cancelled',
        message: 'Your booking with Dr. John has been cancelled',
        time: '1 day ago',
        isRead: true,
        type: NotificationType.booking,
        bookingData: {
          'name': 'User Name',
          'service': 'Check-up',
          'provider': 'Dr. John',
          'location': 'Downtown Clinic',
          'date': '28/04/2025',
          'time': '11:30 AM',
        },
      ),
      NotificationModel(
        id: '6',
        title: 'Special Offer',
        message: 'Get 20% off on your next booking',
        time: '2 days ago',
        isRead: true,
        type: NotificationType.promotion,
      ),
      NotificationModel(
        id: '7',
        title: 'New Service Available',
        message: 'Check out our new services available at your location',
        time: '3 days ago',
        isRead: true,
        type: NotificationType.info,
      ),
      NotificationModel(
        id: '8',
        title: 'New Booking Request',
        message: 'John Smith requested a consultation appointment',
        time: '30 minutes ago',
        isRead: false,
        type: NotificationType.clientRequest,
        clientData: {
          'name': 'John Smith',
          'email': 'john.smith@example.com',
          'phone': '+1 555-234-5678',
          'service': 'Consultation',
          'date': '10/05/2025',
          'time': '3:30 PM',
          'notes': 'First-time client seeking consultation',
        },
      ),
    ];
  }

  void markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    });
  }

  void markAllAsRead() {
    setState(() {
      notifications = notifications.map((notification) => notification.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification.id == id);
    });
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
            child: Text(
              'Mark all as read',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return NotificationItemWidget(
                  notification: notifications[index],
                  onTap: (id) {
                    markAsRead(id);
                    
                    final notification = notifications.firstWhere((n) => n.id == id);
                    
                    if (notification.type == NotificationType.provider && notification.providerData != null) {
                      _showProviderDetailsPopup(context, notification.providerData!);
                    } else if (notification.type == NotificationType.clientRequest && notification.clientData != null) {
                      _showClientRequestDetailsPopup(context, notification.clientData!);
                    } else {
                      _showNotificationDetail(context, notification);
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

  void _showProviderDetailsPopup(BuildContext context, Map<String, String> providerData) {
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
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Rejection"),
                              content: const Text("Are you sure you want to reject this provider?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("CANCEL"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Provider rejected')),
                                    );
                                  },
                                  child: const Text("REJECT", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
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
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BookingForm()),
                        );
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

  void _showClientRequestDetailsPopup(BuildContext context, Map<String, String> clientData) {
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
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Rejection"),
                              content: const Text("Are you sure you want to reject this booking request?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("CANCEL"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Booking request rejected')),
                                    );
                                  },
                                  child: const Text("REJECT", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
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
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking request accepted')),
                        );
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

  void _showNotificationDetail(BuildContext context, NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text("Are you sure you want to delete this notification?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      deleteNotification(notification.id);
                                    },
                                    child: const Text("DELETE", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                notification.time,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              if (notification.type == NotificationType.booking && notification.bookingData != null)
                BookingDetailsCard(bookingData: notification.bookingData!),
              const Spacer(),
              if (notification.type == NotificationType.booking)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingTimesTableView(
                            bookingData: notification.bookingData ?? {},
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'View Full Booking Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}