import 'package:intl/intl.dart';

class Week {
  final DateTime start;
  final DateTime end;

  Week(this.start, this.end);

  String getFormattedWeek() {
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  int getWeekNumber() {
    final weekYear = DateFormat('w').format(start);
    return int.parse(weekYear);
  }
}

List<Week> generateWeeks(DateTime startDate, int numberOfWeeks) {
  List<Week> weeks = [];
  for (int i = 0; i < numberOfWeeks; i++) {
    DateTime startOfWeek = startDate.add(Duration(days: i * 7));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 4)); // 5-Tage-Woche
    weeks.add(Week(startOfWeek, endOfWeek));
  }
  return weeks;
}