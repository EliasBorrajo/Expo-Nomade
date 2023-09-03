import 'dart:async';

import 'package:expo_nomade/admin_forms/quiz/question_add_page.dart';
import 'package:expo_nomade/admin_forms/quiz/question_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/question_models.dart';
import 'question_list_item.dart';

class QuizListPage extends StatefulWidget {
  final FirebaseDatabase database;

  const QuizListPage({super.key, required this.database});

  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  List<Question> questions = [];
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() async {
    try {
      DatabaseReference quizRef = widget.database.ref().child('quiz');

      _subscription = quizRef.onValue.listen((DatabaseEvent event) {
        if (mounted) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            List<Question> fetchedQuestions = data.entries
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

            setState(() {
              questions = fetchedQuestions;
            });
          }
        }
      });
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _deleteQuestion(String questionId) async {
    try {
      await widget.database.ref().child('quiz').child(questionId).remove();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La question a été supprimée avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting question: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la suppression de la question.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditQuestionPage(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionPage(database: widget.database, question: question),
      ),
    );
  }

  void _navigateToAddQuestionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(database: widget.database),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des questions')),
      body: questions.isEmpty
          ? const Center(
              child: Text(
                'Aucune question trouvée dans la base de données.',
              ),
            )
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    QuestionListItem(
                        question: questions[index],
                        onDeletePressed: _deleteQuestion,
                        onEditPressed: _navigateToEditQuestionPage),
                    const Divider(height: 1), // Ajoute une ligne de séparation
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddQuestionPage();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
