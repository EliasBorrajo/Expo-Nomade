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
}