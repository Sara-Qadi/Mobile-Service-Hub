import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_service_hub/firebase_options.dart';
import 'package:mobile_service_hub/repository/RatingRepository.dart';
import 'package:mobile_service_hub/repository/display_service_repository.dart';
import 'package:mobile_service_hub/repository/update-service_repository.dart';
import 'package:mobile_service_hub/repository/view_rating_repository.dart';
import 'package:mobile_service_hub/routes/appRoutes.dart';
import 'package:mobile_service_hub/screens/role.dart';
import 'package:mobile_service_hub/views/services_page.dart';
import 'package:provider/provider.dart';

import 'package:mobile_service_hub/screens/login.dart';
import 'package:mobile_service_hub/theme/app_colors.dart';


import 'Firebase/ratingFirebase.dart';
import 'repository/add-service_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
       
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
   
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
      
        Provider<addServiceRepository>(
          create: (_) => addServiceRepository(),
        ),
        Provider<RatingRepository>(
          create: (_) => RatingRepository(),
        ),
        
        Provider<viewRatingRepository>(
          create: (_) => viewRatingRepository(),
        ),
        Provider<viewRatingRepository>(
          create: (_) => viewRatingRepository(),
        ),
        Provider<updateServiceRepository>(
          create: (_) => updateServiceRepository(),
        ),
        Provider<ServiceRepository>(
          create: (_) => ServiceRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'ServiceHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Roboto',
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            elevation: 4,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home:  LoginScreen(),
        routes: {
  '/role-selection': (context) => RoleSelectionScreen(),
},

       
      ),
    );
    
  }
}
