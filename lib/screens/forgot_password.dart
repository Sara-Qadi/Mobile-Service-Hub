import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/varify.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _contactController = TextEditingController();
  String _selectedMethod = 'email'; 
  bool isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _contactController.text.isNotEmpty;
    });
  }

  void _toggleMethod(int index) {
    setState(() {
      _selectedMethod = index == 0 ? 'email' : 'sms'; 
      _contactController.clear();
      isButtonEnabled = false;
    });
  }

  Future<void> _sendResetLink() async {
   final contact = _contactController.text.trim();

if (_selectedMethod == 'email') {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(contact)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid email address.")),
    );
    return;
  }
} else {
  final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$'); 
  if (!phoneRegex.hasMatch(contact)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid phone number.")),
    );
    return;
  }
}


    if (_selectedMethod == 'email') {
 
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: contact);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
  
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: contact,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyCodeScreen(
                  contact: contact,
                  method: 'sms',
                  verificationId: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 120),
            const Text(
              'Forgot your password?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Enter your ${_selectedMethod == 'email' ? 'email address' : 'phone number'} below and we\'ll send you a code to reset your password.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Choose how to receive the reset code:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ToggleButtons(
                isSelected: [_selectedMethod == 'email', _selectedMethod == 'sms'],
                onPressed: _toggleMethod,
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.teal,
                color: Colors.black,
                constraints: const BoxConstraints(minHeight: 45, minWidth: 120),
                children: const [Text("Email"), Text("SMS")],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              key: ValueKey(_selectedMethod),
              controller: _contactController,
              onChanged: (_) => _updateButtonState(),
              keyboardType: _selectedMethod == 'email'
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: InputDecoration(
                labelText: _selectedMethod == 'email' ? "Email" : "Phone Number",
                hintText: _selectedMethod == 'email'
                    ? "Enter your email"
                    : "Enter your phone number",
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isButtonEnabled ? _sendResetLink : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Send Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
