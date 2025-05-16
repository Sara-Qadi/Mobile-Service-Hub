import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
    final double screenHeightFactor = 0.6;
  final double containerPadding = 20;
  final double cardElevation = 4;
  final double cardBorderRadius = 16;
  final double cardBorderWidth = 2;
  final double innerPadding = 20;
  final double titleFontSize = 22;
  final double appBarFontSize = 20;
  final double widgetSpacingLarge = 20;
  final double widgetSpacingSmall = 16;


  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); 
  }

  Future<void> _submitRating() async {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty) {
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
      'name': name,
      'comment': comment,
      'rating': _rating,
      'date': DateTime.now().toIso8601String(),
      'serviceId': widget.service['id'], // لربط التقييم بالخدمة
    };

    try {
      await FirebaseFirestore.instance
          .collection('ratings')
          .add(newRating);

      widget.onRatingSubmitted(newRating);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.border,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Rate - ${widget.service['name']}',
            style: TextStyle(fontSize:containerPadding , fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: screenHeight * screenHeightFactor,
            ),
            padding: EdgeInsets.all(containerPadding),
            child: Card(
              elevation: cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardBorderRadius),
                side: BorderSide(
                  color: AppColors.primary,
                  width: cardBorderWidth,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(innerPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate this service',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: widgetSpacingLarge),
                    RatingStarsWidget(
                      rating: _rating,
                      onRatingChanged: (newRating) {
                        setState(() {
                          _rating = newRating;
                        });
                      },
                    ),
                    SizedBox(height: widgetSpacingLarge),
                    NameFieldWidget(controller: _nameController),
                    SizedBox(height: widgetSpacingSmall),
                    CommentFieldWidget(controller: _commentController),
                    SizedBox(height: widgetSpacingLarge),
                    SubmitButtonWidget(
                      onPressed: _submitRating,
                    ),
                    SizedBox(height: widgetSpacingLarge),
                    // عرض التقييمات الحالية
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('ratings')
                          .where('serviceId', isEqualTo: widget.service['id'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var ratings = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: ratings.length,
                          itemBuilder: (context, index) {
                            var rating = ratings[index];
                           
                          },
                        );
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
