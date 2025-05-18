import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/reset_password.dart';
import '../widget/bottom_nav_bar.dart';

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
  Uint8List? _imageBytes;

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
          final data = userDoc.data() as Map<String, dynamic>;
          final imageData = data.containsKey('profileImage') ? data['profileImage'] : null;

          setState(() {
            _firstName = data['firstName'] ?? '';
            _lastName = data['lastName'] ?? '';
            _notificationsEnabled = data['notificationsEnabled'] ?? false;

            if (imageData != null && imageData.isNotEmpty) {
              try {
                _imageBytes = base64Decode(imageData);
              } catch (e) {
                print("Error decoding image: $e");
              }
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profileImage': base64String});
        setState(() {
          _imageBytes = bytes;
        });
      } catch (e) {
        print("Failed to upload image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image.")),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture() {
    ImageProvider? imageProvider;
    if (_imageBytes != null) {
      imageProvider = MemoryImage(_imageBytes!);
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundImage: imageProvider,
            backgroundColor: Colors.grey[300],
            child: imageProvider == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 22),
              onPressed: _showImageSourcePicker,
            ),
          ),
        ],
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text("Confirm"),
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
            decoration: const InputDecoration(labelText: 'Enter your password'),
            onChanged: (value) => password = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(password),
              child: const Text("Confirm"),
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
        if (email == null) throw Exception("Email not found");
        String? password = await _promptPassword();
        if (password == null || password.isEmpty) return;

        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.notifications, size: 28),
              title: const Text("Notifications", style: TextStyle(fontSize: 18)),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'notificationsEnabled': _notificationsEnabled});
              },
            ),
            const SizedBox(height: 50),
            _buildListTile(
              icon: Icons.lock_reset,
              title: "Change Password",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResetPasswordScreen(contact: '')),
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
                    MaterialPageRoute(builder: (_) => LoginScreen()),
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
}
