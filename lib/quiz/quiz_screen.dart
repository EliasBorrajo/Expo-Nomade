import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../dataModels/question_models.dart';
import 'quiz_result.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

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
        List<Question> allQuestions = [];
        data.forEach((key, value) {
          allQuestions.add(Question.fromMap(Map<String, dynamic>.from(value)));
        });

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
    }
  }

  void checkAnswer(String selectedAnswer) {
    if (selectedAnswer == questions[currentQuestionIndex].answers[questions[currentQuestionIndex].correctAnswer]) {
      setState(() {
        score++;
      });
    }
    moveToNextQuestion();
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < 9) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        quizEnded = true;
      });
    }
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
              QuizResultScreen(score: score, totalQuestions: questions.length),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Question ${currentQuestionIndex + 1}'),
            Text(questions[currentQuestionIndex].questionText),
            Column(
              children: [
                for (String answer in questions[currentQuestionIndex].answers)
                  ElevatedButton(
                    onPressed: () => checkAnswer(answer),
                    child: Text(answer),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}