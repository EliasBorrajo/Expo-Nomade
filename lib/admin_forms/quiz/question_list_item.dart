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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          const Column(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              Icon(Icons.question_mark_rounded, size: 40),
            ],
          ),
          const SizedBox(width: 30), // Espace entre les colonnes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Title(
                  color: Colors.black,
                  child:
                  Text('Question ${widget.question.id}'),
                ),
                Text(
                  widget.question.questionText,
                ),
                const SizedBox(height: 8),
                const Text('Answers:'),
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
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_rounded,
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
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      widget.onEditPressed(widget.question);
                    },
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    onPressed: () async {
                      _showDeleteConfirmationDialog(context);
                    },
                    icon: const Icon(Icons.delete_rounded),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}