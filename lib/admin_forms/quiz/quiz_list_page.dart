import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/question_models.dart';
import 'question_detail_page.dart';

class QuizListPage extends StatefulWidget {
  final FirebaseDatabase database;

  //const QuizListPage({required this.database, Key? key}) : super(key: key);
  const QuizListPage({super.key, required this.database});

  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() async {
    try {
      DatabaseEvent event = await widget.database.ref().child('quiz').once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
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
    } catch (error) {
      print('Error fetching questions: $error');
      // Handle the error appropriately, e.g., show an error message to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Questions')),
      body: questions.isEmpty
          ? Center(
        child: const Text(
          'Aucune question trouvée dans la base de données.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questions[index].questionText),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO editer la question
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    // TODO supprimer la question
                  },
                  icon: const Icon(Icons.delete),
                )
              ],
            ),
            onTap: () async {
              // Navigate to the question detail page and wait for a result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDetailPage(
                    database: widget.database,
                    question: questions[index],
                  ),
                ),
              );

              // Check if the result is true (question was deleted)
              if (result == true) {
                fetchQuestions(); // Refresh the questions
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to the question creation page
          // Implement the logic to navigate to the page where you can add a new question
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}