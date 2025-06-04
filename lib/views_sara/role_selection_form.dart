import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../controllers_sara/role_selection_controller.dart';


class RoleSelectionForm extends StatelessWidget {
  final RoleSelectionController controller;

  const RoleSelectionForm({required this.controller, super.key});

  Widget _buildRoleButton({
    required BuildContext context,
    required String label,
    required String role,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () => controller.navigateToCreateAccount(context, role),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 70),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: AppColors.shadow,
        elevation: 4,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 250),
        const Text(
          "Please select your role",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildRoleButton(
          context: context,
          label: "Customer",
          role: "Customer",
          color: AppColors.primary,
        ),
        const SizedBox(height: 20),
        _buildRoleButton(
          context: context,
          label: "Service Provider",
          role: "Service Provider",
          color: AppColors.secondary,
        ),
   
      ],
    );
  }
}
