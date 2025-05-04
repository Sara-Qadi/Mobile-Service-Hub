import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/comment_field_widget.dart';
import '../widgets/name_field_widget.dart';
import '../widgets/rating_stars_widget.dart';
import '../widgets/submit_button_widget.dart';

class RatingPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final Function(Map<String, dynamic>) onRatingSubmitted;

  RatingPage({
    required this.service,
    required this.onRatingSubmitted,
  });

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.border,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Rate - ${widget.service['name']}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.6, 
            ),
            padding: EdgeInsets.all(20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color:AppColors.primary,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate this service',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    SizedBox(height: 20),
                    RatingStarsWidget(
                      rating: _rating,
                      onRatingChanged: (newRating) {
                        setState(() {
                          _rating = newRating;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    NameFieldWidget(controller: _nameController),
                    SizedBox(height: 16),
                    CommentFieldWidget(controller: _commentController),
                    SizedBox(height: 20),
                    SubmitButtonWidget(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter your name')),
                          );
                          return;
                        }
                        if (_rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a rating')),
                          );
                          return;
                        }

                        final newRating = {
                          'name': _nameController.text.trim(),
                          'comment': _commentController.text.trim(),
                          'rating': _rating,
                          'date': DateTime.now().toString(),
                        };

                        widget.onRatingSubmitted(newRating);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
