import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../controller/MealPlanController.dart';
import '../model/MealPlan_model.dart';
import 'AddMealPage.dart';
import 'AddNewMealPage.dart';
import 'AddWeekPage.dart';
import 'MealDetailed_view.dart';

class AdminMealplanOverview extends StatefulWidget {
  const AdminMealplanOverview({super.key});

  @override
  MealPlanOverviewPageState createState() => MealPlanOverviewPageState();
}

class MealPlanOverviewPageState extends State<AdminMealplanOverview> {
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
      if (kDebugMode) {
        print("Available Weeks: $availableWeeks");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fehler beim Laden der Wochen: $e');
      }
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
                'Essensplan',
                style: TextStyle(
                  fontSize: 20.0, // Passe die Schriftgröße an, um Platz zu sparen
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Keine Mahlzeiten vorhanden.'));
          }

          MealPlan mealPlan = snapshot.data!;

          return ListView.builder(
            cacheExtent: 1000.0,
            itemCount: mealPlan.weekDays.length,
            itemBuilder: (context, index) {
              WeekDay day = mealPlan.weekDays[index];
              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${day.dayName} - ${day.dayDate.toLocal().toString().split(' ')[0]}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _navigateToAddMealPage(day.id);
                      },
                    ),
                  ],
                ),
                children: day.meals.map((meal) {
                  return ListTile(
                    title: Text(meal.mealName),
                    subtitle: Text('${meal.mealType} - ${meal.price}€'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _mealController.removeMeal(meal.id!);
                        _refreshMealPlan();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Die Mahlzeit wurde erfolgreich entfernt.')));
                      },
                    ),
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
          : const Center(child: Text('Keine Wochen verfügbar.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFabMenu(context);
        },
        child: const Icon(Icons.more_vert),
      ),
    );
  }

  void _showFabMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Neue Woche hinzufügen'),
              onTap: () async {
                Navigator.pop(context);
                    final newWeekId = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (context) => AddWeekPage()),
                );

                if (newWeekId != null) {
                  setState(() {
                    selectedWeekId = newWeekId;
                  });
                  await loadAvailableWeeks();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Aktuelle Woche löschen'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteWeek(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Neue Mahlzeit hinzufügen'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddNewMealPage(context);
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToMealDetailView(BuildContext context, Meal meal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailView(
          meal: meal,
          onMealEdited: _refreshMealPlan,  // Wenn die Mahlzeit gelöscht wird, aktualisiere
        ),
      ),
    );

    if (result == true) {
      // Lade die Daten erneut und aktualisiere den Zustand, um das UI zu aktualisieren.
      await loadAvailableWeeks();
      setState(() {});
    }
  }


  void _navigateToAddNewMealPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewMealPage()),
    );
  }

  void _navigateToAddMealPage(int selectedDayId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMealPage(dayId: selectedDayId)),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _confirmDeleteWeek(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Woche löschen?'),
          content: const Text('Möchten Sie diese Woche wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () async {
                await deleteCurrentWeek();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Die Woche wurde erfolgreich gelöscht')));
              },
            ),
          ],
        );
      },
    );
  }
}
