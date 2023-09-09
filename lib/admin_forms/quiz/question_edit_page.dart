import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/question_models.dart';

class EditQuestionPage extends StatefulWidget {
  final FirebaseDatabase database;
  final Question question;

  const EditQuestionPage({super.key, required this.database, required this.question});

  @override
  _EditQuestionPageState createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController answer1Controller = TextEditingController();
  final TextEditingController answer2Controller = TextEditingController();
  final TextEditingController answer3Controller = TextEditingController();
  int correctAnswer = 0;

  @override
  void initState() {
    super.initState();
    questionTextController.text = widget.question.questionText;
    answer1Controller.text = widget.question.answers[0];
    answer2Controller.text = widget.question.answers[1];
    answer3Controller.text = widget.question.answers[2];
    correctAnswer = widget.question.correctAnswer;
  }

  void _updateQuestionInDatabase() async {

    final questionText = questionTextController.text.trim();
    final answer1 = answer1Controller.text.trim();
    final answer2 = answer2Controller.text.trim();
    final answer3 = answer3Controller.text.trim();

    if (questionText.isEmpty || answer1.isEmpty || answer2.isEmpty || answer3.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ajout, un ou plusieurs champs invalides.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      DatabaseReference questionsRef = widget.database.ref().child('quiz').child(widget.question.id);

      Map<String, dynamic> updatedQuestion =
      {
        'questionText': questionTextController.text,
        'answers': {
          '0': answer1Controller.text,
          '1': answer2Controller.text,
          '2': answer3Controller.text,
        },
        'correctAnswer': correctAnswer,
      };

      await questionsRef.update(updatedQuestion);

      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La question a été éditée avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error updating question: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'édition de la question.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Éditer la Question')),
        body: Form(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Texte de la question:'),
                    TextField(controller: questionTextController),
                    const SizedBox(height: 16),
                    const Text('Réponses:'),
                    TextField(controller: answer1Controller),
                    TextField(controller: answer2Controller),
                    TextField(controller: answer3Controller),
                    const SizedBox(height: 8),
                    const Text('Réponse correcte:'),
                    DropdownButton<int>(
                      value: correctAnswer,
                      onChanged: (value) {
                        setState(() {
                          correctAnswer = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Réponse 1')),
                        DropdownMenuItem(value: 1, child: Text('Réponse 2')),
                        DropdownMenuItem(value: 2, child: Text('Réponse 3')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _updateQuestionInDatabase();
                      },
                      child: const Text('Mettre à jour la question'),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}