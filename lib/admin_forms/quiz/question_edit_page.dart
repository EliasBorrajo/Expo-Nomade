import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/question_models.dart';

class EditQuestionPage extends StatefulWidget {
  final FirebaseDatabase database;
  final Question question;

  // TODO changer
  const EditQuestionPage({Key? key, required this.database, required this.question}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Éditer la Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Text:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: questionTextController),
            SizedBox(height: 16),
            Text(
              'Réponses:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: answer1Controller),
            TextField(controller: answer2Controller),
            TextField(controller: answer3Controller),
            SizedBox(height: 8),
            Text('Réponse Correcte:', style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: correctAnswer,
              onChanged: (value) {
                setState(() {
                  correctAnswer = value!;
                });
              },
              items: [
                DropdownMenuItem(value: 0, child: Text('Réponse 1')),
                DropdownMenuItem(value: 1, child: Text('Réponse 2')),
                DropdownMenuItem(value: 2, child: Text('Réponse 3')),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateQuestionInDatabase();
              },
              child: Text('Mettre à jour la Question'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuestionInDatabase() async {
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

      Navigator.pop(context); // Revenir à la liste après la mise à jour
    } catch (error) {
      print('Error updating question: $error');
    }
  }
}