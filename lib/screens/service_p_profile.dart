import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/reset_password.dart';

class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => ServiceProviderProfileState();
}

class ServiceProviderProfileState extends State<ServiceProviderProfile> {
  bool _notificationsEnabled = false;
    String _username = "Mohammad_5";
String _phoneNumber = "0597259604";

  void _confirmAction({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
  
void _editUsername() {
  final controller = TextEditingController(text: _username);
  String? errorText;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new username",
            errorText: errorText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newUsername = controller.text.trim();
              if (newUsername.isEmpty) {
                setState(() {
                  errorText = "Username cannot be empty";
                });
              } else {
                this.setState(() {
                  _username = newUsername;
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    ),
  );
}

  void _editPhoneNumber() {
  final controller = TextEditingController(text: _phoneNumber);
  String? errorText;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Edit Phone Number"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Enter new phone number",
            errorText: errorText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newNumber = controller.text.trim();
              if (newNumber.isEmpty) {
                setState(() {
                  errorText = "Phone number cannot be empty";
                });
              } else if (newNumber.length < 10 || !RegExp(r'^\d+$').hasMatch(newNumber)) {
                setState(() {
                  errorText = "Enter a valid 10-digit number";
                });
              } else {
                this.setState(() {
                  _phoneNumber = newNumber;
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
     Center(
  child: Stack(
    alignment: Alignment.bottomRight,
    children: [
      const CircleAvatar(
        radius: 70,
        backgroundImage: AssetImage('assets/images/person1.jpg'),
      ),
      Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black87,
        ),
        child: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white, size: 22),
          onPressed: () {
            // todo
          },
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 30),

 ListTile(
              leading: const Icon(Icons.person, size: 28),
              title: const Text("Username", style: TextStyle(fontSize: 18)),
              trailing: InkWell(
                onTap: _editUsername,
                child: Text(
                  _username,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
 ListTile(
              leading: const Icon(Icons.person, size: 28),
              title: const Text("Number", style: TextStyle(fontSize: 18)),
              trailing: InkWell(
                onTap: _editPhoneNumber,
                child: Text(
                  _phoneNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),


            // Notifications Toggle
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.notifications, size: 28),
              title: const Text("Notifications", style: TextStyle(fontSize: 18)),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
                 ListTile(
              leading: const Icon(Icons.keyboard_arrow_right, size: 30, color: Colors.black,),
              title: const Text("MyServices", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              // onTap: () {
              //        Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => ResetPasswordScreen(contact: '',),));
            //  },
            ),
            const SizedBox(height: 50),

        
            ListTile(
              leading: const Icon(Icons.lock_reset, size: 28),
              title: const Text("Change Password", style: TextStyle(fontSize: 18)),
              onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordScreen(contact: '',),));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, size: 28, color: Colors.red),
              title: const Text("Delete Account",
                  style: TextStyle(color: Colors.red, fontSize: 18)),
              onTap: () {
                _confirmAction(
                  title: "Delete Account",
                  content: "Are you sure you want to delete your account?",
                  onConfirm: () {
                    // todo
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, size: 28),
              title: const Text("Log out", style: TextStyle(fontSize: 18)),
              onTap: () {
                _confirmAction(
                  title: "Log Out",
                  content: "Are you sure you want to log out?",
                  onConfirm: () {
                        Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),));
                  },
                );
              },
            ),
          ],
        ),
       ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 3,
      //   selectedItemColor: Colors.teal,
      //   unselectedItemColor: Colors.grey,
      //   selectedFontSize: 14,
      //   unselectedFontSize: 12,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Booking"),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
      //     BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
      //   ],
      // ),
    );
  }
}
