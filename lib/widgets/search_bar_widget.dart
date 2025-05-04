import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  SearchBarWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search services...",
          prefixIcon: Icon(Icons.search, color:AppColors.primary),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
