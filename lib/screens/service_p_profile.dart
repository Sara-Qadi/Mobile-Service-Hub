import 'package:flutter/material.dart';
import 'package:mobile_service_hub/main.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/reset_password.dart';
import 'package:mobile_service_hub/views/services_page.dart';
import 'package:mobile_service_hub/theme/app_colors.dart'; 
class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  bool _notificationsEnabled = false;
  String _username = "Mohammad_5";
  String _phoneNumber = "0597259604";

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
        style: TextButton.styleFrom(
          foregroundColor: Colors.red, 
        ),
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

  void _editTextField({
    required String title,
    required String initialValue,
    required String hintText,
    required Function(String) onSave,
    required String Function(String) validator,
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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
                final error = validator(value);
                if (error.isNotEmpty) {
                  setState(() => errorText = error);
                } else {
                  onSave(value);
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
                        // TODO: Handle image update
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildProfileTile(
              icon: Icons.person,
              title: "Username",
              value: _username,
              onTap: () => _editTextField(
                title: "Edit Username",
                initialValue: _username,
                hintText: "Enter new username",
                onSave: (val) => setState(() => _username = val),
                validator: (val) => val.isEmpty ? "Username cannot be empty" : "",
              ),
            ),
            _buildProfileTile(
              icon: Icons.phone,
              title: "Phone Number",
              value: _phoneNumber,
              onTap: () => _editTextField(
                title: "Edit Phone Number",
                initialValue: _phoneNumber,
                hintText: "Enter 10-digit phone number",
                keyboardType: TextInputType.phone,
                onSave: (val) => setState(() => _phoneNumber = val),
                validator: (val) {
                  if (val.isEmpty) return "Phone number cannot be empty";
                  if (val.length != 10 || !RegExp(r'^\d+$').hasMatch(val)) {
                    return "Enter a valid 10-digit number";
                  }
                  return "";
                },
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
                () {
                  // TODO: Delete account logic
                },
              ),
            ),
            _buildSimpleTile(
              icon: Icons.logout,
              text: "Log out",
              onTap: () => _showConfirmDialog(
                "Log Out",
                "Are you sure you want to log out?",
                () {
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
