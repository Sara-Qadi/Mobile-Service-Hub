import 'package:flutter/material.dart';
import 'package:mobile_service_hub/main.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/reset_password.dart';
import '../widget/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool _notificationsEnabled = false;
  String _firstName = '';
  String _lastName = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['firstName'] ?? '';
            _lastName = userDoc['lastName'] ?? '';
            _notificationsEnabled = userDoc['notificationsEnabled'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
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
                // TODO: Add image edit logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: iconColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: textColor ?? Colors.black),
      ),
      onTap: onTap,
    );
  }

  Future<String?> _promptPassword() async {
    String password = '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Re-authenticate"),
          content: TextField(
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Enter your password'),
            onChanged: (value) => password = value,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () => Navigator.of(context).pop(password),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccountWithReauth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String? email = user.email;

        if (email == null) {
          throw Exception("User email not found.");
        }

        String? password = await _promptPassword();

        if (password == null || password.isEmpty) return;

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);

        await user.reauthenticateWithCredential(credential);

        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        await user.delete();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>  LoginScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Authentication error")),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deletion failed")),
      );
    }
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
            _buildProfilePicture(),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.person, size: 28),
              title: const Text("Full Name", style: TextStyle(fontSize: 18)),
              trailing: Text(
                '$_firstName $_lastName',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.notifications, size: 28),
              title: const Text("Notifications", style: TextStyle(fontSize: 18)),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                if (userId.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'notificationsEnabled': _notificationsEnabled});
                }
              },
            ),
            const SizedBox(height: 50),
            _buildListTile(
              icon: Icons.lock_reset,
              title: "Change Password",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(contact: ''),
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.delete_forever,
              title: "Delete Account",
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showConfirmDialog(
                "Delete Account",
                "Are you sure you want to delete your account?",
                _deleteAccountWithReauth,
              ),
            ),
            _buildListTile(
              icon: Icons.logout,
              title: "Log out",
              onTap: () => _showConfirmDialog(
                "Log Out",
                "Are you sure you want to log out?",
                () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) =>  LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
