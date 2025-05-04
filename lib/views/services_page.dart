import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import 'package:mobile_service_hub/views/services_display_page.dart';
import 'package:mobile_service_hub/views/services_provider_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/add_service_card_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/service_card_widget.dart';
import 'update_service.dart';

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Map<String, dynamic>> services = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadServices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? servicesJson = prefs.getString('services');
    if (servicesJson != null) {
      List<dynamic> decoded = jsonDecode(servicesJson);
      services = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {});
    }
  }

  Future<void> _saveServices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('services', jsonEncode(services));
  }

  void _addService(Map<String, dynamic> newService) {
    setState(() {
      services.add(newService);
    });
    _saveServices();
  }

  void _updateService(Map<String, dynamic> service) async {
    final updatedService = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpdateService(service: service)),
    );

    if (updatedService != null) {
      setState(() {
        int index = services.indexWhere((s) => s['name'] == service['name']);
        if (index != -1) {
          services[index] = updatedService;
        }
      });
      _saveServices();
    }
  }

  void _deleteService(Map<String, dynamic> service) {
    setState(() {
      services.remove(service);
    });
    _saveServices();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = services
        .where((s) => s['name'].toString().toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:AppColors.primary,
        elevation: 4,
        title: Text("ServiceHub",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchBarWidget(controller: _searchController),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return AddServiceCardWidget(onAddService: _addService);
                return ServiceCardWidget(
                  service: filtered[index - 1],
                  onUpdateService: _updateService,
                  onDeleteService: _deleteService,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'provider',
            backgroundColor: Colors.teal,
            child: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServicesProviderPage(services: services),
                ),
              );
            },
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'display',
            backgroundColor: Colors.teal[700],
            child: Icon(Icons.grid_view),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServicesDisplayPage(services: services),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
