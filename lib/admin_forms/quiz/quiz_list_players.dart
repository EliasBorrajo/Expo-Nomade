import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../dataModels/player.dart';

enum PlayerFilter { sortByRecentDate, sortByOldestDate, sortByHighestScore, sortByLowestScore }

class QuizListPlayers extends StatefulWidget {
  final FirebaseDatabase database;

  const QuizListPlayers({super.key, required this.database});

  @override
  _QuizListPlayersState createState() => _QuizListPlayersState();
}

class _QuizListPlayersState extends State<QuizListPlayers> {
  List<Player> players = [];
  StreamSubscription<DatabaseEvent>? _subscription;
  PlayerFilter currentFilter = PlayerFilter.sortByRecentDate;

  List<DropdownMenuItem<PlayerFilter>> filterOptions = [
    const DropdownMenuItem(
      value: PlayerFilter.sortByRecentDate,
      child: Text('Filtrer par date la plus récente'),
    ),
    const DropdownMenuItem(
      value: PlayerFilter.sortByOldestDate,
      child: Text('Filtrer par date la plus ancienne'),
    ),
    const DropdownMenuItem(
      value: PlayerFilter.sortByHighestScore,
      child: Text('Filtrer par score le plus haut'),
    ),
    const DropdownMenuItem(
      value: PlayerFilter.sortByLowestScore,
      child: Text('Filtrer par score le plus bas'),
    ),
  ];

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

  void applyFilter(PlayerFilter? filter) {
    if (filter != null) {
      setState(() {
        currentFilter = filter;
      });
    }
  }

  DateTime parseDateTime(String dateTimeString) {
    final parts = dateTimeString.split(' ');
    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');
    final year = int.parse(dateParts[2]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[0]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return DateTime(year, month, day, hour, minute);
  }

  List<Player> getFilteredPlayers() {
    if (currentFilter == PlayerFilter.sortByRecentDate) {
      players.sort((a, b) => parseDateTime(b.dateTime).compareTo(parseDateTime(a.dateTime)));
      return players;
    } else if (currentFilter == PlayerFilter.sortByOldestDate) {
      players.sort((a, b) => parseDateTime(a.dateTime).compareTo(parseDateTime(b.dateTime)));
      return players;
    } else if (currentFilter == PlayerFilter.sortByHighestScore) {
      players.sort((a, b) => b.score.compareTo(a.score));
      return players;
    }  else if (currentFilter == PlayerFilter.sortByLowestScore) {
      players.sort((a, b) => a.score.compareTo(b.score));
      return players;
    } else {
      return players;
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

      setState(() {
        players.removeWhere((player) => player.id == playerId);
      });

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
    final filteredPlayers = getFilteredPlayers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des joueurs'),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration (
              color: Colors.white,
            ),
            child: DropdownButton<PlayerFilter>(
              value: currentFilter,
              onChanged: applyFilter,
              items: filterOptions,
            ),
          ),
        ],
      ),
      body: filteredPlayers.isEmpty
          ? const Center(
        child: Text(
          'Aucun joueur trouvé dans la base de données.',
        ),
      )
          : ListView.builder(
        itemCount: filteredPlayers.length,
        itemBuilder: (context, index) {
          final player = filteredPlayers[index];
          return Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_rounded, size: 40),
                      ],
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_rounded),
                              Expanded(
                                child: Text('Joueur: ${player.id}'),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email_rounded),
                              Text(player.userEmail),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded),
                              Text('Date et heure: ${player.dateTime}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded),
                              Text(' Score: ${player.score}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_rounded),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, player.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}