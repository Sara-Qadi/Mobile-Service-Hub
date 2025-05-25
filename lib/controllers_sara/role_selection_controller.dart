import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/create_account.dart';

class RoleSelectionController {
  void navigateToCreateAccount(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAccountScreen(role: role),
      ),
    );
  }
}
