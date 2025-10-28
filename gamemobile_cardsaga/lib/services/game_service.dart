import 'package:flutter/material.dart';
import '../models/level.dart';
import '../models/user.dart';

class GameService extends ChangeNotifier {
  UserData user = UserData(coins: 100, stars: 0);
  final List<Level> levels = [];

  GameService() {
    levels.add(
      Level(id: 1, pairCount: 6, timeLimit: 60, unlocked: true, stars: 0),
    );
    levels.add(
      Level(id: 2, pairCount: 6, timeLimit: 60, unlocked: false, stars: 0),
    );
    levels.add(
      Level(id: 3, pairCount: 8, timeLimit: 70, unlocked: false, stars: 0),
    );
  }
}
