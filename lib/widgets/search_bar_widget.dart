import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  SearchBarWidget({required this.controller});

  void searchInFirestore(String query) async {
    if (query.trim().isEmpty) return;

   
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('search')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    for (var doc in snapshot.docs) {
      print("Matched: ${doc['name']}");
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        onChanged: searchInFirestore,
        decoration: InputDecoration(
          hintText: "Search services...",
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
