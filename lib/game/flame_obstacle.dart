import 'package:flame/components.dart';
import 'game_level.dart';

/// Obstacle component for Flame game engine
class FlameObstacle extends SpriteComponent with HasGameReference {
  double screenWidth = 0.0;
  final GameLevel level;

  /// World Y position (0 = bottom of world, increases upward)
  double worldY = 0.0;

  /// World X position (relative to center)
  double worldX = 0.0;

  /// Get obstacle width percent based on level
  double get obstacleWidthPercent {
    return level == GameLevel.level2 ? 0.20 : 0.15;
  }

  FlameObstacle({
    required this.level,
    required this.worldY,
    required this.worldX,
  });

  @override
  Future<void> onLoad() async {
    // Load obstacle sprite
    sprite = await game.loadSprite('obstacle.png');

    // Get original sprite dimensions to maintain aspect ratio
    final originalSize = sprite!.originalSize;
    final aspectRatio = originalSize.y / originalSize.x;

    // Set initial size based on screen
    if (game.size.x > 0) {
      screenWidth = game.size.x;
      final obstacleWidth = screenWidth * obstacleWidthPercent;
      final obstacleHeight = obstacleWidth * aspectRatio;

      size = Vector2(obstacleWidth, obstacleHeight);
    } else {
      // Default size if screen not ready yet
      size = originalSize;
    }

    // Position will be updated based on camera
    anchor = Anchor.center;
  }

  /// Update obstacle position based on camera
  void updatePosition(double cameraY) {
    // Only update if game size is available
    if (game.size.x > 0 && game.size.y > 0) {
      position = Vector2(
        game.size.x / 2 + worldX,
        game.size.y - (worldY - cameraY), // Convert world Y to screen Y
      );
    }
  }

  /// Update screen dimensions when screen size changes
  void updateScreenDimensions(double newScreenWidth, double cameraY) {
    screenWidth = newScreenWidth;

    // Recalculate size maintaining aspect ratio (only if sprite is loaded)
    if (sprite != null) {
      final originalSize = sprite!.originalSize;
      final aspectRatio = originalSize.y / originalSize.x;
      final obstacleWidth = screenWidth * obstacleWidthPercent;
      final obstacleHeight = obstacleWidth * aspectRatio;

      size = Vector2(obstacleWidth, obstacleHeight);
    }

    // Update position based on camera
    updatePosition(cameraY);
  }
}
