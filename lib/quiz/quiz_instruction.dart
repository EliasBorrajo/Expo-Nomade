import 'package:flutter/material.dart';

class QuizInstructionsPopup extends StatelessWidget {
  const QuizInstructionsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Instructions'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Bienvenue au quiz de 10 questions pour évaluer vos connaissances.'),
            SizedBox(height: 16),
            Text('Règles du quiz :'),
            SizedBox(height: 8),
            Text('1. Vous avez 10 questions à répondre.'),
            Text('2. Pour chaque question, il y a trois choix de réponses, dont une seule est correcte.'),
            Text('3. À la fin du quiz, vous pouvez renseigner votre e-mail pour peut-être gagner des cadeaux.'),
            SizedBox(height: 16),
            Text('Bonne chance !'),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Continuer'),
        ),
      ],
    );
  }
}
