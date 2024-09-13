import 'package:flutter/material.dart';
import '../controller/MealPlanController.dart';
import '../model/MealPlan_model.dart';

class AddNewMealPage extends StatefulWidget {
  const AddNewMealPage({super.key});

  @override
  _AddNewMealPageState createState() => _AddNewMealPageState();
}

class _AddNewMealPageState extends State<AddNewMealPage> {
  final MealPlanController _mealController = MealPlanController();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _mealPriceController = TextEditingController();

  // Standardwert für das Dropdown
  String _selectedMealType = 'Mit Fleisch';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Mahlzeit hinzufügen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Textfeld für den Mahlzeit-Namen
            TextField(
              controller: _mealNameController,
              decoration: const InputDecoration(
                labelText: 'Mahlzeit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // DropdownButton für den Mahlzeit-Typ
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: const InputDecoration(
                labelText: 'Mahlzeit Typ',
                border: OutlineInputBorder(),
              ),
              items: ['Mit Fleisch', 'Vegetarisch', 'Vegan'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMealType = newValue!;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Textfeld für den Mahlzeit-Preis
            TextField(
              controller: _mealPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Button zum Hinzufügen der Mahlzeit
            ElevatedButton(
              onPressed: () async {
                // Erstellen einer neuen Mahlzeit
                final mealName = _mealNameController.text;
                final mealPrice = double.tryParse(_mealPriceController.text) ?? 0.0;

                // Hier fügen wir die Mahlzeit in das Modell ein
                if(mealName.isNotEmpty && mealPrice != 0.0) { //Felder müssen ausgefüllt sein
                  Meal newMeal = Meal(
                    weekDayId: 0,
                    // Woche 0 bedeutet, dass es keine spezifische Woche gibt
                    mealName: mealName,
                    mealType: _selectedMealType,
                    // Verwende den ausgewählten Typ
                    price: mealPrice,
                  );
                  // Mahlzeit zum Modell hinzufügen
                  await _mealController.addMeal(newMeal);

                  // Zurück zur vorherigen Seite navigieren
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Die Mahlzeit wurde erfolgreich hinzugefügt')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alle Felder müssen ausgefüllt werden')));
                }
              },
              child: const Text('Mahlzeit hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}
