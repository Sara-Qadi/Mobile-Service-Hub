import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool isButtonEnabled = false;

  void _login() {
    print('Login Successful');
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
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
              SizedBox(height: 180),
      
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your email",
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                onChanged: (value) => _updateButtonState(),
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.blueGrey),
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
          Text(
            'Remember me',
            style: TextStyle(fontSize: 14),
          ),
        ],
          ),
          TextButton(
        onPressed: () {
          // TODO
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 14),
        ),
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
                  onPressed: () {
                   
                  },
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
                  onPressed: () {
            
                  },
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
      
                print('Navigate to signup screen');
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
