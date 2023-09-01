import 'package:expo_nomade/quiz/quiz_email_sender.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final Function() redoQuiz;

  const QuizResultScreen({ super.key, required this.score, required this.totalQuestions, required this.redoQuiz});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Quiz terminé'),
        Text('Score: $score/$totalQuestions'),
        ElevatedButton(
          onPressed: () {
            redoQuiz();
          },
          child: const Text('Refaire le test'),
        ),
        ScoreEmailSender(
          score: score
        ),
      ],
    );
  }
}