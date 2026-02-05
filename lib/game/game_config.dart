/// Game configuration constants
class GameConfig {
  // Character settings
  static const double characterWidthPercent = 0.1; // 10% of screen width
  
  // Movement settings
  static const double sensitivity = 200.0; // Velocity multiplier
  static const double deadZone = 0.3; // Ignore small tilts
  static const double maxVelocity = 500.0; // Maximum velocity (pixels per second)
  
  // Animation settings
  static const int animationFrameDuration = 16; // ~60 FPS
}
