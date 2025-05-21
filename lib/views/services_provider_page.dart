import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/repository/user_repository.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class ServicesProviderPage extends StatefulWidget {
  final List<Map<String, dynamic>> services;

  ServicesProviderPage({required this.services});

  @override
  _ServicesProviderPageState createState() => _ServicesProviderPageState();
}

class _ServicesProviderPageState extends State<ServicesProviderPage> {
  final TextEditingController _searchController = TextEditingController();
  final UserRepository _userRepo = UserRepository();

  List<Map<String, dynamic>> filteredServices = [];
  Map<String, Uint8List?> _profileImagesCache = {};

  @override
  void initState() {
    super.initState();
    filteredServices = widget.services;
    _searchController.addListener(_handleSearch);
    _loadImages(); // Calls future from repo
  }

  void _handleSearch() {
    setState(() {
      filteredServices = _userRepo.filterServicesByProvider(
          widget.services, _searchController.text);
    });
  }

  void _loadImages() async {
    final images =
        await _userRepo.preloadProfileImagesFromServices(widget.services);
    if (!mounted) return;
    setState(() {
      _profileImagesCache = images;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Provider Services"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by provider name...",
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.border,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (_, index) {
                final service = filteredServices[index];
                final userId = service['userId'] as String?;
                final providerName = service['user'] ?? 'Unknown';
                final imageBytes =
                    userId != null ? _profileImagesCache[userId] : null;

                return GestureDetector(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: imageBytes != null
                                ? Image.memory(imageBytes,
                                    fit: BoxFit.cover, width: double.infinity)
                                : Image.asset(
                                    'assets/images/person1.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            providerName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
