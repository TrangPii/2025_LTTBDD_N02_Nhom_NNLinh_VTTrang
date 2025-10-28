import 'package:flutter/foundation.dart';

@immutable
class GameTheme {
  final String id;
  final String nameKey;
  final int requiredStars;
  final bool isDefault;
  final List<String> cardImagePaths;
  final List<int> puzzleImageIds;

  const GameTheme({
    required this.id,
    required this.nameKey,
    required this.requiredStars,
    this.isDefault = false,
    required this.cardImagePaths,
    required this.puzzleImageIds,
  });
}
