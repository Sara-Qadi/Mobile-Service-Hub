import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import 'view_service_page.dart';

class ServicesDisplayPage extends StatefulWidget {
  final List<Map<String, dynamic>> services;

  ServicesDisplayPage({required this.services});

  @override
  _ServicesDisplayPageState createState() => _ServicesDisplayPageState();
}

class _ServicesDisplayPageState extends State<ServicesDisplayPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredServices = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredServices = widget.services;
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> getCategories() {
    final categories = widget.services
        .map((s) => s['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredServices = widget.services.where((service) {
        final name = service['name']?.toString().toLowerCase() ?? '';
        final matchQuery = name.contains(query);
        final matchCategory =
            selectedCategory == 'All' || service['name'] == selectedCategory;
        return matchQuery && matchCategory;
      }).toList();
    });
  }

  void _onCategoryChanged(String? category) {
    if (category == null) return;
    setState(() {
      selectedCategory = category;
    });
    _filterServices(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
              title: Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      "Display Services",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ],
),

        backgroundColor: Colors.teal,
        actions: [
         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12.0),
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
   
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedCategory,
        dropdownColor: Colors.white,
        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
        items: getCategories().map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              category,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: _onCategoryChanged,
        icon: Icon(Icons.filter_list, color: Color.fromARGB(255, 11, 11, 11)),
      ),
    ),
  ),
),

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: Icon(Icons.search, color: Colors.teal),
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
                final imageBytes = base64Decode(service['imageBytes'] ?? '');

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewServicePage(service: service)),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image with overlay name
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.memory(
                                  imageBytes,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    service['user'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Service name
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            service['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
