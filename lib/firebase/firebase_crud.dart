import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/question_models.dart';


//////////////////////////////////// QUIZ //////////////////////////////////////

class QuestionCRUDHandler {
  final FirebaseDatabase database;

  QuestionCRUDHandler({required this.database});

  Future<List<Question>> fetchQuestions() async {
    List<Question> questions = [];

    try {
      DatabaseEvent event = await database.ref().child('quiz').once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        questions = data.entries
            .map((entry) {
          String questionId = entry.key;
          Map<String, dynamic> questionData = Map<String, dynamic>.from(entry.value);
          return Question(
            id: questionId,
            questionText: questionData['questionText'] ?? '',
            answers: List<String>.from(questionData['answers'] ?? []),
            correctAnswer: questionData['correctAnswer'] ?? 0,
          );
        })
            .toList();
      }
    } catch (error) {
      print('Error fetching questions: $error');
    }

    return questions;
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await database.ref().child('quiz').child(questionId).remove();
    } catch (error) {
      print('Error deleting question: $error');
    }
  }
}