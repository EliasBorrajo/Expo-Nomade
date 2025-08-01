import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuizResultScreen extends StatefulWidget {
  final FirebaseDatabase database;
  final int score;
  final int totalQuestions;
  final Function() redoQuiz;

  const QuizResultScreen({ super.key, required this.database, required this.score, required this.totalQuestions, required this.redoQuiz});

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController emailController = TextEditingController();
  bool isValidEmail = true;
  bool isEmailSent = false;

  void _addEmailToDatabase() async {
    final userEmail = emailController.text.trim();

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une adresse e-mail valide.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      DatabaseReference quizUserRef = widget.database.ref().child('quizPlayers');
      DatabaseReference newQuestionRef = quizUserRef.push();

      final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
      final formattedDateTime = dateFormat.format(DateTime.now());

      Map<String, dynamic> questionToUpload = {
        'userEmail': userEmail,
        'score': '${widget.score}/${widget.totalQuestions}',
        'dateTime': formattedDateTime
      };

      await newQuestionRef.set(questionToUpload);

      setState(() {
        isEmailSent = true;
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre email a été envoyé avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error adding question: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'envoie de votre email.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.stars_rounded, size: 50),
        const Text('Quiz terminé !'),
        const SizedBox(height: 32),
        Text('Votre score: ${widget.score}/${widget.totalQuestions}'),
        const SizedBox(height: 32),
        Column(
          children: [
            const Text('Entrez votre e-mail et tentez votre chance pour gagner un cadeau !'),
            SizedBox(
              width: 410.0,
              child: TextField(
                controller: emailController,
                maxLines: 1,
                onChanged: (value) {
                  setState(() {
                    isValidEmail = isValidEmailFormat(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Entrez votre e-mail',
                  errorText: isValidEmail ? null : 'E-mail invalide',
                ),
                enabled: !isEmailSent,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isEmailSent ? null : () {
                if (isValidEmail) {
                  _addEmailToDatabase();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer une adresse e-mail valide.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: const Size(200, 60),
              ),
              child: const Text(
                'Soumettre l\'e-mail',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            widget.redoQuiz();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            minimumSize: const Size(200, 60),
          ),
          child: const Text(
            'Refaire le test',
          ),
        ),
      ],
    );
  }
}