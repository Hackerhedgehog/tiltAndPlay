/// Game configuration constants
class GameConfig {
  // Character settings
  static const double characterWidthPercent = 0.1; // 10% of screen width

  // Movement settings
  static const double sensitivity = 150.0; // Velocity multiplier
  static const double deadZone = 0.3; // Ignore small tilts
  /// Maps web joystick (-1..1) into the same ballpark as accelerometer X (m/s²).
  static const double webJoystickSimulatedTiltMax = 8.0;
  static const double maxVelocity = 400.0;
  static const double acceleration = 2.5;

  // Physics settings
  static const double gravity =
      800.0; // Gravity acceleration (pixels per second squared)
  static const double bounceForce =
      800.0; // Upward force when hitting platform (pixels per second)

  // Camera settings
  static const double maxJumpHeight = 600.0; // Maximum jump height (pixels)
  static const double obstacleMinDistanceAbovePlatform =
      500.0; // Obstacle must be at least this far above platform top
  static const double obstacleMinDistanceBelowPlatform =
      200.0; // Obstacle must be at least this far below platform bottom
  static const double platformSpacing =
      300.0; // Vertical spacing between platforms (pixels)
  static const double platformSpawnDistance =
      200.0; // Distance above camera to spawn platforms
  static const double platformDespawnDistance =
      300.0; // Distance below camera to despawn platforms

  // Animation settings
  static const int animationFrameDuration = 16; // ~60 FPS
}
