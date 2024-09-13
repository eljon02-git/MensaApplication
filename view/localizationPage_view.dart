import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:untitled1/LanguagePickerWidget.dart'; // Überprüfen Sie den Importpfad
import 'package:untitled1/controller/LanguagePage_controller.dart';
import '../LanguageWidget.dart';
import 'package:untitled1/controller/EntryPage_controller.dart';
import 'package:untitled1/controller/Login_controller.dart';
import 'package:untitled1/model/User_model.dart';

class LocalizationPageView extends StatefulWidget {
  const LocalizationPageView({super.key});

  @override
  _LocalizationPageViewState createState() => _LocalizationPageViewState();
}

class _LocalizationPageViewState extends State<LocalizationPageView> {
  final _formKey = GlobalKey<FormState>();
  late UserModel userModel;
  late LoginController loginController;
  late EntryController entryController;
  late LanguagePageController languagePage_Controller;

  @override
  void initState() {
    super.initState();
    // Initialize the UserModel
    userModel = UserModel(username: 'testuser', password: 'password1234');

    // Initialize controllers
    loginController = LoginController(userModel: userModel);
    entryController = EntryController(loginController: loginController);
    languagePage_Controller = LanguagePageController(entryController: entryController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localization Page'),
        actions: [
          LanguagePickerWidget(), // Sprachwähler-Widget
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LanguageWidget(), // Sprach-Widget
                  const SizedBox(height: 32),
                  Text(AppLocalizations.of(context)!.title),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                languagePage_Controller.navigateToEntry(context)
                ;
              },
              child: Text(AppLocalizations.of(context)!.message),
            ),
          ),
        ],
      ),
    );
  }
}
