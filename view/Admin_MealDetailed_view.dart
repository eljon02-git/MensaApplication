import 'package:flutter/material.dart';
import '../controller/MealPlanController.dart';
import '../model/MealPlan_model.dart';

class MealDetailView extends StatefulWidget {
  final Meal meal;
  final Function onMealDeleted;  // Callback, falls die Mahlzeit gelöscht wird

  const MealDetailView({required this.meal, required this.onMealDeleted});

  @override
  _MealDetailViewState createState() => _MealDetailViewState();
}

class _MealDetailViewState extends State<MealDetailView> {
  final MealPlanController _mealController = MealPlanController();
  late String editedName;
  late double editedPrice;
  late String editedType;

  // Zustände für die Bearbeitungsansicht
  bool isEditingName = false;
  bool isEditingPrice = false;
  bool isEditingType = false;

  @override
  void initState() {
    super.initState();
    editedName = widget.meal.mealName;
    editedPrice = widget.meal.price;
    editedType = widget.meal.mealType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
                Navigator.pop(context, true);  // Gebe true zurück, wenn Änderungen gespeichert wurden
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Name:', style: TextStyle(fontSize: 18)),
                isEditingName
                    ? Expanded(
                  child: TextField(
                    onChanged: (value) {
                      editedName = value;
                    },
                    decoration: const InputDecoration(hintText: "Meal Name"),
                    controller: TextEditingController(text: editedName),
                  ),
                )
                    : Text(editedName, style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(isEditingName ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditingName = !isEditingName;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Preis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preis:', style: TextStyle(fontSize: 18)),
                isEditingPrice
                    ? Expanded(
                  child: TextField(
                    onChanged: (value) {
                      editedPrice = double.tryParse(value) ?? editedPrice;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Meal Price"),
                    controller: TextEditingController(text: editedPrice.toStringAsFixed(2)),
                  ),
                )
                    : Text('${editedPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(isEditingPrice ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditingPrice = !isEditingPrice;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Typ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Typ:', style: TextStyle(fontSize: 18)),
                isEditingType
                    ? Expanded(
                  child: DropdownButton<String>(
                    value: editedType,
                    items: ['Mit Fleisch', 'Vegan', 'Vegetarisch']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        editedType = newValue!;
                      });
                    },
                  ),
                )
                    : Text(editedType, style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(isEditingType ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditingType = !isEditingType;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Speichern der Änderungen
  Future<bool> _saveChanges() async {
    if (editedName.isNotEmpty && editedPrice > 0) {
      // Ändere den globalen Wert der Mahlzeiten im Controller
      await _mealController.updateMealGlobally(
        mealName: widget.meal.mealName,
        newMealName: editedName,
        newPrice: editedPrice,
        newType: editedType,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Änderungen gespeichert.')),
      );
      return true;  // Gib true zurück, wenn die Änderungen erfolgreich waren
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler: Name und Preis müssen gültig sein.')),
      );
      return false;  // Gib false zurück, wenn ein Fehler auftritt
    }
  }

}
