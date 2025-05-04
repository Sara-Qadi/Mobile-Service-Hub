import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class SubmitButtonWidget extends StatelessWidget {
  final Function() onPressed;

  SubmitButtonWidget({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Submit Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.send),
          ],
        ),
      ),
    );
  }
}
