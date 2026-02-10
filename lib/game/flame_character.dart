import 'package:flame/components.dart';
import 'game_config.dart';
import 'flame_platform.dart';
import 'flame_obstacle.dart';
import 'flame_vent.dart';

/// Character component for Flame game engine
class FlameCharacter extends SpriteComponent with HasGameReference {
  double _velocity = 0.0; // Horizontal velocity
  double _velocityY = 0.0; // Vertical velocity
  double screenWidth = 0.0;
  double _positionX = 0.0; // Position relative to center (horizontal)
  double _worldY =
      0.0; // World Y position (0 = bottom of world, increases upward)
  double _targetWorldY = 0.0; // Target world Y for smooth interpolation
  bool _isFacingLeft = false;

  /// Get world Y position
  double get worldY => _worldY;

  /// Current velocity (pixels per second)
  double get velocity => _velocity;

  /// Whether the character is facing left
  bool get isFacingLeft {
    if (_velocity == 0.0) {
      return _isFacingLeft;
    }
    return _velocity < 0;
  }

  @override
  Future<void> onLoad() async {
    // Load character sprite (Flame loads from assets folder)
    sprite = await game.loadSprite('character.png');

    // Set initial size based on screen
    if (game.size.x > 0) {
      screenWidth = game.size.x;
      size = Vector2(
        screenWidth * GameConfig.characterWidthPercent,
        screenWidth * GameConfig.characterWidthPercent,
      );
    } else {
      // Default size if screen not ready yet
      size = Vector2(100, 100);
    }

    // Center the character initially (horizontally, at bottom of world)
    anchor = Anchor.center;
    if (game.size.y > 0) {
      _worldY = game.size.y * 0.15; // Start slightly above bottom
      _targetWorldY = _worldY; // Initialize target position
      position = Vector2(
        game.size.x / 2,
        game.size.y - _worldY, // Position from bottom
      );
    } else {
      // Default position if game size not available yet
      _worldY = 100.0;
      _targetWorldY = _worldY;
      position = Vector2(400, 600);
    }
  }

  /// Update screen dimensions when screen size changes
  void updateScreenDimensions(double newScreenWidth, double cameraY) {
    screenWidth = newScreenWidth;
    final newSize = screenWidth * GameConfig.characterWidthPercent;
    size = Vector2(newSize, newSize);

    // Recalculate position based on world Y and camera (only if game size is available)
    if (game.size.y > 0) {
      position = Vector2(
        screenWidth / 2 + _positionX,
        game.size.y - (_worldY - cameraY), // Convert world Y to screen Y
      );
    }
  }

  /// Update velocity based on tilt
  void updateVelocity(double tiltX, double deltaTime) {
    // Apply dead zone - ignore small tilts
    double processedTilt = tiltX.abs() < GameConfig.deadZone ? 0.0 : tiltX;
    processedTilt *= -1;

    // double velocityChange = processedTilt * GameConfig.sensitivity;
    double targetVelocity =
        processedTilt * processedTilt * GameConfig.sensitivity;

    if (processedTilt < 0) {
      targetVelocity = -targetVelocity;
    }

    _velocity -=
        (_velocity - targetVelocity) * deltaTime * GameConfig.acceleration;

    _velocity =
        _velocity.clamp(-GameConfig.maxVelocity, GameConfig.maxVelocity);

    // Update facing direction when moving
    if (_velocity.abs() > 0.01) {
      _isFacingLeft = _velocity < 0;
    }
  }

  /// Update character position (called from game with camera offset)
  void updatePosition(double dt, double cameraY) {
    // Clamp delta time to prevent large jumps (smooth physics)
    final clampedDt = dt.clamp(0.0, 1.0 / 60.0); // Max 30 FPS equivalent

    // Apply gravity to vertical velocity (negative = downward in world space)
    _velocityY -= GameConfig.gravity * clampedDt;

    // Update horizontal position based on velocity
    _positionX += _velocity * clampedDt;

    // Update target world Y position based on velocity (positive Y = upward)
    _targetWorldY += _velocityY * clampedDt;

    // Prevent character from going below world bottom
    if (_targetWorldY < 0) {
      _targetWorldY = 0;
      _velocityY = 0;
    }

    // Smooth interpolation for vertical position to reduce stuttering
    // Use lerp to smoothly transition to target position
    // Higher factor = more responsive, lower = smoother
    const smoothingFactor =
        0.7; // Balance between smoothness and responsiveness
    _worldY += (_targetWorldY - _worldY) * smoothingFactor;

    // Clamp horizontal position to screen bounds
    if (screenWidth > 0) {
      final maxPosition = (screenWidth - size.x) / 2;
      _positionX = _positionX.clamp(-maxPosition, maxPosition);
    }

    // Update sprite position based on world Y and camera (only if game size is available)
    if (game.size.x > 0 && game.size.y > 0) {
      position = Vector2(
        game.size.x / 2 + _positionX,
        game.size.y - (_worldY - cameraY), // Convert world Y to screen Y
      );
    }

    // Flip sprite based on facing direction
    if (isFacingLeft) {
      scale = Vector2(-1.0, 1.0);
    } else {
      scale = Vector2(1.0, 1.0);
    }
  }

