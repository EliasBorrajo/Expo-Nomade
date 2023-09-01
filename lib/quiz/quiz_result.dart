import 'package:expo_nomade/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Quiz terminé'),
        Text('Score: $score/$totalQuestions'),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuizScreen()),
            );// Retour à l'écran du quiz
          },
          child: const Text('Refaire le test'),
        ),
      ],
    );
  }
}