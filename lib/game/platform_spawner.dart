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
      final randomOffset = (random.nextDouble() - 0.5) * GameConfig.platformSpacing * 0.3;
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
  static FlamePlatform spawnPlatformAt(double worldY, double screenWidth, GameLevel level) {
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

    // Calculate platform positions for overlap checking
    final platformPositions = <Map<String, double>>[];
    for (final p in platforms) {
      platformPositions.add({
        'y': p.worldY,
        'x': p.worldX,
        'width': screenWidth * (level == GameLevel.level2 ? 0.10 : 0.20),
      });
    }

    // Spawn obstacles with proper vertical spacing, avoiding platforms
    for (int i = 0; i < obstacleCount; i++) {
      int attempts = 0;
      bool positionValid = false;
      double worldY = 0.0;
      double worldX = 0.0;

      // Try to find a valid position that doesn't overlap with platforms
      while (!positionValid && attempts < 50) {
        attempts++;
        
        // Random X position (with some padding from edges)
        final padding = screenWidth * 0.1;
        final minX = -screenWidth / 2 + padding;
        final maxX = screenWidth / 2 - padding;
        worldX = minX + random.nextDouble() * (maxX - minX);
        
        // World Y position - space obstacles vertically
        final baseWorldY = GameConfig.platformSpacing * (i + 1) + GameConfig.platformSpacing * 0.5;
        final randomOffset = (random.nextDouble() - 0.5) * GameConfig.platformSpacing * 0.4;
        worldY = baseWorldY + randomOffset;
        
        // Check if this position overlaps with any platform
        positionValid = true;
        final obstacleWidth = screenWidth * (level == GameLevel.level2 ? 0.20 : 0.15);
        final obstacleHalfWidth = obstacleWidth / 2;
        
        for (final platform in platformPositions) {
          final platformWidth = platform['width']!;
          final platformHalfWidth = platformWidth / 2;
          final platformX = platform['x']!;
          final platformY = platform['y']!;
          
          // Check horizontal overlap
          final horizontalOverlap = (worldX - obstacleHalfWidth < platformX + platformHalfWidth) &&
              (worldX + obstacleHalfWidth > platformX - platformHalfWidth);
          
          // Check vertical overlap (within 50 pixels)
          final verticalOverlap = (worldY - 50 < platformY + 50) &&
              (worldY + 50 > platformY - 50);
          
          if (horizontalOverlap && verticalOverlap) {
            positionValid = false;
            break;
          }
        }
      }

      if (positionValid) {
        final obstacle = FlameObstacle(
          level: level,
          worldY: worldY,
          worldX: worldX,
        );
        obstacles.add(obstacle);
      }
    }

    return obstacles;
  }

  /// Spawn a single obstacle at a specific world Y position
  static FlameObstacle spawnObstacleAt(
      double worldY, double screenWidth, GameLevel level, List<FlamePlatform> platforms) {
    final random = Random();
    final padding = screenWidth * 0.1;
    final minX = -screenWidth / 2 + padding;
    final maxX = screenWidth / 2 - padding;
    
    int attempts = 0;
    double worldX = 0.0;
    bool positionValid = false;

    // Try to find a valid position that doesn't overlap with platforms
    while (!positionValid && attempts < 50) {
      attempts++;
      worldX = minX + random.nextDouble() * (maxX - minX);
      
      // Check if this position overlaps with any platform
      positionValid = true;
      final obstacleWidth = screenWidth * (level == GameLevel.level2 ? 0.20 : 0.15);
      final obstacleHalfWidth = obstacleWidth / 2;
      
      for (final platform in platforms) {
        final platformWidth = screenWidth * (level == GameLevel.level2 ? 0.10 : 0.20);
        final platformHalfWidth = platformWidth / 2;
        
        // Check horizontal overlap
        final horizontalOverlap = (worldX - obstacleHalfWidth < platform.worldX + platformHalfWidth) &&
            (worldX + obstacleHalfWidth > platform.worldX - platformHalfWidth);
        
        // Check vertical overlap (within 50 pixels)
        final verticalOverlap = (worldY - 50 < platform.worldY + 50) &&
            (worldY + 50 > platform.worldY - 50);
        
        if (horizontalOverlap && verticalOverlap) {
          positionValid = false;
          break;
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
