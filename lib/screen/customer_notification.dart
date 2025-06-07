import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mobile_service_hub/views/booking_confirmation_view.dart';
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

  static Map<String, String> _providerNames = {};

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
    }, onError: (e) {
      print("Customer notification stream error: $e");
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<String> _getProviderName(String providerId) async {
    print('Getting provider name for ID: $providerId');
    
    if (_providerNames.containsKey(providerId)) {
      print('Found in cache: ${_providerNames[providerId]}');
      return _providerNames[providerId]!;
    }

    try {
      print('Fetching from Firestore...');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        print('User document data: $data');
        
        String fullName = _extractFullName(data);
        print('Extracted full name: $fullName');
        
        _providerNames[providerId] = fullName;
        return fullName;
      } else {
        print('User document does not exist for ID: $providerId');
      }

      _providerNames[providerId] = providerId;
      return providerId;
    } catch (e) {
      print('Error fetching provider name for ID $providerId: $e');
      _providerNames[providerId] = providerId;
      return providerId;
    }
  }

  String _extractFullName(Map<String, dynamic>? data) {
    if (data == null) {
      print('Data is null');
      return '';
    }
    
    String firstName = data['firstName']?.toString() ?? '';
    String lastName = data['lastName']?.toString() ?? '';
    String nameField = data['name']?.toString() ?? '';
    
    print('firstName: $firstName, lastName: $lastName, name: $nameField');
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (nameField.isNotEmpty) {
      return nameField;
    } else {
      return '';
    }
  }

  Future<void> _confirmBooking(NotificationModel notification) async {
    try {
      final booking = notification.bookingData!;
      final providerId = booking['providerID']?.toString() ?? booking['provider']?.toString() ?? '';
      
      print('Confirming booking with data: $booking');
      print('Provider ID: $providerId');
      
      await FirebaseFirestore.instance.collection('bookingnow').add({
        'name': booking['name'] ?? '',
        'service': booking['service'] ?? '',
        'provider': providerId,
        'location': booking['location'] ?? '',
        'date': booking['date'] ?? '',
        'time': booking['time'] ?? '',
        'serviceId': booking['serviceId'] ?? '',
        'clientId': _notificationService.currentUserId ?? '',
        'bookingId': booking['bookingId'] ?? '',
        'status': 'confirmed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _notificationService.removePendingBooking(
        _notificationService.currentUserId ?? '',
        providerId
      );

      if (providerId.isNotEmpty) {
        await _notificationService.sendNotificationToProvider(
          providerId: providerId,
          title: 'Booking Confirmed',
          message: 'Customer has confirmed the booking request',
          bookingData: Map<String, dynamic>.from(booking),
          type: 'booking_confirmed',
          bookingId: booking['bookingId']?.toString()
        );
      }

      await _notificationService.markAsRead(notification.id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationView(
            name: booking['name']?.toString() ?? '',
            location: booking['location']?.toString() ?? '',
            time: booking['time']?.toString() ?? '',
            date: booking['date']?.toString() ?? '',
            service: booking['service']?.toString() ?? '',
            provider: providerId,
            serviceId: booking['serviceId']?.toString() ?? '',
          ),
        ),
      );

    } catch (e) {
      print('Error confirming booking: $e');
      _showErrorDialog('Failed to confirm booking. Please try again.');
    }
  }

  Future<void> _cancelBooking(NotificationModel notification) async {
    try {
      final booking = notification.bookingData!;
      final providerId = booking['providerID']?.toString() ?? booking['provider']?.toString() ?? '';
      
      print('Cancelling booking with data: $booking');
      print('Provider ID: $providerId');
      
      await _notificationService.removePendingBooking(
        _notificationService.currentUserId ?? '',
        providerId
      );

      if (providerId.isNotEmpty) {
        await _notificationService.sendNotificationToProvider(
          providerId: providerId,
          title: 'Booking Cancelled',
          message: 'Customer has cancelled the booking request',
          bookingData: Map<String, dynamic>.from(booking),
          type: 'booking_cancelled',
          bookingId: booking['bookingId']?.toString()
        );
      }

      await _notificationService.markAsRead(notification.id);

    } catch (e) {
      print('Error cancelling booking: $e');
      _showErrorDialog('Failed to cancel booking. Please try again.');
    }
  }

  void _showPendingBookingDialog(NotificationModel notification) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final booking = notification.bookingData ?? {};
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(24, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: const Color(0xFF008080),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Confirm Your Booking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.room_service, 'Service', booking['service'] ?? ''),
                            SizedBox(height: 12),
                            _buildDetailRow(Icons.calendar_today, 'Date', booking['date'] ?? ''),
                            SizedBox(height: 12),
                            _buildDetailRow(Icons.access_time, 'Time', booking['time'] ?? ''),
                            SizedBox(height: 12),
                            _buildDetailRow(Icons.location_on, 'Location', booking['location'] ?? ''),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF008080).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline, 
                              color: const Color(0xFF008080), 
                              size: 20
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'The provider has accepted your request. Please confirm to finalize your booking.',
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: const Color(0xFF008080),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                        onPressed: () {
                            Navigator.of(context).pop();
                            _showCancelConfirmationDialog(notification);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _confirmBooking(notification);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008080),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
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
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF008080)),
        SizedBox(width: 10),
        Text(
          '$label: ', 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Expanded(
          child: Text(
            value, 
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmationDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Cancel Booking?', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel this booking request? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Keep Booking', 
                style: TextStyle(fontWeight: FontWeight.w600)
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(notification);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Yes, Cancel', 
                style: TextStyle(fontWeight: FontWeight.w600)
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                foregroundColor: Colors.white,
              ),
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
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
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                await _notificationService.markAllAsRead(notifications);
                _showSuccessSnackBar('All notifications marked as read');
              },
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Mark all read',
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

                        if (notification.type == NotificationType.bookingPendingConfirmation && 
                            notification.bookingData != null) {
                          _showPendingBookingDialog(notification);
                        }
                        else if (notification.type == NotificationType.booking && 
                                 notification.bookingData != null) {
                          
                          final booking = notification.bookingData!;
                          
                          String providerId = '';
                          
                          if (booking.containsKey('providerID') && booking['providerID'] != null && booking['providerID'].toString().isNotEmpty) {
                            providerId = booking['providerID'].toString();
                          } else if (booking.containsKey('provider') && booking['provider'] != null && booking['provider'].toString().isNotEmpty) {
                            providerId = booking['provider'].toString();
                          } else if (booking.containsKey('receiver') && booking['receiver'] != null && booking['receiver'].toString().isNotEmpty) {
                            providerId = booking['receiver'].toString();
                          }

                          print('Provider ID found: $providerId');
                          print('Booking data: $booking');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingConfirmationView(
                                name: booking['name']?.toString() ?? '',
                                location: booking['location']?.toString() ?? '',
                                time: booking['time']?.toString() ?? '',
                                date: booking['date']?.toString() ?? '',
                                service: booking['service']?.toString() ?? '',
                                provider: providerId,
                                serviceId: booking['serviceId']?.toString() ?? '',
                              ),
                            ),
                          );
                        }
                        else if (notification.type == NotificationType.booking_rejected) {
                          print('Booking rejection notification tapped');
                        }
                        else if (notification.type == NotificationType.approval) {
                          print('Approval notification tapped');
                        }
                        else if (notification.type == NotificationType.info) {
                          print('Info notification tapped: ${notification.message}');
                        }
                        else if (notification.type == NotificationType.bookingCompleted) {
                          print('Booking completed notification tapped');
                        }
                        else if (notification.type == NotificationType.bookingCancelled) {
                          print('Booking cancelled notification tapped');
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