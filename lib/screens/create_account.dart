import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_service_hub/screens/login.dart';
import '../widgets_sara/custom_text_field.dart';
class CreateAccountScreen extends StatefulWidget {
  final String role; 

  const CreateAccountScreen({required this.role, super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isButtonEnabled = false;
  bool _isLoading = false;

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _firstNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  Future<void> _createAccount() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();
  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();

  if (firstName.isEmpty || lastName.isEmpty) {
    _showError('Please enter your first and last name');
    return;
  }

  if (!RegExp(r"^[a-zA-Z]+$").hasMatch(firstName) ||
      !RegExp(r"^[a-zA-Z]+$").hasMatch(lastName)) {
    _showError('Names should only contain letters');
    return;
  }

  if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
    _showError('Invalid email format');
    return;
  }

if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$')
    .hasMatch(password)) {
  _showError(
      'Password must be at least 6 characters and include:\n• Uppercase\n• Lowercase\n• Number\n• Special character');
  return;
}


  if (password != confirmPassword) {
    _showError('Passwords do not match');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'location': _locationController.text.trim(),
        'role': widget.role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  } on FirebaseAuthException catch (e) {
    _showError(e.message ?? 'An error occurred');
  } catch (e) {
    _showError('Something went wrong');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 120),
            const Center(
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'Enter your first name',
              onChanged: (_) => _updateButtonState(),
            ),
            CustomTextField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Enter your last name',
              onChanged: (_) => _updateButtonState(),
            ),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              onChanged: (_) => _updateButtonState(),
                keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              onChanged: (_) => _updateButtonState(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              obscureText: _obscureConfirmPassword,
              onChanged: (_) => _updateButtonState(),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            CustomTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter your location (Optional)',
              onChanged: (_) => _updateButtonState(),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isButtonEnabled
                          ? Colors.green
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: isButtonEnabled ? _createAccount : null,
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2),
                    ),
                  ),
            const SizedBox(height: 30),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            ),
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
