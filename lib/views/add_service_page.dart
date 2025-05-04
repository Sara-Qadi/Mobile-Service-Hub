import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/service_form_field.dart';
import '../screens/service_repository.dart'; 

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ImagePickerWidget(imageBytes: _imageBytes, onImageSelected: _onImageSelected),
            SizedBox(height: 20),
            ServiceFormField(
              controller: userController,
              label: 'User Name',
              hint: 'Enter your name',
              onChanged: _validateForm,
            ),
            SizedBox(height: 20),
            ServiceFormField(
              controller: nameController,
              label: 'Service Name',
              hint: 'Enter service name',
              onChanged: _validateForm,
            ),
            SizedBox(height: 16.0),
            ServiceFormField(
              controller: detailsController,
              label: 'Service Details',
              hint: 'Enter service details',
              maxLines: 3,
              onChanged: _validateForm,
            ),
            SizedBox(height: 16.0),
            ServiceFormField(
              controller: priceController,
              label: 'Price',
              hint: 'Enter service price',
              isNumber: true,
              onChanged: _validateForm,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: isFormValid
                  ? () {
                      final newService = {
                        'user': userController.text,
                        'name': nameController.text,
                        'details': detailsController.text,
                        'price': priceController.text,
                        'imageBytes': _imageBytes != null ? base64Encode(_imageBytes!) : '',
                        'ratings': [],
                      };

                      addService(newService); // <-- Save to memory

                      Navigator.pop(context, newService);
                    }
                  : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Add Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid ? AppColors.primary : AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
