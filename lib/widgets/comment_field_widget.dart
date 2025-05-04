import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class CommentFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  CommentFieldWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Your Comment (optional)',
        prefixIcon: Icon(Icons.comment, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor:AppColors.background,
      ),
      maxLines: 4,
    );
  }
}
