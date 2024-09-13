class Meal {
  final int? id;
  late final int weekDayId;
  final String mealName;
  final String mealType;
  final double price;

  Meal({
    this.id,
    required this.weekDayId,
    required this.mealName,
    required this.mealType,
    required this.price,
  });

  factory Meal.fromMap(Map<String, dynamic> json) => Meal(
    id: json['id'],
    weekDayId: json['week_day_id'],
    mealName: json['meal_name'],
    mealType: json['meal_type'],
    price: json['price'] != null ? json['price'] as double : 0.0,  // Standardwert 0.0, falls null
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'week_day_id': weekDayId,
      'meal_name': mealName,
      'meal_type': mealType,
      'price': price,
    };
  }
}


class WeekDay {
  final int id;
  final String dayName;
  final DateTime dayDate;
  final List<Meal> meals;

  WeekDay({required this.id, required this.dayName, required this.dayDate, required this.meals});

  factory WeekDay.fromMap(Map<String, dynamic> json, List<Meal> meals) => WeekDay(
    id: json['id'],
    dayName: json['day_name'],
    dayDate: DateTime.parse(json['day_date']),
    meals: meals,
  );
}

class MealPlan {
  final int weekNumber;
  final int year;
  final List<WeekDay> weekDays;

  MealPlan({required this.weekNumber, required this.year, required this.weekDays});

  factory MealPlan.fromMaps(Map<String, dynamic> weekMap, List<WeekDay> weekDays) {
    // Filtere nur die Wochentage von Montag bis Freitag
    List<WeekDay> filteredWeekDays = weekDays.where((day) {
      // Wir nehmen an, dass 'Monday' bis 'Friday' die ersten 5 Tage in der Liste sind
      return day.dayName != 'Saturday' && day.dayName != 'Sunday';
    }).toList();

    return MealPlan(
      weekNumber: weekMap['week_number'],
      year: weekMap['year'],
      weekDays: filteredWeekDays,
    );
  }
}

List<MealPlan> generateSampleMealPlans() {
  List<MealPlan> mealPlans = [];
  List<String> weekDays = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag'];


  List<Meal> allMeals = [
    Meal(weekDayId: 0, mealName: "Chicken Sandwich", mealType: "Mit Fleisch", price: 3.49),
    Meal(weekDayId: 0, mealName: "Veggie Burger", mealType: "Vegetarisch", price: 4.99),
    Meal(weekDayId: 0, mealName: "Spaghetti Bolognese", mealType: "Mit Fleisch", price: 2.49),
    Meal(weekDayId: 0, mealName: "Caesar Salad", mealType: "Vegetarisch", price: 2.99),
    Meal(weekDayId: 0, mealName: "Pizza Margherita", mealType: "Vegetarisch", price: 4.49),
    Meal(weekDayId: 0, mealName: "Kartoffelspalten", mealType: "Vegan", price: 0.80),
    Meal(weekDayId: 0, mealName: "Käse Sandwich", mealType: "Vegetarisch", price: 1.99),
    Meal(weekDayId: 0, mealName: "Chicken Wings", mealType: "Mit Fleisch", price: 3.99),
    Meal(weekDayId: 0, mealName: "Falafel", mealType: "Vegan", price: 2.49),
    Meal(weekDayId: 0, mealName: "Pommes", mealType: "Vegan", price: 1.20),
  ];

  for (int week = 1; week <= 8; week++) {
    List<WeekDay> days = [];
    DateTime startOfWeek = DateTime(2024, 1, 1).add(Duration(days: (week - 1) * 7));

    for (int i = 0; i < 5; i++) { // Nur Montag bis Freitag
      allMeals.shuffle(); // Mische die Liste, um zufällige Mahlzeiten auszuwählen
      List<Meal> selectedMeals = allMeals.take(3).toList(); // Nimm die ersten 3 zufälligen Mahlzeiten

      // Weise den Tag zu, an dem die Mahlzeit serviert wird
      for (Meal meal in selectedMeals) {
        meal.weekDayId = i;
      }

      days.add(WeekDay(
        id: i,
        dayName: weekDays[i],
        dayDate: startOfWeek.add(Duration(days: i)),
        meals: selectedMeals,
      ));
    }

    mealPlans.add(MealPlan(
      weekNumber: week,
      year: 2024,
      weekDays: days,
    ));
  }

  return mealPlans;
}

