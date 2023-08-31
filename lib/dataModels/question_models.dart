class Question {
  String id;
  String questionText;
  List<String> answers;
  int correctAnswer;

  Question({
    required this.id,
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
    );
  }
}