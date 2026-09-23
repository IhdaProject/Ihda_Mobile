class ImportantDateItem {
  final String id;
  final String title;
  final String hijriDate;
  final String gregorianDate;
  final DateTime eventDate;
  final String description;
  final String category; // "Hayit", "Muborak kecha", "Muhim sana"

  const ImportantDateItem({
    required this.id,
    required this.title,
    required this.hijriDate,
    required this.gregorianDate,
    required this.eventDate,
    required this.description,
    required this.category,
  });

  String get countdownLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(eventDate.year, eventDate.month, eventDate.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) {
      return 'Bugun!';
    } else if (diff == 1) {
      return 'Ertaga';
    } else if (diff > 1) {
      return '$diff kundan keyin';
    } else {
      return 'O\'tib ketdi';
    }
  }
}
