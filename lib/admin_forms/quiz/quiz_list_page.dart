import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../dataModels/quiz_models.dart';
import 'question_detail_page.dart';

class QuizListPage extends StatelessWidget {
  final List<Question> questions;
  final FirebaseDatabase database;

  const QuizListPage({required this.questions, required this.database});

  void _seedDatabase() async {
    // Get a reference to your Firebase database
    DatabaseReference databaseReference = database.ref();

    // Loop through the dummyQuiz and add them to the database
    for (var question in questions) {
      await databaseReference.child('quiz').push().set({
        'questionText': question.questionText,
        'answers': question.answers.map((answer) => answer.answerText).toList(),
        'correctAnswer': question.correctAnswer,
      });
    }
  }

  void _readDatabase() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('quiz');

    DataSnapshot snapshot = await databaseReference.get();

    if (snapshot.value != null) {
      print('Quiz data:');
      Map<dynamic, dynamic> quizData = snapshot.value as Map<dynamic, dynamic>;
      quizData.forEach((key, value) {
        print('Question ID: $key');
        print('Question: ${value['questionText']}');
        print('Answers: ${value['answers']}');
        print('Correct Answer: ${value['correctAnswer']}');
        print('---');
      });
    } else {
      print('No quiz questions found in the database.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des questions',
      home: Scaffold(
        appBar: AppBar(title: Text('Liste des questions')),
        body: ListView.builder(
            itemCount: questions.length,
        itemBuilder: (context, index) {
              final question = questions[index];
              return ListTile(
                title: Text(question.questionText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO editer la question
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO supprimer la question
                      },
                      icon: Icon(Icons.delete),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuestionDetailPage(question: question)),
                  );
                },
              );
            }),
        floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              // TODO ajouter une question
            },
            label: Text('Ajouter question'),
            icon: Icon(Icons.add),
            heroTag: 'add_question',
          ),
          SizedBox(height: 10), // Add some spacing between the FABs
          FloatingActionButton.extended(
            onPressed: _seedDatabase,
            label: Text('Seed Database'),
            icon: Icon(Icons.cloud_upload),
            heroTag: 'seed_database',
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _readDatabase,  // Utilise la méthode de lecture
            label: Text('Read Database'),  // Libellé du bouton
            icon: Icon(Icons.cloud_download),  // Icône du bouton
            heroTag: 'read_database',  // Tag héros unique
          ),
        ],
        ),
      ),
    );
  }
}