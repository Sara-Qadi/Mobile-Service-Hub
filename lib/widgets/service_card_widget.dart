import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../views/view_service_page.dart';


class ServiceCardWidget extends StatelessWidget {
  final Map<String, dynamic> service;
  final Function(Map<String, dynamic>) onUpdateService;
  final Function(Map<String, dynamic>) onDeleteService;

  ServiceCardWidget({
    required this.service,
    required this.onUpdateService,
    required this.onDeleteService,
  });

  @override
  Widget build(BuildContext context) {
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
                        color: AppColors.dark,
                        child: Icon(Icons.image, size: 50, color:AppColors.primary),
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
                        onTap: () => onUpdateService(service),
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
                        onTap: () => onDeleteService(service),
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
}
