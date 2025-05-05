import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/create_account.dart';
import 'package:mobile_service_hub/screens/forgot_password.dart';
import 'package:mobile_service_hub/screens/role.dart';
import 'package:mobile_service_hub/views/services_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool isButtonEnabled = false;
  bool _obscurePassword = true;
  bool _showPasswordError = false;
  bool _showEmailError = false;

  void _login() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => ServicesPage()),
  );
}


  void _updateButtonState() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _showEmailError = !_isValidEmail(email);
      _showPasswordError = !_isValidPassword(password);
      isButtonEnabled = _isValidEmail(email) && _isValidPassword(password);
    });
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 125),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
              ),
            ),
            SizedBox(height: 60),

            TextField(
              controller: _emailController,
              onChanged: (value) => _updateButtonState(),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.blueGrey),
              ),
            ),

            if (_showEmailError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  "Please enter a valid email address",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              onChanged: (value) => _updateButtonState(),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter your password",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.blueGrey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            if (_showPasswordError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  "Password must be at least 6 characters",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('Remember me', style: TextStyle(fontSize: 14)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text('Forgot Password?', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 20),

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
                  if (states.contains(MaterialState.pressed)) return Colors.blueAccent;
                  if (states.contains(MaterialState.hovered)) return Colors.teal;
                  if (states.contains(MaterialState.disabled)) return Colors.grey.shade400;
                  return Colors.green;
                }),
              ),
              onPressed: isButtonEnabled ? _login : null, 
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                
              ),
              
            ),
            SizedBox(height: 20),

            Row(children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("OR"),
              ),
              Expanded(child: Divider()),
            ]),
            SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata),
              label: Text("Sign in with Google"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.facebook),
              label: Text("Sign in with Facebook"),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 30),

            Center(
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Create one",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoleSelectionScreen(),
                            ),
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
    );
  }
}