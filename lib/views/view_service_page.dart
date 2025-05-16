import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screen/Bookingform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rating_page.dart';
import '../screens/service_repository.dart';

class ViewServicePage extends StatefulWidget {
  final Map<String, dynamic> service;

  const ViewServicePage({Key? key, required this.service}) : super(key: key);

  @override
  _ViewServicePageState createState() => _ViewServicePageState();
}

class _ViewServicePageState extends State<ViewServicePage> {
  late Map<String, dynamic> service;

  @override
  void initState() {
    super.initState();
    service = Map<String, dynamic>.from(widget.service);
      if (!service.containsKey('userId') && widget.service['userId'] != null) {
    service['userId'] = widget.service['userId'];
  }
    service['ratings'] = [];
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ratings_${service['name']}';
    final storedRatings = prefs.getString(key);
    if (storedRatings != null) {
      final decoded = jsonDecode(storedRatings);
      if (decoded is List) {
        setState(() {
          service['ratings'] = List<Map<String, dynamic>>.from(decoded);
        });
      }
    }
  }

  Future<void> _saveRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ratings_${service['name']}';
    final encoded = jsonEncode(service['ratings']);
    await prefs.setString(key, encoded);
  }

  void _addRating(Map<String, dynamic> newRating) {
    setState(() {
      service['ratings'].add(newRating);
    });
    _saveRatings(); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your rating has been submitted!')),
    );
  }

  Widget _buildImageWidget() {
    try {
      if (service['imageBytes'] != null && service['imageBytes'].isNotEmpty) {
        return Image.memory(
          base64Decode(service['imageBytes']),
          fit: BoxFit.cover,
          width: 160,
          height: 160,
        );
      } else if (service['imageUrl'] != null && service['imageUrl'].isNotEmpty) {
        return Image.network(
          service['imageUrl'],
          fit: BoxFit.cover,
          width: 160,
          height: 160,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      } else if (!kIsWeb && service['imagePath'] != null && service['imagePath'].isNotEmpty) {
        return Image.file(
          File(service['imagePath']),
          fit: BoxFit.cover,
          width: 160,
          height: 160,
        );
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 160,
      height: 160,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.teal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allProviders = getAllServices()
        .where((s) => s['name'] == service['name'])
        .toList();

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
                    onRatingSubmitted: _addRating,
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
                            child: _buildImageWidget(),
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
          'userId': service['userId'], // ✅ This is now passed correctly
        },
      ),
    ),
  );
},

),

                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard('Service Provider', service['user'] ?? 'N/A'),
                    _buildDetailCard('Details', service['details'] ?? 'N/A'),
                    _buildDetailCard('Price', '${service['price'] ?? 'N/A'} \$'),
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
                                onRatingSubmitted: _addRating,
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
                        return _buildRatingCard(rating);
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

  Widget _buildDetailCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal, width: 1),
      ),
      child: Text(
        '$title: $content',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(color: Colors.teal, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal[100],
                  child: const Icon(Icons.person, color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Text(
                  rating['name'] ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < (rating['rating'] ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              rating['comment'] ?? '',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            if (rating['date'] != null)
              Text(
                rating['date'].toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
