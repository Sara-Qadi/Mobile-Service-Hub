import 'dart:core';

import 'package:flutter/cupertino.dart';
import '../screens/role.dart';
import '../screens/forgot_password.dart';
import '../views/add_service_page.dart';
import '../views/rating_page.dart';
import '../views/services_display_page.dart';
import '../views/update_service.dart';
import '../views/view_service_page.dart';



class AppRoutes {
  late final Map<String, dynamic> service;
  late final Function(Map<String, dynamic>) onRatingSubmitted;
  static const String home = '/service_page';
  static const String forgotPassword = '/forgot-password';


  static const String ratingPage = '/rating_page';
  static const String viewServicePage = '/view_service_page';
  static const String updateServicePage = '/update_service_page';
  static const String addServicePage = '/add_service_page';
  static const String serviceDisplayPage = '/service_display_page';
static const String roleSelection = '/role-selection';

static Map<String, WidgetBuilder> getRoutes() {
  return {
    home: (context) => ServicesDisplayPage(services: []),
    forgotPassword: (context) => ForgotPasswordScreen(),
    addServicePage: (context) => AddServicePage(),
    viewServicePage: (context) => ViewServicePage(service: {}),
    roleSelection: (context) => const RoleSelectionScreen(), // Add this line
  };
}


}
