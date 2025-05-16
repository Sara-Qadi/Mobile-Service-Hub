import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/views/services_display_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_service_hub/screens/create_account.dart';
import 'package:mobile_service_hub/screens/forgot_password.dart';
import 'package:mobile_service_hub/screens/role.dart';
import 'package:mobile_service_hub/views/services_page.dart';
import 'package:mobile_service_hub/widgets_sara/login_text_field.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoginEnabled = false;
  bool _obscurePassword = true;
  bool _emailErrorVisible = false;
  bool _passwordErrorVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
        _isLoginEnabled = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailErrorVisible = !_isValidEmail(email);
      _passwordErrorVisible = !_isValidPassword(password);
      _isLoginEnabled = _isValidEmail(email) && _isValidPassword(password);
    });
  }

  bool _isValidEmail(String email) {
    return email.contains(RegExp(r'^[^@]+@[^@]+\.[^@]+'));
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
Future<void> _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  setState(() {
    _emailErrorVisible = email.isEmpty || !_isValidEmail(email);
    _passwordErrorVisible = password.isEmpty || !_isValidPassword(password);
  });

  if (_emailErrorVisible || _passwordErrorVisible) {
    _showError('Please fix the errors before logging in.');
    return;
  }

  setState(() => _isLoading = true);

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user == null) {
      _showError('Login failed. Please try again.');
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      _showError('User data not found.');
      return;
    }

    final userData = userDoc.data();
    final status = userData?['status'] ?? 'pending';
    final role = userData?['role'] ?? 'User';

    if (role == 'Service Provider' && status == 'pending') {
      _showError('Your account is awaiting admin approval.');
      await FirebaseAuth.instance.signOut();
      return;
    }

    // Save credentials and user info
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }

    await prefs.setString('uid', user.uid);
    await prefs.setString('role', role);
    List<Map<String, dynamic>> services = [];

if (role == 'Admin' || role == 'Customer') {
  final snapshot = await FirebaseFirestore.instance.collection('services').get();
  services = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}

if (role == 'Admin' || role == 'Customer') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => ServicesDisplayPage(services: services)),
  );
} else if (role == 'Service Provider') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => ServicesPage()),
  );
} else {
  _showError('Unrecognized role. Please contact support.');
}

  } on FirebaseAuthException catch (e) {
    _showError(e.message ?? 'Login failed');
  } catch (e) {
    _showError('Something went wrong. Please try again.');
  } finally {
    setState(() => _isLoading = false);
  }
}



  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 125),
            Center(
              child: Image.asset('assets/images/logo.png', height: 120),
            ),
            const SizedBox(height: 60),
            LoginTextField(
              controller: _emailController,
              labelText: "Email",
              hintText: "Enter your email",
              obscureText: false,
              showError: _emailErrorVisible,
              errorText: "Please enter a valid email address",
              onChanged: (_) => _updateButtonState(),
            ),
            const SizedBox(height: 20),
            LoginTextField(
              controller: _passwordController,
              labelText: "Password",
              hintText: "Enter your password",
              obscureText: _obscurePassword,
              showError: _passwordErrorVisible,
              errorText: "Password must be at least 6 characters",
              toggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              onChanged: (_) => _updateButtonState(),
            ),
            _buildRememberMeAndForgot(),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLoginButton(),
            const SizedBox(height: 20),
            _buildOrDivider(),
            const SizedBox(height: 20),
            _buildSocialLoginButtons(),
            const SizedBox(height: 30),
            _buildCreateAccountText(),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberMeAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() => _rememberMe = value!);
              },
              visualDensity: VisualDensity.compact,
            ),
            const Text('Remember me', style: TextStyle(fontSize: 14)),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
            );
          },
          child: const Text('Forgot Password?', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: _isLoginEnabled
            ? AppColors.primary
            : AppColors.disabled,
      ),
      onPressed: _isLoginEnabled ? _login : null,
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("OR"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.g_mobiledata),
          label: const Text("Sign in with Google"),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.facebook),
          label: const Text("Sign in with Facebook"),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountText() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: "Create one",
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
