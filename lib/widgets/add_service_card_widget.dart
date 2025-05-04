import 'package:flutter/material.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import '../views/add_service_page.dart';


class AddServiceCardWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddService;

  AddServiceCardWidget({required this.onAddService});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddServicePage()),
        );
        if (result != null) {
          onAddService(result);
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:AppColors.background.withOpacity(0.1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.primary, size: 40),
                SizedBox(height: 8),
                Text("Add Service",
                    style: TextStyle(
                        color:AppColors.light, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
