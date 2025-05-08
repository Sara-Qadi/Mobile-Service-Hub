import 'package:flutter/material.dart';
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

  void _sendResetLink() {
    print('Code sent to ${_contactController.text} via $_selectedMethod');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyCodeScreen(
          contact: _contactController.text,
          method: _selectedMethod,
        ),
      ),
    );
  }

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

  Widget _buildToggleButtons() {
    return Center(
      child: ToggleButtons(
        isSelected: [_selectedMethod == 'email', _selectedMethod == 'sms'],
        onPressed: _toggleMethod,
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: Colors.teal,
        color: Colors.black,
        constraints: const BoxConstraints(minHeight: 45, minWidth: 120),
        children: const [
          Text("Email"),
          Text("SMS"),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
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
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(6),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.blueAccent;
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.teal;
          } else if (states.contains(MaterialState.disabled)) {
            return Colors.grey.shade400;
          }
          return Colors.teal;
        }),
      ),
      onPressed: isButtonEnabled ? _sendResetLink : null,
      child: const Text(
        'Send Code',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: const Text(
        'Back to Login',
        style: TextStyle(fontSize: 14),
      ),
    );
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
            _buildToggleButtons(),
            const SizedBox(height: 20),
            _buildTextField(),
            const SizedBox(height: 30),
            _buildSendButton(),
            const SizedBox(height: 20),
            _buildBackToLoginButton(),
          ],
        ),
      ),
    );
  }
}
