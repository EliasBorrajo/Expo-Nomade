import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../dataModels/question_models.dart';

class QuestionDetailPage extends StatefulWidget {
  final FirebaseDatabase database;
  final Question question;

  const QuestionDetailPage({super.key , required this.database, required this.question});

  @override
  _QuestionDetailPageState createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          //content: Text('Êtes-vous sûr de vouloir supprimer cette question ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Êtes-vous sûr de vouloir supprimer cette question ?'),
              SizedBox(height: 8),
              Text('ID de la question : ${widget.question.id}'), // Display the question's ID
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Suppression réelle dans la base de données
                _deleteQuestion();
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteQuestion() async {
    try {
      await widget.database.ref().child('quiz').child(widget.question.id).remove();
      // Afficher un message de succès ou de confirmation ici si nécessaire
      Navigator.of(context).pop(); // Ferme la page de détails de la question
    } catch (error) {
      print('Error deleting question: $error');
      // Gérer l'erreur en conséquence, par exemple, afficher un message d'erreur à l'utilisateur.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question: ${widget.question.questionText}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Answers:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.question.answers.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          i == widget.question.correctAnswer ? Icons.check_circle : Icons.circle,
                          color: i == widget.question.correctAnswer ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(widget.question.answers[i]),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'editQuestion',
            onPressed: () {
              // TODO: Ajoutez ici la logique d'édition de la question
            },
            tooltip: 'Éditer',
            child: Icon(Icons.edit),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'deleteQuestion',
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
            tooltip: 'Supprimer',
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}