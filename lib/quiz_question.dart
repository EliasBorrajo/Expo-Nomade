class Question {
  final String questionText;
  final List<String> answers;
  final int correctAnswer;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
    );
  }

}