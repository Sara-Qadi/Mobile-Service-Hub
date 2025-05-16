import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/update_button_widget.dart';
import '../widgets/image_pickerr_widget.dart';

class UpdateService extends StatefulWidget {
  final Map<String, dynamic> service;

  UpdateService({required this.service});

  @override
  _UpdateServicePageState createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateService> {
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final userController = TextEditingController();

  Uint8List? _imageBytes;
   static const double paddingAll = 16.0;
  static const double spacingSmall = 16.0;
  static const double spacingMedium = 20.0;
  static const double spacingLarge = 24.0;


  @override
  void initState() {
    super.initState();
    final service = widget.service;
    nameController.text = service['name'];
    detailsController.text = service['details'];
    priceController.text = service['price'];
    userController.text = service['user'];
    _imageBytes = base64Decode(service['imageBytes']);
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: ${e.toString()}')),
      );
    }
  }

  void _submitUpdate() {
    if (nameController.text.isEmpty ||
        detailsController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final updatedService = {
      'user': userController.text,
      'name': nameController.text,
      'details': detailsController.text,
      'price': priceController.text,
      'imageBytes': base64Encode(_imageBytes ?? Uint8List(0)),
    };

    Navigator.pop(context, updatedService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Service')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingAll),
        child: Column(
          children: [
            ImagePickerWidget(
              imageBytes: _imageBytes,
              onTap: _pickImage,
            ),
            SizedBox(height: spacingMedium),
            TextFieldWidget(controller: userController, labelText: 'User Name'),
            SizedBox(height: spacingMedium),
            TextFieldWidget(controller: nameController, labelText: 'Service Name'),
            SizedBox(height: spacingSmall),
            TextFieldWidget(
              controller: detailsController,
              labelText: 'Service Details',
              maxLines: 3,
            ),
            SizedBox(height: spacingSmall),
            TextFieldWidget(
              controller: priceController,
              labelText: 'Price',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: spacingLarge),
            UpdateButtonWidget(onPressed: _submitUpdate),
          ],
        ),
      ),
    );
  }
}
