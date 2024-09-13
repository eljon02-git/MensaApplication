import 'package:flutter/material.dart';
import '../controller/MealPlanController.dart';
import '../model/MealPlan_model.dart';

class AddMealPage extends StatefulWidget {
  final int dayId; // Der ausgewählte Tag (weekDayId)

  AddMealPage({required this.dayId});

  @override
  _AddMealPageState createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final MealPlanController _mealController = MealPlanController();
  final TextEditingController _searchController = TextEditingController();

  List<Meal> _allMeals = [];
  List<Meal> _filteredMeals = [];

  @override
  void initState() {
    super.initState();
    _loadAllMeals(); // Lade alle Mahlzeiten, wenn die Seite startet
  }

  // Lade alle Mahlzeiten und setze die Liste der gefilterten Mahlzeiten auf die vollständige Liste
  Future<void> _loadAllMeals() async {
    List<Meal> meals = await _mealController.getAllMeals();
    setState(() {
      _allMeals = meals;
      _filteredMeals = meals; // Anfangs alle Mahlzeiten anzeigen
    });
  }

  // Filtere die Mahlzeiten basierend auf der Benutzereingabe
  void _filterMeals(String query) {
    setState(() {
      _filteredMeals = _allMeals.where((meal) {
        return meal.mealName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahlzeit auswählen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Suchfeld
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Mahlzeit suchen',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterMeals, // Filtere die Liste basierend auf der Eingabe
            ),
            const SizedBox(height: 16.0),
            // Liste der Mahlzeiten
            Expanded(
              child: _filteredMeals.isEmpty
                  ? Center(child: Text('Keine Mahlzeiten gefunden'))
                  : ListView.builder(
                itemCount: _filteredMeals.length,
                itemBuilder: (context, index) {
                  final meal = _filteredMeals[index];
                  return ListTile(
                    title: Text(meal.mealName),
                    subtitle: Text('${meal.mealType} - ${meal.price}€'),
                    onTap: () async {
                      // Füge die ausgewählte Mahlzeit dem Tag hinzu
                      String? error = await _mealController.addMealToDay(widget.dayId, meal);

                      if (error != null) {
                        // Zeige eine Fehlermeldung an, wenn die Mahlzeit bereits existiert
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        // Aktualisiere die vorherige Seite und kehre zurück
                        Navigator.of(context).pop(true);// 'true' signalisiert, dass etwas geändert wurde
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Änderungen wurden gespeichert')));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
