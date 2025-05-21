import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
import 'package:mobile_service_hub/screen/ProviderClientsTableView.dart';
import 'package:mobile_service_hub/screen/admin_notification.dart';
import 'package:mobile_service_hub/screen/customer_notification.dart';
import 'package:mobile_service_hub/screen/provider_notification.dart';
import 'package:mobile_service_hub/screens/service_p_profile.dart';
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
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }
  Future<void> _fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _userRole = doc.data()?['role'];
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 60); // Placeholder while loading
    }
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
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
final List<Map<String, dynamic>> servicesList = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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
                  MaterialPageRoute(builder: (context) => BookingTimesTableView(bookingData: {},)),
                );
              }
              break;
            case 2 :
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final role = userDoc.data()?['role'];
    if (role == 'Service Provider') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProviderNotificationsScreen()),
      );
    } else if (role == 'Customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerNotificationsScreen()),
      );
    } else if (role == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
      );
    }
  }
  break;
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServiceProviderProfile()),
              );
              break;
          }
        }
      },
    );
  }
}


