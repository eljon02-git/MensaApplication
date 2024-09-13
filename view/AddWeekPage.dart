import 'package:flutter/material.dart';

import '../controller/MealPlanController.dart';

class AddWeekPage extends StatefulWidget {
  @override
  _AddWeekPageState createState() => _AddWeekPageState();
}

class _AddWeekPageState extends State<AddWeekPage> {

  final MealPlanController _mealController = MealPlanController();
  final TextEditingController _weekNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neue Woche hinzufügen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _weekNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Wochennummer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jahr',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try{
                  int weekNumber = int.parse(_weekNumberController.text);
                int year = int.parse(_yearController.text);
                int weekId = await _mealController.addCalendarWeek(weekNumber, year);
                Navigator.of(context).pop(weekId);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Woche hinzugefügt')));
                } catch (error){
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Die Woche existiert bereits')));
                }

              },
              child: const Text('Woche hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}