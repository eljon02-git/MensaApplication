class CalendarWeek {
  final int? id;
  final int weekNumber;
  final int year;

  CalendarWeek({this.id, required this.weekNumber, required this.year});

  factory CalendarWeek.fromMap(Map<String, dynamic> json) => CalendarWeek(
    id: json['id'],
    weekNumber: json['week_number'],
    year: json['year'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'week_number': weekNumber,
      'year': year,
    };
  }
}