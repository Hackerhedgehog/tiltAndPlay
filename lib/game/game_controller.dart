import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'character.dart';

/// Game controller that manages accelerometer input and character updates
class GameController {
  final Character character;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime _lastUpdateTime = DateTime.now();
  bool _isInitialized = false;

  GameController(this.character);

  /// Start listening to accelerometer
  void startAccelerometer() {
    if (_isInitialized) return;
    
    try {
      _lastUpdateTime = DateTime.now();
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          // Use X-axis for left/right movement
          // Negative X = tilt left (move left), Positive X = tilt right (move right)
          character.updateVelocity(event.x);
        },
        onError: (error) {
          // Handle error (e.g., sensor not available)
          print('Accelerometer error: $error');
          character.stop();
        },
        cancelOnError: false,
      );
      _isInitialized = true;
    } catch (e) {
      // Handle initialization error
      print('Failed to start accelerometer: $e');
      character.stop();
    }
  }

  /// Update game state (call this each frame)
  void update() {
    final now = DateTime.now();
    final deltaTime = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;

    character.updatePosition(deltaTime);
  }

  /// Stop accelerometer and clean up
  void dispose() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isInitialized = false;
  }

  /// Reset game state
  void reset() {
    character.reset();
  }
}
