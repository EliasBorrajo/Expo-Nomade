import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/question_models.dart';
import '../../firebase/firebase_crud.dart';
import 'question_detail_page.dart';

class QuizListPage extends StatefulWidget {

  //const QuizListPage({required this.database, Key? key}) : super(key: key);
  const QuizListPage({super.key});

  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  late QuestionCRUDHandler crudHandler;
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    crudHandler = QuestionCRUDHandler(database: FirebaseDatabase.instance);
    fetchQuestions();
  }

  void fetchQuestions() async {
    try {
      final fetchedQuestions = await crudHandler.fetchQuestions();
      setState(() {
        questions = fetchedQuestions;
      });
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
          ? const Center(
        child: Text(
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
                    database: FirebaseDatabase.instance,
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