class Question {
  String id;
  String questionText;
  List<Answer> answers;
  int correctAnswer;

  Question({
    required this.id,
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
  });
}

class Answer {
  String answerText;

  Answer({
   required this.answerText
  });
}