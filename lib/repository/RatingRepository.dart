import 'package:flutter/material.dart';
import '../Firebase/ratingFirebase.dart';

class RatingRepository {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> submitRating({
    required BuildContext context,
    required Map<String, dynamic> service,
    required String name,
    required String comment,
    required double rating,
    required Function(Map<String, dynamic>) onRatingSubmitted,
  }) async {
    if (name.isEmpty || rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            name.isEmpty ? 'Please enter your name' : 'Please select a rating',
          ),
        ),
      );
      return;
    }

    final newRating = {
      'name': name,
      'comment': comment,
      'rating': rating,
      'date': DateTime.now().toIso8601String(),
      'serviceId': service['id'],
    };

    try {
      await _firebaseService.addRating(newRating);
      onRatingSubmitted(newRating);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  Stream getServiceRatings(String serviceId) {
    return _firebaseService.getRatingsForService(serviceId);
  }
}