  /// Check collision with platform and apply bounce
  void checkPlatformCollision(FlamePlatform platform, double cameraY) {
    // Get character bounds (using center anchor)
    final charLeft = position.x - size.x / 2;
    final charRight = position.x + size.x / 2;
    final charBottom = position.y + size.y / 2;

    // Get platform bounds (using bottomCenter anchor)
    final platformLeft = platform.position.x - platform.size.x / 2;
    final platformRight = platform.position.x + platform.size.x / 2;
    final platformTop = platform.position.y - platform.size.y;
    final platformBottom = platform.position.y;

    // Check if character is colliding with platform
    // Character must be above platform and falling down
    if (_velocityY <
            0 && // Falling down (negative velocityY = downward in world space)
        charBottom >= platformTop &&
        charBottom <= platformBottom &&
        charRight > platformLeft &&
        charLeft < platformRight) {
      // Character is on top of platform
      // Position character just above platform in world space
      final platformWorldY = platform.worldY;
      _targetWorldY = platformWorldY + size.y / 2;
      _worldY = _targetWorldY; // Snap to position on collision

      // Apply upward bounce force (positive velocityY = upward in world space)
      _velocityY = GameConfig.bounceForce;
    }
  }

  /// Reset character to initial position
  void reset() {
    _positionX = 0.0;
    _worldY = game.size.y * 0.15; // Reset to initial height
    _targetWorldY = _worldY; // Reset target as well
    _velocity = 0.0;
    _velocityY = 0.0;
  }

  /// Stop character movement
  void stop() {
    _velocity = 0.0;
  }

  /// Check collision with vent (win condition)
  bool checkVentCollision(FlameVent vent) {
    // Get character bounds (using center anchor)
    final charLeft = position.x - size.x / 2;
    final charRight = position.x + size.x / 2;
    final charTop = position.y - size.y / 2;
    final charBottom = position.y + size.y / 2;

    // Get vent bounds (using topCenter anchor)
    final ventLeft = vent.position.x - vent.size.x / 2;
    final ventRight = vent.position.x + vent.size.x / 2;
    final ventTop = vent.position.y;
    final ventBottom = vent.position.y + vent.size.y;

    // Check if character is colliding with vent
    if (charRight > ventLeft &&
        charLeft < ventRight &&
        charBottom > ventTop &&
        charTop < ventBottom) {
      return true; // Collision detected
    }
    return false;
  }

  /// Check collision with obstacle (lose condition)
  /// Uses a smaller collision area than the sprite (10% smaller width, 5% smaller height)
  bool checkObstacleCollision(FlameObstacle obstacle) {
    // Get character bounds (using center anchor)
    final charLeft = position.x - size.x / 2;
    final charRight = position.x + size.x / 2;
    final charTop = position.y - size.y / 2;
    final charBottom = position.y + size.y / 2;

    // Get obstacle collision bounds (using center anchor, but smaller than sprite)
    // Collision width is 10% smaller (90% of sprite width)
    // Collision height is 5% smaller (95% of sprite height)
    final collisionWidth = obstacle.size.x * 0.9;
    final collisionHeight = obstacle.size.y * 0.95;

    final obstacleLeft = obstacle.position.x - collisionWidth / 2;
    final obstacleRight = obstacle.position.x + collisionWidth / 2;
    final obstacleTop = obstacle.position.y - collisionHeight / 2;
    final obstacleBottom = obstacle.position.y + collisionHeight / 2;

    // Check if character is colliding with obstacle's collision area
    if (charRight > obstacleLeft &&
        charLeft < obstacleRight &&
        charBottom > obstacleTop &&
        charTop < obstacleBottom) {
      return true; // Collision detected
    }
    return false;
  }
}
