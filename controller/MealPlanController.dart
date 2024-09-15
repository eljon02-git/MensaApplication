import '../model/MealPlan_model.dart';
import '../model/Database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MealPlanController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addMeal(Meal meal) async {
    // Debugging: Prüfen, ob alle Felder korrekt sind
    print("Adding meal: ${meal.mealName}, ${meal.mealType}, ${meal.price}, ${meal.weekDayId}");

    // Füge die Mahlzeit in die Datenbank ein
    return await _dbHelper.addMeal(meal.toMap());
  }
  Future<void> updateMealGlobally({
    required String mealName,
    required String newMealName,
    required double newPrice,
    required String newType,
  }) async {
    // Aktualisiere alle Mahlzeiten mit dem gegebenen mealName
    await _dbHelper.updateMealGlobally(mealName, newMealName, newPrice, newType);
  }

  Future<List<Meal>> searchMeals(String query) async {
    List<Meal> meals = (await _dbHelper.getAllMeals()).cast<Meal>();

    // Filtere Mahlzeiten basierend auf der Suchanfrage
    return meals.where((meal) => meal.mealName.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<List<Meal>> getAllMeals() async {
    List<Meal> meals = (await _dbHelper.getAllMeals()).cast<Meal>();

    // Sortiere die Mahlzeiten alphabetisch nach mealName
    meals.sort((a, b) => a.mealName.compareTo(b.mealName));

    // Entferne doppelte Mahlzeiten basierend auf dem mealName
    final seen = <String>{};
    final uniqueMeals = meals.where((meal) => seen.add(meal.mealName)).toList();

    return uniqueMeals;
  }

  Future<void> initializeSampleWeeksIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isInitialized = prefs.getBool('weeks_initialized') ?? false;

    if (!isInitialized) {
      await addSampleWeeks(); // Debug-Print einfügen
      print('Sample weeks initialized');
      await prefs.setBool('weeks_initialized', true);
    } else {
      print('Weeks already initialized');
    }
  }

  Future<void> addSampleWeeks() async {
    for (int i = 1; i <= 8; i++) {
      int weekId = await addCalendarWeek(i, 2024);
      await createMealsForSampleWeek(weekId);
    }
  }

  Future<int> removeMeal(int id) async {
    return await _dbHelper.removeMeal(id);
  }
  Future<void> removeMealGlobally(String mealName, String mealType)async {
    _dbHelper.removeMealGlobally(mealName, mealType);
  }

  Future<List<Meal>> getMealsForWeek(int weekNumber, int year) async {
    List<Map<String, dynamic>> result = await _dbHelper.getMealsForWeek(weekNumber, year);
    return result.map((map) => Meal.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getMealsForDay(int dayId) async {
    // Debugging: Prüfen, ob der richtige Tag abgefragt wird
    print("Fetching meals for dayId: $dayId");

    return await _dbHelper.getMealsForDay(dayId);
  }

  Future<void> debugPrintWeeks() async {
    List<Map<String, dynamic>> weeks = await _dbHelper.getAllWeeks();
    for (var week in weeks) {
        print('Week: ${week['week_number']}, Year: ${week['year']}');
    }
  }
  Future<List<Map<String, dynamic>>> getAllWeeks() async {
    return await _dbHelper.getAllWeeks();
  }

  Future<int> addCalendarWeek(int weekNumber, int year) async {
    return await _dbHelper.addNewCalendarWeek(weekNumber, year);
  }

  Future<int> deleteCalendarWeek(int weekId) async {
    return await _dbHelper.deleteCalendarWeek(weekId);
  }

  Future<MealPlan> getMealPlanForWeek(int weekId) async {
    // Abfrage der Woche basierend auf der ID
    var week = await _dbHelper.getWeekById(weekId);

    if (week.isEmpty) {
      throw Exception('Kalenderwoche nicht gefunden.');  // Fehlermeldung, falls die Woche nicht existiert
    }

    int weekNumber = week.first['week_number'] as int;
    int year = week.first['year'] as int;

    var days = await _dbHelper.getDaysByWeekId(weekId);
    if (days.isEmpty) {
      throw Exception('Keine Wochentage gefunden für die Woche.');  // Falls keine Tage gefunden wurden
    }

    List<WeekDay> weekDays = [];
    for (var day in days) {
      var meals = await _dbHelper.getMealsForDay(day['id']);
      List<Meal> mealList = meals.map((meal) => Meal.fromMap(meal)).toList();
      weekDays.add(WeekDay.fromMap(day, mealList));
    }

    return MealPlan(weekNumber: weekNumber, year: year, weekDays: weekDays);
  }




  Future<void> createSampleMeals(int weekDayId, BuildContext context) async {
    List<Meal> sampleMeals = [
      Meal(weekDayId: 0, mealName: "Chicken Sandwich", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 5.99),
      Meal(weekDayId: 0, mealName: "Veggie Burger", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 4.99),
      Meal(weekDayId: 0, mealName: "Pasta Bolognese", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 6.49),
      Meal(weekDayId: 0, mealName: "Caesar Salad", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 3.99),
      Meal(weekDayId: 0, mealName: "Margherita Pizza", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 5.49),
      Meal(weekDayId: 0, mealName: "Sushi Roll", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 7.99),
      Meal(weekDayId: 0, mealName: "Grilled Cheese Sandwich", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 4.49),
      Meal(weekDayId: 0, mealName: "Beef Steak", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 10.99),
      Meal(weekDayId: 0, mealName: "Falafel Wrap", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 4.99),
      Meal(weekDayId: 0, mealName: "Chicken Caesar Salad", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 6.49),
      Meal(weekDayId: 0, mealName: "Vegetable Stir Fry", mealType: AppLocalizations.of(context)!.mealTypeVegan, price: 5.99),
      Meal(weekDayId: 0, mealName: "Spaghetti Carbonara", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 6.99),
      Meal(weekDayId: 0, mealName: "Tuna Salad", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 5.99),
      Meal(weekDayId: 0, mealName: "Minestrone Soup", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 3.99),
      Meal(weekDayId: 0, mealName: "Cheeseburger", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 6.49),
      Meal(weekDayId: 0, mealName: "Avocado Toast", mealType:  AppLocalizations.of(context)!.mealTypeVegan, price: 4.99),
      Meal(weekDayId: 0, mealName: "Salmon Fillet", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 9.99),
      Meal(weekDayId: 0, mealName: "Quinoa Salad", mealType: AppLocalizations.of(context)!.mealTypeVegan, price: 5.49),
      Meal(weekDayId: 0, mealName: "Vegetarian Lasagna", mealType: AppLocalizations.of(context)!.mealTypeVegetarian, price: 6.49),
      Meal(weekDayId: 0, mealName: "Chicken Nuggets", mealType: AppLocalizations.of(context)!.mealTypeWithMeat, price: 4.99),
    ];


    // Wähle zufällig 3 Mahlzeiten aus der Liste aus
    sampleMeals.shuffle();
    List<Meal> selectedMeals = sampleMeals.take(3).toList();

    for (Meal meal in selectedMeals) {
      await addMeal(meal);
    }
  }

  Future<List<Map<String, dynamic>>> getDaysByWeekId(int weekId) async {
    return await _dbHelper.getDaysByWeekId(weekId);
  }

  Future<void> createMealsForSampleWeek(int weekId) async {
    List<int> weekDayIds = [];

    // Lade die IDs der Wochentage für die übergebene Woche
    var days = await getDaysByWeekId(weekId);
    for (var day in days) {
      weekDayIds.add(day['id'] as int);
    }

    // Füge Beispielmahlzeiten für jeden Tag der Woche hinzu
    for (int dayId in weekDayIds) {
      List<Meal> existingMeals = (await getMealsForDay(dayId)).cast<Meal>();
      if (existingMeals.isEmpty) {
        await createSampleMeals(dayId);
      }
    }
  }

  Future<void> deleteWeek(int weekNumber, int year) async {
    await _dbHelper.deleteWeek(weekNumber, year);
  }
  Future<String?> addMealToDay(int weekDayId, Meal meal) async {
    // Überprüfen, ob die Mahlzeit bereits an diesem Tag existiert
    bool mealExists = await _dbHelper.mealExistsForDay(weekDayId, meal.mealName);

    if (mealExists) {
      // Gib eine Nachricht zurück, falls die Mahlzeit bereits existiert
      return "Die Mahlzeit existiert bereits für diesen Tag.";
    }

    // Mahlzeit hinzufügen, da sie nicht existiert
    await _dbHelper.addMealToDay(weekDayId, meal.mealName, meal.mealType, meal.price);

    return null; // Keine Fehlermeldung
  }


}
