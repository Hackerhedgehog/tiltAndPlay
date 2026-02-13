import 'dart:math';
import 'flame_platform.dart';
import 'flame_obstacle.dart';
import 'game_level.dart';
import 'game_config.dart';

/// Manages spawning and positioning of platforms and obstacles
class PlatformSpawner {
  /// Spawn initial platforms and obstacles for a level
  static List<FlamePlatform> spawnInitialPlatforms(
      GameLevel level, double screenWidth) {
    final platforms = <FlamePlatform>[];
    final random = Random();
    final platformCount = level.platformCount;

    // Spawn platforms with proper vertical spacing
    for (int i = 0; i < platformCount; i++) {
      // Random X position (with some padding from edges)
      final padding = screenWidth * 0.1;
      final minX = -screenWidth / 2 + padding;
      final maxX = screenWidth / 2 - padding;
      final randomX = minX + random.nextDouble() * (maxX - minX);

      // World Y position - space platforms vertically
      // Start above the base platform, with spacing between them
      final baseWorldY = GameConfig.platformSpacing * (i + 1);
      // Add some randomness to spacing (but keep them reachable)
      final randomOffset =
          (random.nextDouble() - 0.5) * GameConfig.platformSpacing * 0.3;
      final worldY = baseWorldY + randomOffset;

      final platform = FlamePlatform(
        worldY: worldY,
        worldX: randomX,
        level: level,
      );

      platforms.add(platform);
    }

    return platforms;
  }

  /// Spawn a single platform at a specific world Y position
  static FlamePlatform spawnPlatformAt(
      double worldY, double screenWidth, GameLevel level) {
    final random = Random();
    final padding = screenWidth * 0.1;
    final minX = -screenWidth / 2 + padding;
    final maxX = screenWidth / 2 - padding;
    final randomX = minX + random.nextDouble() * (maxX - minX);

    return FlamePlatform(
      worldY: worldY,
      worldX: randomX,
      level: level,
    );
  }

