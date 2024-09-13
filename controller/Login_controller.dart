import 'package:flutter/material.dart';
import '../model/User_model.dart';
import '../view/Admin_MealPlanOverview_view.dart';



class LoginController {
  UserModel userModel;

  LoginController({required this.userModel});

  bool validateLogin(String username, String password) {
    return username == userModel.username && password == userModel.password;
  }

  void navigateToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminMealplanOverview()),
    );
  }
}
