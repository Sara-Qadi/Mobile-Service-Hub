import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/login.dart';

class CreateAccountScreen extends StatefulWidget {
    final String role; // Role passed from the RoleSelectionScreen
  
  CreateAccountScreen({required this.role});
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();

  bool isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _firstNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _locationController.text.isNotEmpty;
    });
  }

  void _createAccount() {
    print('Account Created for ${_firstNameController.text}');
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 120),
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _firstNameController,
                onChanged: (_) => _updateButtonState(),
                decoration: InputDecoration(
                  labelText: "First Name",
                  hintText: "Enter your first name",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _lastNameController,
                onChanged: (_) => _updateButtonState(),
                decoration: InputDecoration(
                  labelText: "Last Name",
                  hintText: "Enter your last name",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                onChanged: (_) => _updateButtonState(),
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                onChanged: (_) => _updateButtonState(),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                onChanged: (_) => _updateButtonState(),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  hintText: "Re-enter your password",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _locationController,
                onChanged: (_) => _updateButtonState(),
                decoration: InputDecoration(
                  labelText: "Location",
                  hintText: "Enter your location (Optional)",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(6),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 16),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blueAccent;
                    } else if (states.contains(MaterialState.hovered)) {
                      return Colors.teal;
                    } else if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade400;
                    }
                    return Colors.green;
                  }),
                ),
                onPressed: isButtonEnabled ? _createAccount : null,
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                           Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
