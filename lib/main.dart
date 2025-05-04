import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/screens/forgot_password.dart';
import 'package:mobile_service_hub/screens/customer_profile.dart';
import 'package:mobile_service_hub/screens/service_p_profile.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'create account App',
      home: ForgotPasswordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