  /// Spawn initial obstacles for a level
  static List<FlameObstacle> spawnInitialObstacles(
      GameLevel level, double screenWidth, List<FlamePlatform> platforms) {
    final obstacles = <FlameObstacle>[];
    final random = Random();
    final obstacleCount = level.obstacleCount;

    // Calculate platform positions for overlap checking (bottom, top, width)
    final platformPositions = <Map<String, double>>[];
    for (final p in platforms) {
      final platformWidth =
          screenWidth * (level.useLevel2Sizes ? 0.10 : 0.20);
      platformPositions.add({
        'bottom': p.worldY,
        'top': p.worldY + p.size.y, // platform anchor is bottomCenter
        'x': p.worldX,
        'width': platformWidth,
      });
    }

    // Spawn obstacles spread evenly across the full level height
    final obstacleWidth =
        screenWidth * (level.useLevel2Sizes ? 0.20 : 0.15);
    final obstacleHeightEst = obstacleWidth; // conservative estimate
    final obstacleHalfWidth = obstacleWidth / 2;
    final obstacleTop = (double worldY) => worldY + obstacleHeightEst / 2;
    final obstacleBottom = (double worldY) => worldY - obstacleHeightEst / 2;

    // Level vertical range: from first to last platform
    const levelMinY = GameConfig.platformSpacing;
    final levelMaxY = GameConfig.platformSpacing * platforms.length;
    final levelRange = levelMaxY - levelMinY;

    // Compute safe Y ranges (gaps between forbidden zones) for fallback placement
    // Forbidden when overlapping: [platformBottom - 200, platformTop + 500]
    // Safe: obstacle entirely below (obsTop <= platformBottom - 200) or above (obsBottom >= platformTop + 500)
    final h = obstacleHeightEst / 2;
    final safeYRanges = <({double start, double end})>[];
    for (int i = 0; i < platformPositions.length; i++) {
      final p = platformPositions[i];
      final platformBottom = p['bottom']!;
      final platformTop = p['top']!;

      if (i == 0) {
        // Below first platform: Y + h <= platformBottom - 200
        final end = platformBottom - GameConfig.obstacleMinDistanceBelowPlatform - h;
        if (end > levelMinY) {
          safeYRanges.add((start: levelMinY, end: end));
        }
      }
      if (i < platformPositions.length - 1) {
        final nextBottom = platformPositions[i + 1]['bottom']!;
        final gapStart = platformTop + GameConfig.obstacleMinDistanceAbovePlatform + h;
        final gapEnd = nextBottom - GameConfig.obstacleMinDistanceBelowPlatform - h;
        if (gapEnd > gapStart) {
          safeYRanges.add((start: gapStart, end: gapEnd));
        }
      }
      if (i == platformPositions.length - 1) {
        final start = platformTop + GameConfig.obstacleMinDistanceAbovePlatform + h;
        safeYRanges.add((start: start, end: levelMaxY + 1000));
      }
    }
    if (safeYRanges.isEmpty) {
      safeYRanges.add((start: levelMinY, end: levelMaxY + 1000));
    }

    bool isValidPosition(double worldX, double worldY) {
      final obsBottom = obstacleBottom(worldY);
      final obsTop = obstacleTop(worldY);

      for (final platform in platformPositions) {
        final platformHalfWidth = platform['width']! / 2;
        final platformX = platform['x']!;
        final platformBottom = platform['bottom']!;
        final platformTop = platform['top']!;

        final horizontalOverlap =
            (worldX - obstacleHalfWidth < platformX + platformHalfWidth) &&
                (worldX + obstacleHalfWidth > platformX - platformHalfWidth);

        if (horizontalOverlap) {
          // Forbidden zone: [platformBottom - 200, platformTop + 500]
          // Obstacle must be entirely below or entirely above
          final forbiddenStart = platformBottom - GameConfig.obstacleMinDistanceBelowPlatform;
          final forbiddenEnd = platformTop + GameConfig.obstacleMinDistanceAbovePlatform;

          if (obsTop > forbiddenStart && obsBottom < forbiddenEnd) {
            return false; // Overlaps forbidden zone (on platform or too close)
          }
        }
      }
      return true;
    }

    for (int i = 0; i < obstacleCount; i++) {
      bool positionValid = false;
      double worldY = 0.0;
      double worldX = 0.0;

      // Strategy 1: Random placement with even spread
      for (int attempt = 0; attempt < 150 && !positionValid; attempt++) {
        final padding = screenWidth * 0.1;
        final minX = -screenWidth / 2 + padding;
        final maxX = screenWidth / 2 - padding;
        worldX = minX + random.nextDouble() * (maxX - minX);

        final segmentSize = levelRange / (obstacleCount + 1);
        final baseWorldY = levelMinY + segmentSize * (i + 1);
        final randomOffset = (random.nextDouble() - 0.5) * segmentSize * 0.6;
        worldY = baseWorldY + randomOffset;

        positionValid = isValidPosition(worldX, worldY);
      }

      // Strategy 2: Place in known safe Y ranges
      if (!positionValid) {
        for (final range in safeYRanges) {
          if (range.end <= range.start) continue;
          for (int attempt = 0; attempt < 30 && !positionValid; attempt++) {
            worldY = range.start + random.nextDouble() * (range.end - range.start);
            final padding = screenWidth * 0.1;
            final minX = -screenWidth / 2 + padding;
            final maxX = screenWidth / 2 - padding;
            worldX = minX + random.nextDouble() * (maxX - minX);
            positionValid = isValidPosition(worldX, worldY);
          }
          if (positionValid) break;
        }
      }

      if (positionValid) {
        obstacles.add(FlameObstacle(
          level: level,
          worldY: worldY,
          worldX: worldX,
        ));
      }
    }

    return obstacles;
  }

  /// Spawn a single obstacle at a specific world Y position
  static FlameObstacle spawnObstacleAt(double worldY, double screenWidth,
      GameLevel level, List<FlamePlatform> platforms) {
    final random = Random();
    final padding = screenWidth * 0.1;
    final minX = -screenWidth / 2 + padding;
    final maxX = screenWidth / 2 - padding;

    final obstacleWidth =
        screenWidth * (level.useLevel2Sizes ? 0.20 : 0.15);
    final obstacleHeightEst = obstacleWidth;
    final obstacleHalfWidth = obstacleWidth / 2;
    final obsBottom = worldY - obstacleHeightEst / 2;
    final obsTop = worldY + obstacleHeightEst / 2;

    double worldX = 0.0;
    bool positionValid = false;

    for (int attempt = 0; attempt < 100 && !positionValid; attempt++) {
      worldX = minX + random.nextDouble() * (maxX - minX);
      positionValid = true;

      for (final platform in platforms) {
        final platformWidth =
            screenWidth * (level.useLevel2Sizes ? 0.10 : 0.20);
        final platformHalfWidth = platformWidth / 2;
        final platformBottom = platform.worldY;
        final platformTop = platform.worldY + platform.size.y;

        final horizontalOverlap = (worldX - obstacleHalfWidth <
                platform.worldX + platformHalfWidth) &&
            (worldX + obstacleHalfWidth > platform.worldX - platformHalfWidth);

        if (horizontalOverlap) {
          final forbiddenStart =
              platformBottom - GameConfig.obstacleMinDistanceBelowPlatform;
          final forbiddenEnd =
              platformTop + GameConfig.obstacleMinDistanceAbovePlatform;
          if (obsTop > forbiddenStart && obsBottom < forbiddenEnd) {
            positionValid = false;
            break;
          }
        }
      }
    }

    return FlameObstacle(
      level: level,
      worldY: worldY,
      worldX: worldX,
    );
  }
}
