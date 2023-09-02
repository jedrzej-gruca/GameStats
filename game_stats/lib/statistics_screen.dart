import 'package:flutter/material.dart';
import 'package:game_stats/firestore_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:bgg_api/bgg_api.dart';
import 'add_game_result_modal.dart';

class StatisticsScreen extends StatelessWidget {

  final FirestoreService firestoreService = FirestoreService();
  StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Game Plays'),
      ), 
      body: FutureBuilder<List<Game>>(
        future: firestoreService.getGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            final games = snapshot.data;
            return ListView.builder(
              itemCount: games?.length,
              itemBuilder: (context, index) {
                final game = games?[index];
                return ListTile(
                  title: Text(game!.name),
                  onTap: () => _showGameDetails(context, game),
                );
              },
            );
          }
          return const Text('No games found.');
        },
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGameResultModal(context),
        child: const Icon(Icons.add_circle_outline_sharp),
      ),
      // Container(
      //   alignment: Alignment.bottomCenter,
      //   child: ElevatedButton(
      //     onPressed: () => {
      //       Navigator.push(
      //         context, 
      //         MaterialPageRoute(
      //           builder: (context) => addGameResult(),
      //         ),
      //       )
      //     }, 
      //     child: const Icon(Icons.add_circle_outline_sharp),
      //   ),
      // ),
    );
  }

  void _showGameDetails(BuildContext context, Game game) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(game.name),
          content: const Column(
            children: [
              // TODO: Implement game details UI here
              // Display statistics, last four game results, etc.
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: Implement logic to view more results
              },
              child: const Text('View more...'),
            ),
          ],
        );
      },
    );
  }

  void _showAddGameResultModal(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddGameResultModal();
      },
    );

    // Handle the result from the modal (e.g., save the game result)
    if (result != null) {
      final player = result['player'] as Player;
      final gameResult = result['result'] as int;

      // Save the game result to Firestore or perform any necessary actions
      // based on the selected player and game result
      // ...

      // Show a success message or perform any other required actions
    }
  }
}