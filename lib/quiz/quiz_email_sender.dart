import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ScoreEmailSender extends StatefulWidget {
  final int score;

  const ScoreEmailSender({super.key, required this.score});

  @override
  _ScoreEmailSenderState createState() => _ScoreEmailSenderState();
}

class _ScoreEmailSenderState extends State<ScoreEmailSender> {
  final _emailController = TextEditingController();

  final _subjectController = TextEditingController(text: 'Votre score au Quiz de L\'ExpoNomade');

  Future<void> _sendScore() async {
    final userEmail = _emailController.text.trim();
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

    if (emailRegExp.hasMatch(userEmail)) {
      final Email emailMessage = Email(
        body: 'Votre score est ${widget.score}',
        subject: _subjectController.text,
        recipients: [_emailController.text],
      );

      try {
        await FlutterEmailSender.send(emailMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Score envoyé à $userEmail'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        print(error);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de l\'envoi du score : $error'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une adresse e-mail valide.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Entrez votre e-mail',
          ),
        ),
        ElevatedButton(
          onPressed: _sendScore,
          child: const Text('Envoyer le score par e-mail'),
        ),
      ],
    );
  }
}