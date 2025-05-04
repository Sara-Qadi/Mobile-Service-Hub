import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../widgets/add_rating_button.dart';
import '../widgets/ratings_list.dart';
import '../widgets/service_detail_card.dart';
import '../widgets/service_image_widget.dart';

import 'rating_page.dart';

class ViewServicePage extends StatefulWidget {
  final Map<String, dynamic> service;

  ViewServicePage({required this.service});

  @override
  _ViewServicePageState createState() => _ViewServicePageState();
}

class _ViewServicePageState extends State<ViewServicePage> {
  late Map<String, dynamic> service;

  @override
  void initState() {
    super.initState();
    service = Map<String, dynamic>.from(widget.service);
    service['ratings'] = List<Map<String, dynamic>>.from(service['ratings'] ?? []);
  }

  void _addRating(Map<String, dynamic> newRating) {
    setState(() {
      service['ratings'].add(newRating);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your rating has been submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service['name'] ?? 'Service Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.star_rate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingPage(
                    service: service,
                    onRatingSubmitted: _addRating,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                service['name'] ?? '',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:AppColors.primary),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Hero(
                tag: 'service-image-${service['name']}',
                child: ServiceImageWidget(service: service),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: AppColors.background, width: 2),
                  ),
                ),
                child: Text('Booking Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 16),
            ServiceDetailCard(title: 'Details', value: service['details'] ?? 'N/A'),
            ServiceDetailCard(title: 'Price', value: '${service['price'] ?? 'N/A'} \$'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AddRatingButton(service: service, onRatingSubmitted: _addRating),
              ],
            ),
            SizedBox(height: 24),
            RatingsList(ratings: service['ratings']),
          ],
        ),
      ),
    );
  }
}
