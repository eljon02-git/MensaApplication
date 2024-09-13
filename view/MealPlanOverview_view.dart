import 'package:flutter/material.dart';
import '../controller/MealPlanController.dart';
import '../model/MealPlan_model.dart';
import 'MealDetailed_view.dart';

class MealPlanOverviewPage extends StatefulWidget {

  @override
  _MealPlanOverviewPageState createState() => _MealPlanOverviewPageState();
}

class _MealPlanOverviewPageState extends State<MealPlanOverviewPage> {
  final MealPlanController _mealController = MealPlanController();
  int selectedWeekId = 1; // Start mit der ersten Woche als Beispiel
  int year = 2024;
  List<Map<String, dynamic>> availableWeeks = []; // Statt List<int>

  @override
  void initState() {
    super.initState();
    loadAvailableWeeks(); // Lade die verfügbaren Wochen aus der Datenbank
    _mealController.debugPrintWeeks(); // Debugging
  }

  Future<void> loadAvailableWeeks() async {
    try {
      List<Map<String, dynamic>> weeks = await _mealController.getAllWeeks();

      if (weeks.isNotEmpty) {
        setState(() {
          availableWeeks = List.from(weeks)
            ..sort((a, b) {
              int yearComparison = a['year'].compareTo(b['year']);
              if (yearComparison != 0) return yearComparison;
              return a['week_number'].compareTo(b['week_number']);
            });

          // Falls die ausgewählte Woche nicht existiert, wähle die erste Woche
          if (!availableWeeks.any((week) => week['id'] == selectedWeekId)) {
            selectedWeekId = availableWeeks.isNotEmpty ? availableWeeks.first['id'] : 0;
          }
        });
      } else {
        setState(() {
          availableWeeks = [];
          selectedWeekId = 0;
        });
      }
      print("Available Weeks: $availableWeeks");
    } catch (e) {
      print('Fehler beim Laden der Wochen: $e');
    }
  }

  Future<void> deleteCurrentWeek() async {
    await _mealController.deleteCalendarWeek(selectedWeekId);
    await loadAvailableWeeks();
  }

  void _refreshMealPlan() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'Meal Plan Overview',
                style: TextStyle(
                  fontSize: 25.0, // Passe die Schriftgröße an, um Platz zu sparen
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Text in einer Zeile behalten und abschneiden, wenn nötig
              ),
            ),
            if (availableWeeks.isNotEmpty)
              DropdownButton<int>(
                value: selectedWeekId,
                items: availableWeeks.map((week) {
                  return DropdownMenuItem<int>(
                    value: week['id'],
                    child: Text('Woche ${week['week_number']} (${week['year']})'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedWeekId = newValue!;
                  });
                },
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: availableWeeks.isNotEmpty
          ? FutureBuilder<MealPlan>(
        future: _mealController.getMealPlanForWeek(selectedWeekId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Keine Mahlzeiten vorhanden.'));
          }

          MealPlan mealPlan = snapshot.data!;

          return ListView.builder(
            itemCount: mealPlan.weekDays.length,
            itemBuilder: (context, index) {
              WeekDay day = mealPlan.weekDays[index];
              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${day.dayName} - ${day.dayDate.toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                children: day.meals.map((meal) {
                  return ListTile(
                    title: Text(meal.mealName),
                    subtitle: Text('${meal.mealType} - ${meal.price}€'),
                    onTap: () {
                      _navigateToMealDetailView(context, meal);
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      )
          : Center(child: Text('Keine Wochen verfügbar.')),
    );
  }


  _navigateToMealDetailView(BuildContext context, Meal meal) {
    final result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailView(
          meal: meal,
          onMealEdited: _refreshMealPlan,
        ),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }
}
