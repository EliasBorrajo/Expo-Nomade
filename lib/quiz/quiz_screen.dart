import 'dart:math';

import 'package:expo_nomade/quiz/quiz_instruction.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../dataModels/question_models.dart';
import 'quiz_result.dart';

class QuizScreen extends StatefulWidget {
  final FirebaseDatabase database;

  final VoidCallback resetInactivityTimer;

  const QuizScreen({super.key, required this.database, required this.resetInactivityTimer});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
      'quiz');
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
          Map<String, dynamic> questionData = Map<String, dynamic>.from(
              entry.value);
          return Question(
            id: questionId,
            questionText: questionData['questionText'] ?? '',
            answers: List<String>.from(questionData['answers'] ?? []),
            correctAnswer: questionData['correctAnswer'] ?? 0,
          );
        })
            .toList();

        allQuestions.shuffle();
        int numberOfQuestionsToTake = 10;
        questions =
            allQuestions.take(min(numberOfQuestionsToTake, allQuestions.length))
                .toList();

        setState(() {
          questions = questions;
        });
      }
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  void checkAnswer(int selectedAnswer) {
    if (selectedAnswer == questions[currentQuestionIndex].correctAnswer) {
      setState(() {
        score++;
      });
    }
    moveToNextQuestion();
    widget.resetInactivityTimer();
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
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
        body: const Center(
            child: CircularProgressIndicator()), // Display a loading indicator
      );
    }

    if (quizEnded) {
      return Scaffold(
          appBar: AppBar(title: const Text('Quiz')),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QuizResultScreen(database: widget.database,
                      score: score,
                      totalQuestions: questions.length,
                      redoQuiz: _redoQuiz),
                ],
              ),
            ),
          )
      );
    }

    void showInstructionsDialog(BuildContext context) {
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
            icon: const Icon(Icons.help_rounded),
            onPressed: () {
              showInstructionsDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1}',
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 40),
              Container(
                  width: MediaQuery.of(context).size.width >= 400 ? 900 : MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height >= 500 ? 500 : MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white, // Couleur de fond du carré
                    borderRadius: BorderRadius.circular(12.0), // Bords arrondis
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Ombre légère autour du carré
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // Ajustez le décalage pour contrôler la direction de l'ombre
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0), // Espacement intérieur du carré
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          questions[currentQuestionIndex].questionText,
                        ),
                        const SizedBox(height: 40),
                        Column(
                          children: [
                            for (int i = 0; i < questions[currentQuestionIndex].answers.length; i++)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => checkAnswer(i),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      minimumSize: const Size(200, 60),
                                    ),
                                    child: Text(
                                      questions[currentQuestionIndex].answers[i],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}