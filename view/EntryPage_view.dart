import 'package:flutter/material.dart';
import 'package:untitled1/LanguagePickerWidget.dart';
import 'package:untitled1/controller/EntryPage_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:untitled1/LanguageWidget.dart';

class EntryPage extends StatelessWidget {
  final EntryController entryController;

  const EntryPage({super.key, required this.entryController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          actions: [LanguagePickerWidget()],
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white),
        ),
        body: LayoutBuilder(
            builder: (context, constraints) {
              var screenHeight = constraints.maxHeight;
              var screenWidth = constraints.maxWidth;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                  ),
                  child: Stack(
                    children: <Widget>[
                      // Hintergrundbild
                      Opacity(
                        opacity: 0.6,
                        child: Container(
                          height: screenHeight,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/GruppeBild.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Hauptinhalt zentriert
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: screenHeight * (screenWidth > 600 ? 0.25 : 0.3)), // Erhöht, um die Nachricht weiter nach unten zu verschieben

                            // Willkommensnachricht
                            Text(
                              AppLocalizations.of(context)!.welcomeMessage,
                              style: TextStyle(
                                fontSize: screenWidth * (screenWidth > 600 ? 0.08 : 0.15),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: screenHeight * 0.01),

                            // Bild
                            Image.asset(
                              'assets/images/startImage4.png',
                              width: screenWidth * (screenWidth > 600 ? 0.3 : 0.4),
                              height: screenHeight * (screenWidth > 600 ? 0.15 : 0.2),
                            ),

                            SizedBox(height: screenHeight * 0.01),

                            // Buttons
                            ElevatedButton(
                              onPressed: () {
                                entryController.navigateToLogin(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(screenWidth * (screenWidth > 600 ? 0.5 : 0.6), screenHeight * (screenWidth > 600 ? 0.07 : 0.1)),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.withLogin,
                                style: TextStyle(fontSize: screenWidth * (screenWidth > 600 ? 0.04 : 0.05)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                entryController.navigateToMealPlanOverview(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(screenWidth * (screenWidth > 600 ? 0.5 : 0.6), screenHeight * (screenWidth > 600 ? 0.07 : 0.1)),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.withoutLogin,
                                style: TextStyle(fontSize: screenWidth * (screenWidth > 600 ? 0.04 : 0.05)),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                      // Sprachwechsel in der Ecke, etwas weiter nach unten und rechts verschoben
                      Positioned(
                        top: screenHeight * (screenWidth > 600 ? 0.1 : 0.08), // Weiter nach unten
                        right: screenWidth * (screenWidth > 600 ? 0.01 : 0.025), // Weiter nach rechts
                        child: LanguageWidget(),
                      ),
                    ],
                  ),
                ),
              );
            },
        ),
    ) ;
 }
}