import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';
import 'views/services_page.dart';

void main() {
  
  debugPrintRebuildDirtyWidgets = false;
  
  debugPrintRebuildDirtyWidgets = false;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServiceHub',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 4,
        ),
      ),
      home: ServicesPage(),
    );
  }
}
