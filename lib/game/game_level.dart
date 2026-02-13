/// Game level enumeration
enum GameLevel {
  tutorial(platformCount: 3, obstacleCount: 1),
  level1(platformCount: 10, obstacleCount: 4),
  level2(platformCount: 20, obstacleCount: 10),
  level3(platformCount: 50, obstacleCount: 40);

  final int platformCount;
  final int obstacleCount;
  const GameLevel({required this.platformCount, required this.obstacleCount});

  /// Level 2 and Level 3 use smaller platforms (10%) and larger obstacles (20%).
  bool get useLevel2Sizes => this == GameLevel.level2 || this == GameLevel.level3;
}
