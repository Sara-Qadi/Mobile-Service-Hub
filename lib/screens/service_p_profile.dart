import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/reset_password.dart';
import 'package:mobile_service_hub/views/services_page.dart';
import 'package:mobile_service_hub/widget/bottom_nav_bar.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  bool _notificationsEnabled = false;
  String _firstName = '';
  String _lastName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          setState(() {
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> _updateUserProfileField(String field, String value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        field: value,
      });
      setState(() {
        if (field == 'firstName') _firstName = value;
        if (field == 'lastName') _lastName = value;
      });
    }
  }

  void _editTextField({
    required String title,
    required String initialValue,
    required String hintText,
    required String fieldKey,
  }) {
    final controller = TextEditingController(text: initialValue);
    String? errorText;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
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
                final value = controller.text.trim();
                if (value.isEmpty) {
                  setState(() => errorText = "$fieldKey cannot be empty");
                } else {
                  _updateUserProfileField(fieldKey, value);
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // TODO: Change profile picture
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_firstName $_lastName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildProfileTile(
              icon: Icons.person,
              title: "First Name",
              value: _firstName,
              onTap: () => _editTextField(
                title: "Edit First Name",
                initialValue: _firstName,
                hintText: "Enter first name",
                fieldKey: 'firstName',
              ),
            ),
            _buildProfileTile(
              icon: Icons.person_outline,
              title: "Last Name",
              value: _lastName,
              onTap: () => _editTextField(
                title: "Edit Last Name",
                initialValue: _lastName,
                hintText: "Enter last name",
                fieldKey: 'lastName',
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSimpleTile(
              icon: Icons.build,
              text: "My Services",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) =>  ServicesPage()),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildSimpleTile(
              icon: Icons.lock_reset,
              text: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  ResetPasswordScreen(contact: '')),
                );
              },
            ),
            _buildSimpleTile(
              icon: Icons.delete_forever,
              text: "Delete Account",
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showConfirmDialog(
                "Delete Account",
                "Are you sure you want to delete your account?",
                _deleteAccountWithReauth,
              ),
            ),
            _buildSimpleTile(
              icon: Icons.logout,
              text: "Log Out",
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

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: InkWell(
        onTap: onTap,
        child: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.text,
        ),
      ),
      onTap: onTap,
    );
  }
}
