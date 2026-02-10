import 'package:flame/components.dart';

/// Vent component at the top of the screen - win condition
class FlameVent extends SpriteComponent with HasGameReference {
  static const double ventWidthPercent = 0.15; // 15% of screen width
  double screenWidth = 0.0;
  double worldY = 0.0; // World Y position (will be set based on level)

  @override
  Future<void> onLoad() async {
    // Load vent sprite
    sprite = await game.loadSprite('vent.png');

    // Get original sprite dimensions to maintain aspect ratio
    final originalSize = sprite!.originalSize;
    final aspectRatio = originalSize.y / originalSize.x;

    // Set initial size based on screen
    if (game.size.x > 0) {
      screenWidth = game.size.x;
      final ventWidth = screenWidth * ventWidthPercent;
      final ventHeight = ventWidth * aspectRatio;

      size = Vector2(ventWidth, ventHeight);
    } else {
      // Default size if screen not ready yet
      size = originalSize;
    }

    // Position will be updated based on camera
    anchor = Anchor.topCenter;
  }
  
  /// Set world Y position for the vent
  void setWorldY(double y) {
    worldY = y;
  }
  
  /// Update vent position based on camera
  void updatePosition(double cameraY) {
    // Only update if game size is available
    if (game.size.x > 0 && game.size.y > 0) {
      position = Vector2(
        game.size.x / 2,
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
      final ventWidth = screenWidth * ventWidthPercent;
      final ventHeight = ventWidth * aspectRatio;

      size = Vector2(ventWidth, ventHeight);
    }

    // Update position based on camera
    updatePosition(cameraY);
  }
}
