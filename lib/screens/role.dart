import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../controllers_sara/role_selection_controller.dart';
import '../views_sara/role_selection_form.dart';


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RoleSelectionController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: RoleSelectionForm(controller: controller),
        ),
      ),
    );
  }
}
