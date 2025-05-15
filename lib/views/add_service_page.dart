import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/service_form_field.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final userController = TextEditingController();
  Uint8List? _imageBytes;
  bool isFormValid = false;
   final double paddingAll = 16.0;
  final double spaceSmall = 16.0;
  final double spaceMedium = 20.0;
  final double spaceLarge = 24.0;
  final double appBarFontSize = 18;
  final double buttonFontSize = 16;
  final double buttonPaddingHorizontal = 24;
  final double buttonPaddingVertical = 12;
  final double buttonBorderRadius = 10;

  void _validateForm() {
    setState(() {
      isFormValid = nameController.text.isNotEmpty &&
          detailsController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          userController.text.isNotEmpty;
    });
  }

  void _onImageSelected(Uint8List bytes) {
    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> addService(Map<String, dynamic> newService) async {
  try {
    final docRef = await FirebaseFirestore.instance.collection('services').add(newService);
    await docRef.update({'id': docRef.id}); // إضافة الـ id داخل المستند نفسه
    print("Service added successfully with ID: ${docRef.id}");
  } catch (e) {
    print("Error adding service: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Service', style: TextStyle(fontSize: appBarFontSize, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingAll),
        child: Column(
          children: [
            ImagePickerWidget(imageBytes: _imageBytes, onImageSelected: _onImageSelected),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: userController,
              label: 'User Name',
              hint: 'Enter your name',
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: nameController,
              label: 'Service Name',
              hint: 'Enter service name',
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceSmall),
            ServiceFormField(
              controller: detailsController,
              label: 'Service Details',
              hint: 'Enter service details',
              maxLines: 3,
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceMedium),
            ServiceFormField(
              controller: priceController,
              label: 'Price',
              hint: 'Enter service price',
              isNumber: true,
              onChanged: _validateForm,
            ),
            SizedBox(height: spaceLarge),
            ElevatedButton(
  onPressed: isFormValid
      ? () async {
          final newService = {
            'user': userController.text,
            'name': nameController.text,
            'details': detailsController.text,
            'price': priceController.text,
            'imageBytes': _imageBytes != null ? base64Encode(_imageBytes!) : '',
           // 'ratings': [],
          };

          try {
            final docRef = await FirebaseFirestore.instance
                .collection('services')
                .add(newService);
            await docRef.update({'id': docRef.id}); 

            Navigator.pop(context, docRef.id); 
          } catch (e) {
            print("Error adding service: $e");
            
          }
        }
      : null,
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: buttonPaddingHorizontal, vertical: buttonPaddingVertical),
    child: Text('Add Service', style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: isFormValid ? AppColors.primary : AppColors.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}