import 'package:flame/components.dart';
import 'game_level.dart';

/// Platform component for Flame game engine
class FlamePlatform extends SpriteComponent with HasGameReference {
  double screenWidth = 0.0;
  final GameLevel? level;

  /// Get platform width percent based on level
  double get platformWidthPercent {
    if (level == null) return 0.20; // Default for base platform
    return level == GameLevel.level2 ? 0.10 : 0.20;
  }

  /// World Y position (0 = bottom of world, increases upward)
  double worldY = 0.0;

  /// World X position (relative to center)
  double worldX = 0.0;

  /// Whether this is a spawned platform (not the base platform)
  bool isSpawned = false;

  FlamePlatform({double? worldY, double? worldX, this.level}) {
    if (worldY != null) {
      this.worldY = worldY;
      this.worldX = worldX ?? 0.0;
      isSpawned = true;
    } else {
      // Base platform at bottom
      this.worldY = 0.0;
      this.worldX = 0.0;
      isSpawned = false;
    }
  }

  @override
  Future<void> onLoad() async {
    // Load platform sprite
    sprite = await game.loadSprite('platform.png');

    // Get original sprite dimensions to maintain aspect ratio
    final originalSize = sprite!.originalSize;
    final aspectRatio = originalSize.y / originalSize.x;

    // Set initial size based on screen
    if (game.size.x > 0) {
      screenWidth = game.size.x;
      final platformWidth = screenWidth * platformWidthPercent;
      final platformHeight = platformWidth * aspectRatio;

      size = Vector2(platformWidth, platformHeight);
    } else {
      // Default size if screen not ready yet
      size = originalSize;
    }

    // Position will be updated based on camera
    anchor = Anchor.bottomCenter;
    // Initial position will be set by updatePosition
  }

  /// Update platform position based on camera
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
      final platformWidth = screenWidth * platformWidthPercent;
      final platformHeight = platformWidth * aspectRatio;

      size = Vector2(platformWidth, platformHeight);
    }

    // Update position based on camera
    updatePosition(cameraY);
  }
}
