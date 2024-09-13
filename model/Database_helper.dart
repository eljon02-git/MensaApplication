import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'MealPlan_model.dart';

class DatabaseHelper {
  // Singleton pattern for DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const _databaseName = "MealPlanDB.db";
  static const _databaseVersion = 1;

  // Table names
  static const tableCalendarWeeks = 'calendar_weeks';
  static const tableWeekDays = 'week_days';
  static const tableMeals = 'meals';

  // Getter für die Datenbankinstanz
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // Initialisierung der Datenbank
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      print('Database initialized on web');
      // Für das Web: databaseFactory explizit setzen
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        _databaseName,  // oder wähle einen eindeutigen Pfad
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
        ),
      );
    } else {
      String path = join(await getDatabasesPath(), _databaseName);
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    }
  }

  // Erstellen der Tabellen in der Datenbank
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE calendar_weeks (
      id INTEGER PRIMARY KEY,
      week_number INTEGER NOT NULL,
      year INTEGER NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    await db.execute('''
    CREATE TABLE week_days (
      id INTEGER PRIMARY KEY,
      calendar_week_id INTEGER NOT NULL,
      day_name TEXT NOT NULL,
      
      day_date DATE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (calendar_week_id) REFERENCES calendar_weeks (id)
    )
  ''');

    await db.execute('''
    CREATE TABLE meals (
      id INTEGER PRIMARY KEY,
      week_day_id INTEGER NOT NULL,
      meal_name TEXT NOT NULL,
      meal_type TEXT,
      price REAL NOT NULL,  
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (week_day_id) REFERENCES week_days (id)
    )
  ''');
  }
  Future<void> printAllWeeks() async {
    Database? db = await instance.database;
    var allWeeks = await db!.query(tableCalendarWeeks);
    print("Aktuelle Wochen in der Datenbank: $allWeeks");
  }
  Future<void> updateMealGlobally(String oldName, String newName, double newPrice, String newType) async {
    Database? db = await instance.database;

    // Aktualisiere alle Mahlzeiten mit dem alten Namen
    await db!.update(
      'meals',
      {'meal_name': newName, 'price': newPrice, 'meal_type': newType},
      where: 'meal_name = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> removeMealGlobally(String mealName, String mealType) async {
    Database? db = await instance.database;

    // Lösche alle Mahlzeiten, die diesen Namen und diesen Typ haben
    await db!.delete(
      tableMeals,
      where: 'meal_name = ? AND meal_type = ?',
      whereArgs: [mealName, mealType],
    );
  }
  Future<int> addMealToDay(int weekDayId, String mealName, String mealType, double price) async {
    Database? db = await instance.database;

    // Bereite die Mahlzeit-Daten als Map vor
    Map<String, dynamic> mealData = {
      'week_day_id': weekDayId,
      'meal_name': mealName,
      'meal_type': mealType,
      'price': price,
    };

    // Füge die Mahlzeit zur Datenbank hinzu (id wird automatisch generiert)
    return await db!.insert(tableMeals, mealData);
  }
  Future<bool> mealExistsForDay(int weekDayId, String mealName) async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> result = await db!.query(
      tableMeals,
      where: 'week_day_id = ? AND meal_name = ?',
      whereArgs: [weekDayId, mealName],
    );

    return result.isNotEmpty; // true, wenn die Mahlzeit existiert, sonst false
  }


  // Methode zum Hinzufügen einer Mahlzeit
  Future<int> addMeal(Map<String, dynamic> row) async {
    Database? db = await instance.database;

    // Debugging: Prüfen, ob die Daten korrekt sind
    print("Inserting meal: $row");

    return await db!.insert(tableMeals, row);
  }

  // Methode zum Entfernen einer Mahlzeit
  Future<int> removeMeal(int id) async {
    Database? db = await instance.database;
    return await db!.delete(tableMeals, where: 'id = ?', whereArgs: [id]);
  }

  // Methode zum Abrufen aller Mahlzeiten für eine bestimmte Woche
  Future<List<Map<String, dynamic>>> getMealsForWeek(int weekNumber, int year) async {
    Database? db = await instance.database;

    // Kalenderwoche abfragen
    var week = await db!.query(
      tableCalendarWeeks,
      where: 'week_number = ? AND year = ?',
      whereArgs: [weekNumber, year],
    );

    if (week.isEmpty) {
      throw Exception('Kalenderwoche nicht gefunden.');
    }

    int weekId = week.first['id'] as int;

    // Alle Tage dieser Woche abfragen
    var days = await db.query(tableWeekDays, where: 'calendar_week_id = ?', whereArgs: [weekId]);

    List<Map<String, dynamic>> meals = [];
    for (var day in days) {
      var dayMeals = await db.query(tableMeals, where: 'week_day_id = ?', whereArgs: [day['id']]);
      meals.addAll(dayMeals);
    }

    return meals;
  }
  Future<List<Meal>> getAllMeals() async {
    Database? db = await instance.database;
    final List<Map<String, dynamic>> result = await db!.query(tableMeals);

    // Konvertiere die Maps in eine Liste von Meal-Objekten
    return result.map((mealData) => Meal.fromMap(mealData)).toList();
  }

  // Methode zum Abrufen aller Mahlzeiten für einen bestimmten Tag
  Future<List<Map<String, dynamic>>> getMealsForDay(int dayId) async {
    Database? db = await instance.database;
    return await db!.query(tableMeals, where: 'week_day_id = ?', whereArgs: [dayId]);
  }

  // Methode zum Abrufen einer Woche nach Nummer und Jahr
  Future<List<Map<String, dynamic>>> getWeekByNumberAndYear(int weekNumber, int year) async {
    Database? db = await instance.database;
    return await db!.query(
      tableCalendarWeeks,
      where: 'week_number = ? AND year = ?',
      whereArgs: [weekNumber, year],
    );
  }

  // Methode zum Abrufen der Tage einer bestimmten Woche
  Future<List<Map<String, dynamic>>> getDaysByWeekId(int weekId) async {
    Database? db = await instance.database;
    return await db!.query(tableWeekDays, where: 'calendar_week_id = ?', whereArgs: [weekId]);
  }


  // Methode zum Hinzufügen einer neuen Woche
  Future<int> addNewCalendarWeek(int weekNumber, int year) async {
    Database? db = await instance.database;

    // Überprüfe, ob die Woche bereits existiert
    var existingWeek = await db!.query(
      tableCalendarWeeks,
      where: 'week_number = ? AND year = ?',
      whereArgs: [weekNumber, year],
    );

    if (existingWeek.isNotEmpty) {
      throw Exception('Kalenderwoche existiert bereits.');
    }

    // Füge die Woche hinzu, wenn sie nicht existiert
    Map<String, dynamic> calendarWeek = {
      'week_number': weekNumber,
      'year': year,
    };
    int weekId = await db.insert(tableCalendarWeeks, calendarWeek);

    // Füge die Wochentage hinzu
    await createWeekDays(weekId, year, weekNumber);

    return weekId;
  }
  Future<List<Map<String, dynamic>>> getWeekById(int weekId) async {
    Database? db = await instance.database;

    // Abfrage der Woche basierend auf ihrer ID
    return await db!.query(
      tableCalendarWeeks,
      where: 'id = ?',
      whereArgs: [weekId],
    );
  }

  // Methode zum Berechnen des ersten Tages der Woche
  DateTime _firstDayOfWeek(int year, int weekNumber) {
    DateTime jan4 = DateTime(year, 1, 4);
    int diff = jan4.weekday - DateTime.monday;
    return jan4.subtract(Duration(days: diff)).add(Duration(days: (weekNumber - 1) * 7));
  }


  // Methode zum Löschen einer Woche
  Future<int> deleteCalendarWeek(int weekId) async {
    Database? db = await instance.database;

    // Lösche zunächst alle Mahlzeiten der Tage dieser Woche
    var days = await db!.query(tableWeekDays, where: 'calendar_week_id = ?', whereArgs: [weekId]);
    for (var day in days) {
      await db.delete(tableMeals, where: 'week_day_id = ?', whereArgs: [day['id']]);
    }

    // Lösche dann die Tage
    await db.delete(tableWeekDays, where: 'calendar_week_id = ?', whereArgs: [weekId]);

    // Schließlich lösche die Woche selbst
    return await db.delete(tableCalendarWeeks, where: 'id = ?', whereArgs: [weekId]);
  }


  Future<List<Map<String, dynamic>>> getAllWeeks() async {
    Database? db = await instance.database;
    return await db!.query('calendar_weeks');  // Gibt alle Wochen mit ID, Woche und Jahr zurück
  }

  Future<void> deleteWeek(int weekNumber, int year) async {
    await printAllWeeks(); // Zustand der Wochen vor dem Löschen

    Database? db = await instance.database;

    var weeks = await db!.query(
      tableCalendarWeeks,
      where: 'week_number = ? AND year = ?',
      whereArgs: [weekNumber, year],
    );

    if (weeks.isNotEmpty) {
      int weekId = weeks.first['id'] as int;
      await deleteCalendarWeek(weekId);
    }

    await printAllWeeks(); // Zustand der Wochen nach dem Löschen
  }
  Future<void> createWeekDays(int weekId, int year, int weekNumber) async {
    Database? db = await instance.database;

    // Liste der Wochentage
    List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    // Berechne das Datum des ersten Tages der Woche (Montag)
    DateTime startOfWeek = _firstDayOfWeek(year, weekNumber);

    // Füge jeden Wochentag zur Datenbank hinzu
    for (int i = 0; i < 5; i++) {
      Map<String, dynamic> day = {
        'calendar_week_id': weekId,
        'day_name': weekDays[i],
        'day_date': startOfWeek.add(Duration(days: i)).toIso8601String(),
      };
      await db!.insert(tableWeekDays, day);
    }
  }
}