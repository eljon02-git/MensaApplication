import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:untitled1/Locale_provider.dart';
import 'package:untitled1/view/EntryPage_view.dart';
import 'controller/EntryPage_controller.dart';
import 'controller/Login_controller.dart';
import 'controller/MealPlanController.dart';
import 'model/User_model.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';


Future<void> main() async {

  runApp(
      ChangeNotifierProvider(
          create: (context) => LocaleProvider(),
          child: const MensaApplication()));
}

class MensaApplication extends StatelessWidget {
  const MensaApplication({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel(username: 'testuser', password: 'password1234');
    final LoginController loginController = LoginController(userModel: userModel);
    final EntryController entryController = EntryController(loginController: loginController);
    final MealPlanController _mealController = MealPlanController();
    _mealController.initializeSampleWeeksIfNeeded(); // Laden der Meals in der main, da sonst Bug beim ersten Aufruf im Overview
    // Zugriff auf LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Mensa Application',
      home: EntryPage(entryController: entryController),
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}