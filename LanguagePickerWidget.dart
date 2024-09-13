import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import für Provider
import 'package:untitled1/Locale_provider.dart';
import 'package:untitled1/l10n/l10n.dart';

class LanguagePickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hole den aktuellen Locale aus dem Provider
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        // Standardwert für das Dropdown-Menü
        value: currentLocale,
        icon: Container(width: 12),
        items: [
          // Der erste Eintrag für den Dropdown-Button mit dem Text „Choose Language“
          DropdownMenuItem<Locale>(
            value: null,
            child: Text(
              'Choose Language',
              style: TextStyle(fontSize: 16),
            ),
          ),
          // Die Sprachoptionen
          ...L10n.all.map((locale) {
            final flag = L10n.getFlag(locale.languageCode);
            return DropdownMenuItem<Locale>(
              child: Center(
                child: Text(
                  flag,
                  style: TextStyle(fontSize: 32),
                ),
              ),
              value: locale,
            );
          }).toList(),
        ],
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            final provider = Provider.of<LocaleProvider>(context, listen: false);
            provider.setLocale(newLocale);
          }
        },
      ),
    );
  }
}
