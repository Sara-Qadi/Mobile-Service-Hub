import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
import 'package:mobile_service_hub/screen/ProviderClientsTableView.dart';
import 'package:mobile_service_hub/screen/admin_notification.dart';
import 'package:mobile_service_hub/screen/customer_notification.dart';
import 'package:mobile_service_hub/screen/provider_notification.dart';
import 'package:mobile_service_hub/screens/admin_profile.dart';
import 'package:mobile_service_hub/screens/service_p_profile.dart';
import 'package:mobile_service_hub/screens/customer_profile.dart';
import 'package:mobile_service_hub/views/services_display_page.dart';
import '/views/services_page.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String? _userRole;
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _userRole = doc.data()?['role'];
      _userId = user.uid;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 60);
    }

    Stream<QuerySnapshot> _getNotificationStream() {
      if (_userRole == 'Service Provider') {
        return FirebaseFirestore.instance
            .collection('notifications')
            .where('providerId', isEqualTo: _userId)
            .where('receiver', isEqualTo: 'Provider')
            .where('isRead', isEqualTo: false)
            .snapshots();
      } else if (_userRole == 'Customer') {
        return FirebaseFirestore.instance
            .collection('notifications')
  .where('clientId', isEqualTo: _userId)
     .where('notificationFor', isEqualTo: "client")
.where('isRead', isEqualTo: false)

            .snapshots();
      } else if (_userRole == 'Admin') {
        return FirebaseFirestore.instance
            .collection('notifications')
            .where('status', isEqualTo: "unread")
            .snapshots();
      } else {
        return const Stream.empty();
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getNotificationStream(),
      builder: (context, snapshot) {
        bool hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return BottomNavigationBar(
          currentIndex: widget.currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Notification',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          onTap: (index) async {
            if (index != widget.currentIndex) {
              switch (index) {
                case 0:
                  if (_userRole == 'Service Provider') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ServicesPage()),
                    );
                  } else {
                    final snapshot = await FirebaseFirestore.instance.collection('services').get();
                    final List<Map<String, dynamic>> servicesList = snapshot.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ServicesDisplayPage(services: servicesList)),
                    );
                  }
                  break;

                case 1:
                  if (_userRole == 'Service Provider') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EnhancedProviderClientsTableView()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BookingTimesTableView(bookingData: {})),
                    );
                  }
                  break;

                case 2:
                  if (_userRole == 'Service Provider') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProviderNotificationsScreen()),
                    );
                  } else if (_userRole == 'Customer') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerNotificationsScreen()),
                    );
                  } else if (_userRole == 'Admin') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
                    );
                  }
                  break;

                case 3:
                  if (_userRole == 'Service Provider') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ServiceProviderProfile()),
                    );
                  } else if (_userRole == 'Customer'){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerProfilePage()),
                    );
                    }
                    else{
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminProfilePage()),
                    );
                    }
                  
                  break;
              }
            }
          },
        );
      },
    );
  }
}
