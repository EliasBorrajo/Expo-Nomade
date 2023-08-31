import 'package:flutter/material.dart';

import '../../dataModels/quiz_models.dart';

class QuestionDetailPage extends StatelessWidget {
  final Question question;

  const QuestionDetailPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // TODO: Ajoutez ici la logique d'édition de la question
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // TODO: Ajoutez ici la logique de suppression de la question
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question: ${question.questionText}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Answers:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < question.answers.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          i == question.correctAnswer ? Icons.check_circle : Icons.circle,
                          color: i == question.correctAnswer ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(question.answers[i].answerText),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}