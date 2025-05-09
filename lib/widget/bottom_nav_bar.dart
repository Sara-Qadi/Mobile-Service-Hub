import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
import 'package:mobile_service_hub/screen/Bookingtimestableview.dart';
import 'package:mobile_service_hub/screen/NotificationsPage.dart';
import 'package:mobile_service_hub/screens/service_p_profile.dart';
import '/views/services_page.dart';
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
      onTap: (index) {
        if (index != currentIndex) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  ServicesPage()),
              );
              break;
             case 1:
             
              Map<String, String> bookingData = {
                'name': 'John Doe',
                'time': '10:30 AM',
                'service': 'Oil Change',
                'date': '2025-05-10',
              };
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingTimesTableView(bookingData: bookingData),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceProviderProfile(),
                ),
              );
              break;
          }
        }
      },
    );
  }
}