import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bgg_api/bgg_api.dart';
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>?> getGameDetailsFromBgg(String gameName) async {
  var bgg = Bgg();
  int? foundGameId;
  BoardGame? foundGame;
  var foundBoardgames = bgg.searchBoardGames(gameName);
  for (BoardGameRef boardGameRef in  await foundBoardgames) {
    if (boardGameRef.name == gameName) {
      foundGameId = boardGameRef.id;
    }
  }
  if(foundGameId != null) {
    foundGame = await bgg.getBoardGame(foundGameId);
    // debugPrint('Found Game: $foundGame');
  }
  if (foundGame != null) {
    return {
      'name' : foundGame.name,
      'bggId' : foundGame.id,
      'minPlayers' : foundGame.minPlayers,
      'maxPlayers' : foundGame.maxPlayers,
    };
  } else {
    return null;
  }

  // final url = Uri.parse('https://api.bgg.com/api/v2/search?query=${Uri.encodeQueryComponent(gameName)}');
  // final response = await http.get(url);
  //
  // if(response.statusCode == 200) {
  //   final jsonData = jsonDecode(response.body);
  //   final gameDetails = jsonData['games'][0];
  //   final bggId = gameDetails['gameId'];
  //   final minPlayers = gameDetails['minPlayers'];
  //   final maxPlayers = gameDetails['maxPlayers'];
  //
  //   return {
  //     'bggId' : bggId,
  //     'minPlayers' : minPlayers,
  //     'maxPlayers' : maxPlayers,
  //   };
  // } else {
  //   return null;
  // }
}