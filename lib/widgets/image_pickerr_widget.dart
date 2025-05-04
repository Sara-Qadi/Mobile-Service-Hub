import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final Function() onTap;

  ImagePickerWidget({required this.imageBytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.teal, width: 2),
        ),
        child: imageBytes == null
            ? Center(child: Icon(Icons.add_a_photo, color: Colors.teal))
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
