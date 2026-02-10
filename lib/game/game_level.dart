/// Game level enumeration
enum GameLevel {
  tutorial(platformCount: 3, obstacleCount: 1),
  level1(platformCount: 10, obstacleCount: 4),
  level2(platformCount: 20, obstacleCount: 10);

  final int platformCount;
  final int obstacleCount;
  const GameLevel({required this.platformCount, required this.obstacleCount});
}
