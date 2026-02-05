import 'game_config.dart';

/// Character class that handles position, velocity, and movement logic
class Character {
  double _position = 0.0;
  double _velocity = 0.0;
  double _screenWidth = 0.0;
  double _characterWidth = 0.0;

  /// Current horizontal position (relative to center, in pixels)
  double get position => _position;

  /// Current velocity (pixels per second)
  /// Negative = moving left, Positive = moving right
  double get velocity => _velocity;

  /// Whether the character is moving left
  bool get isMovingLeft => _velocity < 0;

  /// Character width based on screen width
  double get characterWidth => _characterWidth;

  /// Update screen dimensions
  void updateScreenDimensions(double screenWidth) {
    _screenWidth = screenWidth;
    _characterWidth = screenWidth * GameConfig.characterWidthPercent;
  }

  /// Update velocity based on tilt
  void updateVelocity(double tiltX) {
    // Apply dead zone - ignore small tilts
    double processedTilt = tiltX.abs() < GameConfig.deadZone ? 0.0 : tiltX;

    // Calculate velocity based on tilt
    // Negative tilt = negative velocity (move left)
    // Positive tilt = positive velocity (move right)
    double newVelocity = processedTilt * GameConfig.sensitivity;

    // Clamp velocity to maximum
    _velocity = newVelocity.clamp(-GameConfig.maxVelocity, GameConfig.maxVelocity);
  }

  /// Update position based on velocity and delta time
  void updatePosition(double deltaTime) {
    // Update position based on velocity (pixels per second)
    _position += _velocity * deltaTime;

    // Clamp position to screen bounds
    if (_screenWidth > 0) {
      final maxPosition = (_screenWidth - _characterWidth) / 2;
      _position = _position.clamp(-maxPosition, maxPosition);
    }
  }

  /// Reset character to center position
  void reset() {
    _position = 0.0;
    _velocity = 0.0;
  }

  /// Stop character movement
  void stop() {
    _velocity = 0.0;
  }
}
