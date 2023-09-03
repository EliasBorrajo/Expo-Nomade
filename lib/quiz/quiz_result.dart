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
        const Text('Quiz terminé !', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 16),
        Text('Votre score: $score/$totalQuestions', style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            redoQuiz();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text('Refaire le test',  style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}