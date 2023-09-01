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

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() async {
    try {
      DatabaseReference quizRef = widget.database.ref('/quiz');

      quizRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          questions.clear();
          data.forEach((key, value) {
            questions.add(Question.fromMap(Map<String, dynamic>.from(value)));
          });
        }
      });
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  void _deleteQuestion(String questionId) async {
    try {
      widget.database.ref().child('quiz').child(questionId).remove();
      fetchQuestions(); // Rafraîchir la liste des questions après la suppression

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La question a été supprimée avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting question: $error');

      // Afficher un message d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la suppression de la question.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditQuestionPage(Question question) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        //builder: (context) => EditQuestionPage(database: widget.database, question: question),
        builder: (context) => EditQuestionPage(database: widget.database, question: question),
      ),
    );
  }

  void _navigateToAddQuestionPage() async {
    // Naviguer vers la page d'ajout de question et attendre un éventuel retour
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(database: widget.database),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Nombre de question :");
    print(questions.length);

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
          return Column(
            children: [
              QuestionListItem(question: questions[index], onDeletePressed: _deleteQuestion, onEditPressed: _navigateToEditQuestionPage),
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