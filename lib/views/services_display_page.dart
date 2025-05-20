import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import 'package:mobile_service_hub/views/services_provider_page.dart';
import 'package:mobile_service_hub/widget/bottom_nav_bar.dart';


import '../widgets/category_dropdown_widget.dart';
import '../widgets/search_field_widget.dart';
import '../widgets/service_card_widget.dart';
import 'package:mobile_service_hub/repository/display_service_repository.dart';

class ServicesDisplayPage extends StatefulWidget {
  final List<Map<String, dynamic>> services;

  ServicesDisplayPage({required this.services});

  @override
  _ServicesDisplayPageState createState() => _ServicesDisplayPageState();
}

class _ServicesDisplayPageState extends State<ServicesDisplayPage> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceRepository _serviceRepo = ServiceRepository();

  List<Map<String, dynamic>> filteredServices = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredServices = widget.services;
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
    final query = _searchController.text;
    setState(() {
      filteredServices = _serviceRepo.filterServices(
        services: widget.services,
        query: query,
        selectedCategory: selectedCategory,
      );
    });
  }

  void _onCategoryChanged(String? category) {
    if (category == null) return;
    setState(() {
      selectedCategory = category;
    });
    _filterServices();
  }

  void _onSearchSubmitted(String query) {
    _serviceRepo.storeSearchQuery(query);
  }

  Future<void> _navigateToProviderPage() async {
    try {
      final servicesList = await _serviceRepo.fetchAllServices();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServicesProviderPage(services: servicesList),
        ),
      );
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الخدمات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Display Services",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.teal,
        actions: [
          CategoryDropdownWidget(
            selectedCategory: selectedCategory,
            categories: getCategories(),
            onChanged: _onCategoryChanged,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchFieldWidget(
            controller: _searchController,
            onChanged: (_) => _filterServices(),
            onSubmitted: _onSearchSubmitted,
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (_, index) {
                final service = filteredServices[index];
                return ServiceCardWidget(service: service);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'provider',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.person),
        onPressed: _navigateToProviderPage,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
