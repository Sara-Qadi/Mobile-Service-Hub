import 'package:flutter/material.dart';
import '../modelRaghad/rating.dart';
import '../repository/view_rating_repository.dart';
import '../screen/Bookingform.dart';
import '../widgets/detail_card_widget.dart';
import '../widgets/rating_card_widget.dart';
import '../widgets/service_image_widget.dart';
import 'rating_page.dart';

class ViewServicePage extends StatefulWidget {
  final Map<String, dynamic> service;

  const ViewServicePage({Key? key, required this.service}) : super(key: key);

  @override
  _ViewServicePageState createState() => _ViewServicePageState();
}

class _ViewServicePageState extends State<ViewServicePage> {
  late Map<String, dynamic> service;
  final viewRatingRepository _ratingRepository = viewRatingRepository();

  @override
  void initState() {
    super.initState();
    service = Map<String, dynamic>.from(widget.service);
    service['ratings'] = [];
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final ratings = await _ratingRepository.loadRatings(service['id']);
    setState(() {
      service['ratings'] = ratings;
    });
  }

  Future<void> _saveRatings() async {
    await _ratingRepository.saveRatings(service['name'], List<Map<String, dynamic>>.from(service['ratings']));
  }

  void _addRating(Rating newRating) {
    setState(() {
      service['ratings'].add(newRating.toMap());
    });
    _saveRatings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your rating has been submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          service['name'] ?? 'Service Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingPage(
                    service: service,
                    onRatingSubmitted: (ratingMap) {
                      final rating = Rating.fromMap(ratingMap);
                      _addRating(rating);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        service['name'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Hero(
                        tag: 'service-image-${service['name']}',
                        child: ClipOval(
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: ServiceImageWidget(service: service),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: const Text(
                          'Book Now',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          minimumSize: const Size(80, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.white, width: 1.5),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingForm(
                                service: {
                                  'id': service['id'],
                                  'name': service['name'],
                                  'user': service['user'],
                                  'userId': service['userId'],
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    DetailCardWidget(title: 'Service Provider', content: service['user'] ?? 'N/A'),
                    DetailCardWidget(title: 'Phone Number', content: service['phone'] ?? 'N/A'), 
                    DetailCardWidget(title: 'Details', content: service['details'] ?? 'N/A'),
                    DetailCardWidget(title: 'Price', content: '${service['price'] ?? 'N/A'} \$'),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text(
                          'Add Rating',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          minimumSize: const Size(100, 35),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingPage(
                                service: service,
                                onRatingSubmitted: (ratingMap) {
                                  final rating = Rating.fromMap(ratingMap);
                                  _addRating(rating);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (service['ratings'].isNotEmpty) ...[
                      Text(
                        'Reviews:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...service['ratings'].map<Widget>((rating) {
                        final r = Rating.fromMap(rating);
                        return RatingCardWidget(rating: r);
                      }).toList(),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
