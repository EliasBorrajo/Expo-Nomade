import 'dart:math';

import 'package:expo_nomade/quiz/quiz_instruction.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../dataModels/question_models.dart';
import 'quiz_result.dart';

class QuizScreen extends StatefulWidget {
  final FirebaseDatabase database;

  const QuizScreen({super.key, required this.database});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('quiz');
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool quizEnded = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() async {
    try {
      DatabaseEvent event = await _database.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Question> allQuestions = data.entries
            .map((entry) {
          String questionId = entry.key;
          Map<String, dynamic> questionData = Map<String, dynamic>.from(entry.value);
          return Question(
            id: questionId,
            questionText: questionData['questionText'] ?? '',
            answers: List<String>.from(questionData['answers'] ?? []),
            correctAnswer: questionData['correctAnswer'] ?? 0,
          );
        })
            .toList();

        // Shuffle the questions and take the first 10 (or less if there are fewer than 10 questions)
        allQuestions.shuffle();
        int numberOfQuestionsToTake = 10;
        questions = allQuestions.take(min(numberOfQuestionsToTake, allQuestions.length)).toList();

        setState(() {
          questions = questions;
        });
      }

    } catch (error) {
      print('Error fetching questions: $error');
      // Handle the error appropriately, e.g., show an error message to the user.
    }
  }

  void checkAnswer(int selectedAnswer) {
    if (selectedAnswer == questions[currentQuestionIndex].correctAnswer) {
      setState(() {
        score++;
      });
    }
    moveToNextQuestion();
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < questions.length-1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        quizEnded = true;
      });
    }
  }

  void _redoQuiz() {
    questions = [];
    currentQuestionIndex = 0;
    score = 0;
    quizEnded = false;
    fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()), // Display a loading indicator
      );
    }

    if(quizEnded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuizResultScreen(database: widget.database, score: score, totalQuestions: questions.length, redoQuiz: _redoQuiz),
            ],
          ),
        ),
      );
    }
    
    void _showInstructionsDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const QuizInstructionsPopup();
          }
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('Quiz'),
        actions: [
          IconButton(
            icon: Icon(Icons.help), // Utilisez l'icône d'aide (point d'interrogation)
            onPressed: () {
              // À faire : Afficher les informations lorsque l'utilisateur appuie sur le point d'interrogation
              _showInstructionsDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Question ${currentQuestionIndex + 1}'),
            const SizedBox(height: 16),
            Text(questions[currentQuestionIndex].questionText),
            const SizedBox(height: 16),
            Column(
              children: [
                for (int i = 0; i < questions[currentQuestionIndex].answers.length; i++)
                  ElevatedButton(
                    onPressed: () => checkAnswer(i),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(questions[currentQuestionIndex].answers[i]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}