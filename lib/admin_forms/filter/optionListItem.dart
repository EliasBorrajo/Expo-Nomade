import 'package:flutter/material.dart';
import '../../dataModels/filters_tags.dart';

class OptionListItem extends StatefulWidget {
  final FilterTag filter;
  final Function(String) onDeletePressed;
  final Function(FilterTag) onEditPressed;

  const OptionListItem({
    super.key,
    required this.filter,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  _OptionListItemState createState() => _OptionListItemState();
}

class _OptionListItemState extends State<OptionListItem> {
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
              Text('Êtes-vous sûr de vouloir supprimer ce filtre ?'),
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
                widget.onDeletePressed(widget.filter.id);
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
          ),
          const SizedBox(width: 30), // Espace entre les colonnes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Title(
                  color: Colors.black,
                  child:
                  Text(
                    widget.filter.typeName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Options:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < widget.filter.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(widget.filter.options[i]),
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
                      widget.onEditPressed(widget.filter);
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
            ],
          ),
        ],
      ),
    );
  }
}

