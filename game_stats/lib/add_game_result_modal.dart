import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:game_stats/get_game_from_bgg.dart';
// import 'package:bgg_api/bgg_api.dart';

class AddGameResultModal extends StatefulWidget {
  const AddGameResultModal({super.key});

  @override
  _AddGameResultModalState createState() => _AddGameResultModalState();
}

class _AddGameResultModalState extends State<AddGameResultModal> {
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _playerSearchController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final List<Player> _searchResults = [];
  final List<Player> _selectedPlayers = [];
  Game? game;

  @override
  void dispose() {
    _gameNameController.dispose();
    _playerSearchController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Game Result'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _gameNameController,
            decoration: const InputDecoration(labelText: 'Game Name'),
          ),
          ElevatedButton(
            onPressed: _searchGame,
            child: const Text('Search Game'),
          ),
          TextField(
            controller: _playerSearchController,
            decoration: const InputDecoration(labelText: 'Search Player'),
            onChanged: _searchPlayers,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final player = _searchResults[index];
              return ListTile(
                title: Text(player.nickname),
                onTap: () => setState(() => _addSelectedPlayer(player)),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Selected Players:'),
          Column(
            children: _selectedPlayers
                .map(
                  (player) => ListTile(
                    title: Text(player.nickname),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _removeSelectedPlayer(player)),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedPlayers.length >= game!.minPlayers ? _saveGameResult : null,
            child: const Text('Save'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _searchGame() async {
    final gameName = _gameNameController.text;
    final gameDetails = await getGameDetailsFromBgg(gameName);
    if (gameDetails != null) {
      final bggId = gameDetails['bggId'];
      final minPlayers = gameDetails['minPlayers'];
      final maxPlayers = gameDetails['maxPlayers'];

      // Update the state with the retrieved game details
      setState(() {
        game = Game(
          name: gameName, 
          bggId: bggId, 
          minPlayers: minPlayers, 
          maxPlayers: maxPlayers
        );
        _gameNameController.text = gameName;
        _playerSearchController.clear();
        _resultController.clear();
        _searchResults.clear();
        _selectedPlayers.clear();
      });

      // Use the retrieved game details as needed
      print('BGG ID: $bggId');
      print('Min Players: $minPlayers');
      print('Max Players: $maxPlayers');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game Not Found'),
          content: Text('No game found with the given name.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _searchPlayers(String query) {
    // TODO Implement the logic to search for players in Firebase based on the query
    // and update the _searchResults list accordingly
  }

  void _addSelectedPlayer(Player player) {
    if (!_selectedPlayers.contains(player)) {
      setState(() => _selectedPlayers.add(player));
    }
  }

  void _removeSelectedPlayer(Player player) {
    setState(() => _selectedPlayers.remove(player));
  }

  void _saveGameResult() {
    if (_selectedPlayers.length < game!.minPlayers) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Number of Players'),
          content: Text('Please select at least ${game!.minPlayers} players.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_selectedPlayers.length > game!.maxPlayers) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Number of Players'),
          content: Text('Please select no more than ${game!.maxPlayers} players.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Handle saving the game result with the selected players
    Navigator.pop(context, {
      'players': _selectedPlayers,
    });
  }
  
  // Future<Map<String, dynamic>?> getGameDetailsFromBgg(String gameName) async {
  //   final url = Uri.parse('https://api.bgg.com/api/v2/search?query=${Uri.encodeQueryComponent(gameName)}');
  //   final response = await http.get(url);
  //
  //   if(response.statusCode == 200) {
  //     final jsonData = jsonDecode(response.body);
  //     final gameDetails = jsonData['games'][0];
  //     final bggId = gameDetails['gameId'];
  //     final minPlayers = gameDetails['minPlayers'];
  //     final maxPlayers = gameDetails['maxPlayers'];
  //
  //     return {
  //       'bggId' : bggId,
  //       'minPlayers' : minPlayers,
  //       'maxPlayers' : maxPlayers,
  //     };
  //   } else {
  //     return null;
  //   }
  // }
}
