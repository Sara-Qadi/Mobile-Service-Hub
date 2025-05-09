import 'dart:convert';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:mobile_service_hub/main.dart';

import 'package:mobile_service_hub/views/services_display_page.dart';
import 'package:mobile_service_hub/views/services_provider_page.dart';

import 'add_service_page.dart';
import 'view_service_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_service.dart';
import '../widget/bottom_nav_bar.dart';
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

  Widget _buildServiceCard(Map<String, dynamic> service) {
    Uint8List? imageBytes;
    if (service['imageBytes'] != null && service['imageBytes'] != "") {
      imageBytes = base64Decode(service['imageBytes']);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewServicePage(service: service)),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: imageBytes != null
                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 50, color: Colors.teal),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    service['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.teal[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => _updateService(service),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.teal),
                            SizedBox(height: 4),
                            Text(
                              'edit',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                       onTap: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Delete Service"),
      content: Text("Are you sure you want to delete this service?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              services.remove(service);
            });
            _saveServices();
            Navigator.of(context).pop();
          },
          child: Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
},

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, color: Colors.red[400]),
                            SizedBox(height: 4),
                            Text(
                              'delete',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddServiceCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddServicePage()),
        );
        if (result != null) {
          _addService(result);
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromARGB(255, 248, 253, 252).withOpacity(0.1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.teal, size: 40),
                SizedBox(height: 8.0,),
                Text("Add Service",
                    style: TextStyle(
                        color: Colors.teal[700], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
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
        backgroundColor: Colors.teal[600],
        elevation: 4,
        title: Text("ServiceHub",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,



                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  //borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
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
                if (index == 0) return _buildAddServiceCard();
                return _buildServiceCard(filtered[index - 1]);
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
         bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}