import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RatingStarsWidget extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  RatingStarsWidget({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          iconSize: 36,
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color:AppColors.primary,
          ),
          onPressed: () {
            onRatingChanged(index + 1.0);
          },
        );
      }),
    );
  }
}
