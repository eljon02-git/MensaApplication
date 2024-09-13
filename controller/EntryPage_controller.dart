import 'package:flutter/material.dart';
import '../view/Login_view.dart';
import '../view/MealPlanOverview_view.dart';
import 'Login_controller.dart';

class EntryController {
  final LoginController loginController;

  EntryController({required this.loginController});

  void navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ginPage(loginController: loginController),
      ),
    );
  }

  void navigateToMealPlanOverview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanOverviewPage(),
      ),
    );
  }
}
