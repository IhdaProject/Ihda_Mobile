class QuizQuestion {
  final String id;
  final String headerTitle; // "Bugungi savol" yoki "Haftalik savol"
  final String questionText;
  final int points;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.id,
    required this.headerTitle,
    required this.questionText,
    required this.points,
    required this.options,
    required this.correctIndex,
  });

  static const sampleToday = QuizQuestion(
    id: 'q_1',
    headerTitle: 'Bugungi savol',
    questionText: 'Islomda ilk azon aytgan sahoba kim edilar?',
    points: 20,
    options: [
      'Hazrati Abu Bakr Siddiq ro\'ziyallohu anhu',
      'Bilol ibn Raboh ro\'ziyallohu anhu',
      'Hazrati Umar ibn Xattob ro\'ziyallohu anhu',
      'Usmon ibn Affon ro\'ziyallohu anhu',
    ],
    correctIndex: 1,
  );
}
