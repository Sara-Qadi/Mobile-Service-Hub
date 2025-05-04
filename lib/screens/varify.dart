import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/reset_password.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String contact;
  final String method;

  VerifyCodeScreen({required this.contact, required this.method});

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  void _verifyCode() {
    String enteredCode = _controllers.map((c) => c.text).join();
    print('Verifying code $enteredCode sent to ${widget.contact}');

    // TODO: Add actual verification logic
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(contact: widget.contact),
      ),
    );
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    _focusNodes.forEach((f) => f.dispose());
    super.dispose();
  }

  Widget _buildDigitBox(int index) {
    return Container(
      width: 50,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => _onDigitEntered(index, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify ${widget.method.toUpperCase()}")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 140),
            Text(
              'Enter the code sent to your ${widget.method}:\n${widget.contact}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDigitBox(index)),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isCodeComplete ? _verifyCode : null,
              child: Text('Verify', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
