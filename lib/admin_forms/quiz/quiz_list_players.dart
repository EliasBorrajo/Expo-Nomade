import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../dataModels/player.dart';

class QuizListPlayers extends StatefulWidget {
  final FirebaseDatabase database;

  const QuizListPlayers({super.key, required this.database});

  @override
  _QuizListPlayers createState() => _QuizListPlayers();
}

class _QuizListPlayers extends State<QuizListPlayers> {
  List<Player> players = [];
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  void fetchPlayers() async {
    try {
      DatabaseReference quizRef = widget.database.ref().child('quizPlayers');

      _subscription = quizRef.onValue.listen((DatabaseEvent event) {
        if (mounted) {
          Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            List<Player> fetchedPlayers = data.entries
                .map((entry) {
              String playerId = entry.key;
              Map<String, dynamic> playerData = Map<String, dynamic>.from(entry.value);
              return Player(
                id: playerId,
                userEmail: playerData['userEmail'] ?? '',
                score: playerData['score'] ?? '',
                dateTime: playerData['dateTime'] ?? '',
              );
            })
                .toList();

            setState(() {
              players = fetchedPlayers;
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

  void _deletePlayer(String playerId) async {
    try {
      await widget.database.ref().child('quizPlayers').child(playerId).remove();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le joueur a été supprimé avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error deleting question: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la suppression du joueur.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String playerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Êtes-vous sûr de vouloir supprimer ce joueur ?'),
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
                _deletePlayer(playerId);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Listes des joueurs')),
      body: players.isEmpty
          ? const Center(
        child: Text(
          'Aucun joueur trouvé dans la base de données.',
        ),
      )
          : ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            title: Row(
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 40,),
                  ],
                ),
                const SizedBox(width: 30), // Espace entre l'icône et les informations
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info),
                        Text(' Joueur: ${player.id}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.email),
                        Text(' ${player.userEmail}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        Text(' Date et heure: ${player.dateTime}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star),
                        Text(' Score: ${player.score}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, player.id);
              },
            ),
          );
        },
      )
    );
  }
}