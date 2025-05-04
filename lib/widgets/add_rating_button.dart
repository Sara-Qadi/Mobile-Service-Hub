import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';


import '../views/rating_page.dart'; 

class AddRatingButton extends StatelessWidget {
  final Map<String, dynamic> service;
  final Function(Map<String, dynamic>) onRatingSubmitted;

  const AddRatingButton({required this.service, required this.onRatingSubmitted});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.star),
      label: Text('Add Rating'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingPage(
              service: service,
              onRatingSubmitted: onRatingSubmitted,
            ),
          ),
        );
      },
    );
  }
}
