import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddQuestionPage extends StatefulWidget {
  final FirebaseDatabase database;

  const AddQuestionPage({super.key, required this.database});

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController answer1Controller = TextEditingController();
  final TextEditingController answer2Controller = TextEditingController();
  final TextEditingController answer3Controller = TextEditingController();
  int correctAnswer = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Texte de la question:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: questionTextController),
            const SizedBox(height: 16),
            const Text(
              'Réponses:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: answer1Controller),
            TextField(controller: answer2Controller),
            TextField(controller: answer3Controller),
            const SizedBox(height: 8),
            const Text('Réponse Correcte:', style: TextStyle(fontSize: 16)),
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
                _addQuestionToDatabase();
                Navigator.pop(context); // Revenir à la liste après l'ajout
              },
              child: const Text('Ajouter la question'),
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestionToDatabase() async {
    try {
      DatabaseReference questionsRef = widget.database.ref().child('quiz');
      DatabaseReference newQuestionRef = questionsRef.push();
      Map<String, dynamic> questionToUpload = {
        'questionText': questionTextController.text,
        'answers': {
          '0': answer1Controller.text,
          '1': answer2Controller.text,
          '2': answer3Controller.text,
        },
        'correctAnswer': correctAnswer,
      };
      await newQuestionRef.set(questionToUpload);
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La question a été ajoutée avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error adding question: $error');

      // Afficher un message d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'ajout de la question.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}