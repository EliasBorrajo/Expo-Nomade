import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../dataModels/question_models.dart';
import 'quiz_result.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

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
              QuizResultScreen(score: score, totalQuestions: questions.length, redoQuiz: _redoQuiz),
            ],
          ),
        ),
      );
    }

/*    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text('Question ${currentQuestionIndex + 1}', style: GoogleFonts.nunito(fontSize: 30)),
            const SizedBox(height: 16),
            Text(questions[currentQuestionIndex].questionText, style: const TextStyle(fontSize: 24)),
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
                    child: Text(questions[currentQuestionIndex].answers[i],  style: const TextStyle(fontSize: 20)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }*/

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500), // Durée de l'animation en millisecondes
              child: Text('Question ${currentQuestionIndex + 1}', style: GoogleFonts.nunito(fontSize: 30), key: UniqueKey()), // Assurez-vous d'ajouter une clé unique
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500), // Durée de l'animation en millisecondes
              child: Text(questions[currentQuestionIndex].questionText, style: const TextStyle(fontSize: 24), key: UniqueKey()), // Assurez-vous d'ajouter une clé unique
            ),
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
                    child: Text(questions[currentQuestionIndex].answers[i],  style: const TextStyle(fontSize: 20)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _redoQuiz() {
      questions = [];
      currentQuestionIndex = 0;
      score = 0;
      quizEnded = false;
      fetchQuestions();
  }
}