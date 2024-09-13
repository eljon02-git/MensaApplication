import 'package:untitled1/controller/EntryPage_controller.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/view/EntryPage_view.dart';
class LanguagePageController {
  final EntryController entryController;

  LanguagePageController({
    required this.entryController,
  });

  void navigateToEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryPage(entryController: entryController),
      ),
    );
  }
}
