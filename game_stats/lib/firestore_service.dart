import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference gameCollection = FirebaseFirestore.instance.collection('games');
  final CollectionReference playerCollection = FirebaseFirestore.instance.collection('player');
  final CollectionReference gameResultCollection = FirebaseFirestore.instance.collection('gameResult');
  final CollectionReference playerResultCollection = FirebaseFirestore.instance.collection('playerResult');

  //Method to add a new game result
  Future<void> addGameResult(GameResult result) async {
    try {
      final gameResultDoc = await gameResultCollection.add({
        'gameId' : result.gameId,
        'date' : result.date,
      });

      for(final playerResult in result.playerResults.entries) {
        await playerResultCollection.add({
          'playerId' : playerResult.key,
          'result' : playerResult.value,
          'gameResultId' : gameResultDoc.id,
        });
      }

    } catch (exp) {
      print('Error adding new game result: $exp');
      rethrow;
    }
  }

  // Method to retrieve the list of games
  Future<List<Game>> getGames() async {
    final snapshot = await gameCollection.get();
    return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
  }

  // Method to retrieve statistics for a game
  Future<Statistics> getGameStatistics(String gameId) async {
    try {
      final queriedGameResults = await gameResultCollection.where('gameId', isEqualTo: gameId).get();
      List<String>? gameResultsIds;
      for (var element in queriedGameResults.docs) {
        gameResultsIds!.add(element.id);
      }
      final queriedPlayerResults = await playerResultCollection.where('gameResultId', whereIn: gameResultsIds).get();

      int totalPlays = queriedPlayerResults.docs.length;
      double highestWinRatio = 0;
      String playerIdwithHighestWinRatio = '';

      final playerWinCountMap = <String, int>{};

      for(final doc in queriedPlayerResults.docs) {
        final playerResult = PlayerResult.fromFirestore(doc);
        playerWinCountMap[playerResult.playerId] = (playerWinCountMap[playerResult.playerId] ?? 0) + 1;
        final playerWinRatio = playerWinCountMap[playerResult.playerId]! / totalPlays;
        if(playerWinRatio > highestWinRatio) {
          highestWinRatio = playerWinRatio;
          playerIdwithHighestWinRatio = playerResult.playerId;
        }
      }

      late Player bestPlayer;
      final queriedPlayerWithHighestWinRatio = await playerResultCollection.where('id', isEqualTo: playerIdwithHighestWinRatio).get();
      for(final doc in queriedPlayerWithHighestWinRatio.docs) {
        bestPlayer = Player.fromFirestore(doc);
      }

      final statistics = Statistics(
        playerWithHighestWinRatio: bestPlayer.nickname, 
        totalPlays: totalPlays
      );
      return statistics;
    } catch (exp) {
      print('Error calculating game statistics: $exp');
      rethrow;
    }
  }

  // Method to retrieve the last four game results
  Future<Map<String?, List<PlayerResult>>> getLastFourGameResults(String gameId) async {
    try {
      final queriedGameResults = await gameResultCollection.where('gameId', isEqualTo: gameId).orderBy('date', descending: true).limit(4).get();
      List<String>? gameResultsIds;
      queriedGameResults.docs.forEach((element) {
        gameResultsIds!.add(element.id);
      });

      final gameResultMap = <String?, List<PlayerResult>>{};

      for(final doc in queriedGameResults.docs) {
        final gameResult = GameResult.fromFirestore(doc);
        final queriedPlayerResults = await playerResultCollection.where('gameResultId', isEqualTo: gameResult.id).get();
        for(final res in queriedPlayerResults.docs) {
          if(!gameResultMap.containsKey(gameResult.id)) {
            gameResultMap.putIfAbsent(gameResult.id, () => List.empty(growable: true));
          }
          gameResultMap[gameResult.id]?.add(res as PlayerResult);
        }
      }
      return gameResultMap;
    } catch (exp) {
      print('Error retriving game results: $exp');
      rethrow;
    }
  }
}

class Game {
  final String? id;
  final String name;
  final int bggId;
  final int minPlayers;
  final int maxPlayers;
  final int? playsNo;

  Game({
    this.id,
    required this.name,
    required this.bggId,
    required this.minPlayers,
    required this.maxPlayers,
    this.playsNo
  });

  factory Game.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Game(
      id: doc.id, 
      name: data['name'], 
      bggId: data['bggId'], 
      minPlayers: data['minPlayers'], 
      maxPlayers: data['maxPlayers'], 
      playsNo: data['playsNo']
    );
  }
}

class Player {
  final String? id;
  final String nickname;
  final int? playsNo;
  final int? winNo;

  Player({
    this.id,
    required this.nickname,
    this.playsNo,
    this.winNo,
  });

  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Player(
      id: doc.id, 
      nickname: data['nickname'], 
      playsNo: data['playsNo'], 
      winNo: data['winNo']
    );
  }
}

class GameResult {
  final String? id;
  final String gameId;
  final DateTime date;
  //Map<PlayerId, Result>
  final Map<String,int> playerResults;

  GameResult({
    this.id,
    required this.gameId,
    required this.date,
    required this.playerResults
  });

  factory GameResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameResult(
      id: doc.id, 
      gameId: data['gameId'], 
      date: data['date'],
      playerResults: data['playerResults'],
    );
  }
}

class PlayerResult {
  final String? id;
  final String playerId;
  final int result;
  final String gameResultId;

  PlayerResult({
    this.id,
    required this.playerId,
    required this.result,
    required this.gameResultId,
  });

  factory PlayerResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerResult(
      id: doc.id, 
      playerId: data['playerId'], 
      result: data['result'],
      gameResultId: data['gameResultId'],
    );
  }
}

class Statistics {
  final String playerWithHighestWinRatio;
  final int totalPlays;

  Statistics({
    required this.playerWithHighestWinRatio,
    required this.totalPlays
  });
}