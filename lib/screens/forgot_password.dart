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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text("Forgot Password"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 120),
      
              Text(
                'Forgot your password?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Enter your ${_selectedMethod == 'email' ? 'email address' : 'phone number'} below and we\'ll send you a code to reset your password.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              Center(
                child: Text(
                  'Choose how to receive the reset code:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            SizedBox(height: 20),
        Center(
          child:   ToggleButtons(
          
            isSelected: [_selectedMethod == 'email', _selectedMethod == 'sms'],
          
            onPressed: (index) {
          
              setState(() {
          
                _selectedMethod = index == 0 ? 'email' : 'sms';
          
                _contactController.clear();
          
                isButtonEnabled = false;
          
              });
          
            },
              
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
),


              SizedBox(height: 20),
              TextField(
                controller: _contactController,
                onChanged: (value) => _updateButtonState(),
                keyboardType: _selectedMethod == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                decoration: InputDecoration(
                  labelText:
                      _selectedMethod == 'email' ? "Email" : "Phone Number",
                  hintText: _selectedMethod == 'email'
                      ? "Enter your email"
                      : "Enter your phone number",
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
                    return Colors.teal;
                  }),
                ),
                onPressed: isButtonEnabled ? _sendResetLink : null,
                child: Text(
                  'Send Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
