import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingform.dart';
import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
import '../main.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<NotificationItem> notifications = [
      NotificationItem(
        title: 'New Provider Available',
        message: 'Dr. Sarah Johnson is now available for appointments',
        time: '10 minutes ago',
        isRead: false,
        type: NotificationType.provider,
        providerData: {
          'name': 'Dr. Sarah Johnson',
          'specialty': 'Cardiologist',
          'experience': '15 years',
          'location': 'Main Clinic, Floor 2',
          'rating': '4.8',
          'availability': 'Mon-Fri, 9AM-5PM',
        },
      ),
   NotificationItem(
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
      NotificationItem(
        title: 'Appointment Reminder',
        message: 'Your appointment is scheduled in 24 hours',
        time: '3 hours ago',
        isRead: true,
        type: NotificationType.reminder,
      ),
      NotificationItem(
        title: 'New Provider Added',
        message: 'Dr. Michael Smith is now available for consultations',
        time: '2 days ago',
        isRead: true,
        type: NotificationType.provider,
        providerData: {
          'name': 'Dr. Michael Smith',
          'specialty': 'Dermatologist',
          'experience': '8 years',
          'location': 'Downtown Clinic',
          'rating': '4.6',
          'availability': 'Wed-Sun, 10AM-6PM',
        },
      ),
      NotificationItem(
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
      NotificationItem(
        title: 'Special Offer',
        message: 'Get 20% off on your next booking',
        time: '2 days ago',
        isRead: true,
        type: NotificationType.promotion,
      ),
      NotificationItem(
        title: 'New Service Available',
        message: 'Check out our new services available at your location',
        time: '3 days ago',
        isRead: true,
        type: NotificationType.info,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: Text(
              'Mark all as read',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
                return _buildNotificationItem(context, notifications[index]);
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

  Widget _buildNotificationItem(BuildContext context, NotificationItem notification) {
    IconData notificationIcon;
    Color iconBackgroundColor;

    switch (notification.type) {
      case NotificationType.provider:
        notificationIcon = Icons.person;
        iconBackgroundColor = Colors.teal;
        break;
      case NotificationType.booking:
        notificationIcon = Icons.calendar_today;
        iconBackgroundColor = Colors.blue;
        break;
      case NotificationType.reminder:
        notificationIcon = Icons.alarm;
        iconBackgroundColor = Colors.orange;
        break;
      case NotificationType.promotion:
        notificationIcon = Icons.local_offer;
        iconBackgroundColor = Colors.purple;
        break;
      case NotificationType.info:
      default:
        notificationIcon = Icons.info_outline;
        iconBackgroundColor = Colors.blue;
        break;
    }

    return InkWell(
      onTap: () {
        if (notification.type == NotificationType.provider && notification.providerData != null) {
          _showProviderDetailsPopup(context, notification.providerData!);
        } else {
          _showNotificationDetail(context, notification);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.teal.withOpacity(0.05),
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(notificationIcon, color: iconBackgroundColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification.time,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!notification.isRead)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
              _buildProviderDetailsCard(context, providerData),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
              onPressed: () {
  Navigator.pop(context); 
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BookingForm()),
  );
},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Book Appointment',
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

  void _showNotificationDetail(BuildContext context, NotificationItem notification) {
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
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
                _buildBookingDetailsCard(context, notification.bookingData!),
              const Spacer(),
              if (notification.type == NotificationType.booking)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                onPressed: () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BookingTimesTableView(bookingData: {},)),
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

  Widget _buildProviderDetailsCard(BuildContext context, Map<String, String> providerData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', providerData['name'] ?? ''),
            _buildInfoRow('Specialty', providerData['specialty'] ?? ''),
            _buildInfoRow('Experience', providerData['experience'] ?? ''),
            _buildInfoRow('Location', providerData['location'] ?? ''),
            _buildInfoRow('Rating', providerData['rating'] ?? ''),
            _buildInfoRow('Availability', providerData['availability'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context, Map<String, String> bookingData) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', bookingData['name'] ?? ''),
            _buildInfoRow('Service', bookingData['service'] ?? ''),
            _buildInfoRow('Provider', bookingData['provider'] ?? ''),
            _buildInfoRow('Location', bookingData['location'] ?? ''),
            _buildInfoRow('Date', bookingData['date'] ?? ''),
            _buildInfoRow('Time', bookingData['time'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;
  final Map<String, String>? bookingData;
  final Map<String, String>? providerData;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
    this.bookingData,
    this.providerData,
  });
}

enum NotificationType {
  booking,
  reminder,
  promotion,
  info,
  provider,
}
