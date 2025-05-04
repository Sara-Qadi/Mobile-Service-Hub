import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class ServiceImageWidget extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceImageWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (service['imageBytes'] != null && service['imageBytes'].isNotEmpty) {
      imageWidget = Image.memory(
        base64Decode(service['imageBytes']),
        height: 160,
        width: 160,
        fit: BoxFit.cover,
      );
    } else if (service['imageUrl'] != null && service['imageUrl'].isNotEmpty) {
      imageWidget = Image.network(
        service['imageUrl'],
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && service['imagePath'] != null && service['imagePath'].isNotEmpty) {
      imageWidget = Image.file(
        File(service['imagePath']),
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Container(
        height: 150,
        width: 150,
        color:AppColors.info,
        child: Center(
          child: Icon(Icons.image, size: 60, color:AppColors.primary),
        ),
      );
    }

    return ClipOval(
      child: Container(
        width: 160,
        height: 160,
        child: imageWidget,
      ),
    );
  }
}