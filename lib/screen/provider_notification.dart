
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/views/client_view.dart';
import 'package:mobile_service_hub/views/view_ratings_page.dart';

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
      print("Got notifications: ${updatedNotifications.length}");
      for (var notification in updatedNotifications) {
        print("Notification: ${notification.title} - Time: ${notification.createdAt ?? notification.time}");
      }
      setState(() {
        notifications = updatedNotifications;
        isLoading = false;
      });
    }, onError: (e) {
      print("Notification stream error: $e");
      setState(() {
        isLoading = false;
      });
    });
  }

  void _onAccept(NotificationModel notification) async {
    if (notification.bookingId == null || notification.clientData == null) return;

    _showLoadingDialog('Processing request...');

    try {
      await _notificationService.updateBookingStatus(notification.bookingId!, 'pending_confirmation');
      await _notificationService.markAsRead(notification.id);

      final client = notification.clientData!;
      final currentUserId = _notificationService.currentUserId ?? '';
      
      await _notificationService.addToPendingBookings({
        'name': client['name'] ?? '',
        'service': client['service'] ?? '',
        'provider': currentUserId,
        'location': client['location'] ?? '',
        'date': client['date'] ?? '',
        'time': client['time'] ?? '',
        'serviceId': client['serviceId'] ?? '',
        'clientId': notification.clientId ?? '',
        'bookingId': notification.bookingId,
        'status': 'pending_confirmation',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Map<String, dynamic> bookingDataForNotification = Map<String, dynamic>.from(client);
      bookingDataForNotification['provider'] = currentUserId;
      bookingDataForNotification['providerID'] = currentUserId;
      bookingDataForNotification['status'] = 'pending_confirmation';
      
      print('Sending notification with booking data: $bookingDataForNotification');

      final String clientId = notification.clientId ?? '';
      if (clientId.isNotEmpty) {
        await _notificationService.sendNotificationToClient(
          clientId: clientId,
          title: 'Booking Request Accepted',
          message: 'Your booking request has been accepted. Please confirm to finalize.',
          bookingData: bookingDataForNotification,
          type: 'booking_pending_confirmation'
        );
      }

      Navigator.of(context).pop();
      
      _showWaitingForConfirmationPopup();
      
    } catch (e) {
      Navigator.of(context).pop();
      
      _showErrorSnackBar('Failed to process booking: $e');
    }
  }

  void _onReject(NotificationModel notification) async {
    if (notification.bookingId == null || notification.clientData == null) return;
    
    _showLoadingDialog('Rejecting request...');
    
    try {
      await _notificationService.updateBookingStatus(notification.bookingId!, 'rejected');
      await _notificationService.markAsRead(notification.id);
      
      final String clientId = notification.clientId ?? '';
      if (clientId.isNotEmpty) {
        Map<String, dynamic> bookingDataForNotification = Map<String, dynamic>.from(notification.clientData!);
        bookingDataForNotification['provider'] = _notificationService.currentUserId ?? '';
        bookingDataForNotification['providerID'] = _notificationService.currentUserId ?? '';
        
        await _notificationService.sendNotificationToClient(
          clientId: clientId,
          title: 'Booking Request Rejected',
          message: 'Your booking request has been rejected',
          bookingData: bookingDataForNotification,
          type: 'booking_rejected'
        );
      }
      
      Navigator.of(context).pop();
      
      _showSuccessSnackBar('Booking request rejected successfully');
      
    } catch (e) {
      Navigator.of(context).pop();
      
      _showErrorSnackBar('Failed to reject booking: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWaitingForConfirmationPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.schedule, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Waiting for Confirmation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Colors.grey[600]),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your acceptance has been sent to the customer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'Please wait for customer confirmation before the booking is finalized.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDetailsPopup(BuildContext context, NotificationModel notification) {
    final ratingData = notification.ratingData ?? {};
    final rating = double.tryParse(ratingData['rating'] ?? '0') ?? 0.0;
    final clientName = ratingData['clientName'] ?? 'Anonymous';
    final serviceName = ratingData['serviceName'] ?? 'Service';
    final comment = ratingData['comment'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.star, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'New Rating Received',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.build, 'Service', serviceName, Colors.blue[600]!),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.person, 'Client', clientName, Colors.green[600]!),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Rating: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : (index < rating && rating % 1 != 0)
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '($rating/5)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.comment, color: Colors.purple[600], size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Comment:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                          MaterialPageRoute(
                            builder: (context) => ViewRatingsPage(
                              service: {
                                'id': notification.ratingData?['serviceId'] ?? notification.bookingId ?? '',
                                'name': notification.ratingData?['serviceName'] ?? 'Service',
                                'serviceId': notification.ratingData?['serviceId'] ?? notification.bookingId ?? '',
                                'serviceName': notification.ratingData?['serviceName'] ?? 'Service',
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View All Ratings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
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
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person_add, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Client Request',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClientDetailsCard(clientData: clientData),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final confirm = await _showRejectConfirmDialog();
                        if (confirm == true) {
                          _onReject(notification);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onAccept(notification);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showRejectConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Confirm Rejection",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to reject this booking request? This action cannot be undone.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Reject",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
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
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      isLoading = true;
                    });
                    _listenToNotifications();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                          else if (notification.type == NotificationType.rating && notification.ratingData != null) {
                            _showRatingDetailsPopup(context, notification);
                          }
                          else if (notification.type == NotificationType.bookingConfirmed) {
                            _showSuccessSnackBar('Booking confirmed! Navigating to client table...');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EnhancedProviderClientsTableView()),
                            );
                          }
                          else if (notification.type == NotificationType.bookingCancelled) {
                            _showErrorSnackBar('Booking was cancelled by customer');
                          }
                        },
                        onDelete: (id) async {
                          await _notificationService.deleteNotification(id);
                          _showSuccessSnackBar('Notification deleted');
                        },
                      );
                    },
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications at the moment',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}