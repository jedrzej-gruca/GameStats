import 'package:flutter/material.dart';
import 'package:game_stats/firestore_service.dart';
import 'package:game_stats/get_game_from_bgg.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NewMeetingScreen extends StatefulWidget {
  @override
  _NewMeetingScreenState createState() => _NewMeetingScreenState();
}

class GameTable {
  final String tableName;
  final String gameName;
  final DateTime addDate;

  GameTable({
    required this.tableName,
    required this.gameName,
    required this.addDate,
  });
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  List<GameTable> gameTables = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Meeting'),
      ),
      body: ListView.builder(
        itemCount: gameTables.length,
        itemBuilder: (context, index) {
          final gameTable = gameTables[index];
          return ListTile(
            title: Text('Nazwa stolika: ${gameTable.tableName}'),
            subtitle: Text('Nazwa gry: ${gameTable.gameName}'),
            trailing: Text('Data dodania: ${gameTable.addDate.toString()}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGameTable = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGameTable(),
            ),
          );

          if (newGameTable != null) {
            setState(() {
              gameTables.add(newGameTable);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddGameTable extends StatefulWidget {
  const AddGameTable({Key? key});

  @override
  _AddGameTableState createState() => _AddGameTableState();
}

class _AddGameTableState extends State<AddGameTable> {
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();
  String? selectedGameName;
  late Game selectedGame;

  void _showAddGameModal(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddGameModal(),
    );

    if (result != null) {
      setState(() {
        selectedGameName = result.name;
        selectedGame = result;
        _gameNameController.text = selectedGameName ?? '';
      });
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  Future<void> saveGameToFirestore(Game game) async {
    try {
      await FirebaseFirestore.instance.collection('games').add({
        'name': game.name,
        'bggId': game.bggId,
        'minPlayers': game.minPlayers,
        'maxPlayers': game.maxPlayers,
      });
      print('Game saved to Firestore successfully!');
    } catch (error) {
      print('Error saving game to Firestore: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj stolik'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tableController,
              onChanged: (value) {
                if (value != selectedGameName) {
                  setState(() {
                    _tableController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ),
                    );
                  });
                }
              },
              decoration: InputDecoration(labelText: 'Nazwa stolika'),
            ),
            SizedBox(height: 16),
            Text('Wybrana gra: ${selectedGameName ?? 'Brak'}', textScaleFactor: 1.5,),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddGameModal(context);
              },
              child: const Text('Dodaj grę'),
            ),
            ElevatedButton(
              onPressed: () {
                //logic to save game table
                if (_tableController.text.isNotEmpty && selectedGameName != null) {
                  final newGameTable = GameTable(
                    tableName: _tableController.text,
                    gameName: selectedGameName!,
                    addDate: DateTime.now(),
                  );
                  Navigator.pop(context, newGameTable);
                  saveGameToFirestore(selectedGame);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Incomplete Data'),
                      content: Text('Please enter both table name and select a game.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        ),
      ),
    );
  }
}


class AddGameModal extends StatefulWidget {
  const AddGameModal({super.key});

  @override
  _AddGameModalState createState() => _AddGameModalState();
}

class _AddGameModalState extends State<AddGameModal> {
  final TextEditingController _gameNameController = TextEditingController();

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj grę'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _gameNameController,
            decoration: const InputDecoration(labelText: 'Nazwa gry'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Anuluj'),
        ),
        TextButton(
          onPressed: () {
            final gameName = _gameNameController.text;
            _searchGame(gameName);
          },
          child: const Text('Wyszukaj'),
        ),
      ],
    );
  }

  void _searchGame(String gameName) async {
    // Wywołaj swoją funkcję do wyszukiwania gry z wykorzystaniem BGG API
    final gameDetails = await getGameDetailsFromBgg(gameName);

    debugPrint('------------------------------------->  Found Game: $gameDetails');

    if (gameDetails != null) {
      final bggId = gameDetails['bggId'] as int;
      final minPlayers = gameDetails['minPlayers'] as int;
      final maxPlayers = gameDetails['maxPlayers'] as int;

      final game = Game(
        name: gameName,
        bggId: bggId,
        minPlayers: minPlayers,
        maxPlayers: maxPlayers,
      );

      String debugGameName = game.name;

      debugPrint('------------------------------------->  Game: $debugGameName');

      // Przekazanie danych gry do AddGameTable
      Navigator.pop(context, game);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Gra nie znaleziona'),
          content: Text('Nie znaleziono gry o podanej nazwie.'),
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
}
