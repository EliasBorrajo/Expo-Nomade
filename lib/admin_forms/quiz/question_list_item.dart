import 'package:flutter/material.dart';
import '../../dataModels/question_models.dart';

class QuestionListItem extends StatefulWidget {
  final Question question;
  final Function(String) onDeletePressed;
  final Function(Question) onEditPressed;

  const QuestionListItem({
    super.key,
    required this.question,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Question ${widget.question.id}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.questionText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Answers:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.question.answers.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        i == widget.question.correctAnswer
                            ? Icons.check_circle
                            : Icons.circle,
                        color: i == widget.question.correctAnswer
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.question.answers[i]),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              widget.onEditPressed(widget.question);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              _showDeleteConfirmationDialog(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Êtes-vous sûr de vouloir supprimer cette question ?'),
              SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                widget.onDeletePressed(widget.question.id);
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}