import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'flame_character.dart';
import 'flame_platform.dart';
import 'flame_obstacle.dart';
import 'flame_vent.dart';
import 'game_level.dart';
import 'game_config.dart';
import 'platform_spawner.dart';

/// Main game class using Flame engine
class TiltAndPlayGame extends FlameGame {
  late FlameCharacter character;
  late FlamePlatform basePlatform;
  late FlameVent vent;
  List<FlamePlatform> platforms = [];
  List<FlameObstacle> obstacles = [];
  GameLevel gameLevel = GameLevel.tutorial;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _currentTiltX = 0.0;
  bool _isInitialized = false;
  bool _gameWon = false;
  final ValueNotifier<bool> gameWonNotifier = ValueNotifier<bool>(false);
  bool _gameLost = false;
  final ValueNotifier<bool> gameLostNotifier = ValueNotifier<bool>(false);

  // Camera system
  double _cameraY = 0.0; // Camera Y position (world coordinates, 0 = bottom)
  double _highestCharacterY =
      0.0; // Track highest position character has reached

  /// Current accelerometer X value (for debug display)
  double get currentTiltX => _currentTiltX;

  /// Whether the game has been won
  bool get gameWon => _gameWon;

  /// Whether the game has been lost
  bool get gameLost => _gameLost;

  @override
  Color backgroundColor() => Colors.transparent;

  /// Initialize game with a specific level
  void initializeLevel(GameLevel level) {
    gameLevel = level;
  }

  @override
  Future<void> onLoad() async {
    // Wait for game size to be available
    while (size.x == 0 || size.y == 0) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Initialize camera at bottom
    _cameraY = 0.0;
    _highestCharacterY = 0.0;

    // Create and add base platform at bottom (world Y = 0)
    basePlatform = FlamePlatform();
    await add(basePlatform);
    basePlatform.updatePosition(_cameraY);

    // Spawn initial platforms based on level
    platforms = PlatformSpawner.spawnInitialPlatforms(gameLevel, size.x);
    for (final platform in platforms) {
      await add(platform);
      platform.updatePosition(_cameraY);
    }

    // Spawn initial obstacles based on level (avoiding platforms)
    obstacles =
        PlatformSpawner.spawnInitialObstacles(gameLevel, size.x, platforms);
    for (final obstacle in obstacles) {
      await add(obstacle);
      obstacle.updatePosition(_cameraY);
    }

    // Create and add vent at top (world Y = highest platform + spacing)
    final highestPlatformY = platforms.isEmpty
        ? GameConfig.platformSpacing
        : platforms.map((p) => p.worldY).reduce((a, b) => a > b ? a : b);
    vent = FlameVent();
    vent.setWorldY(highestPlatformY + GameConfig.platformSpacing);
    await add(vent);
    vent.updatePosition(_cameraY);

    // Create and add character
    character = FlameCharacter();
    await add(character);
    character.updateScreenDimensions(size.x, _cameraY);

    // Start accelerometer
    _startAccelerometer();

    // Audio: use sounds/ prefix (assets/sounds/sfx/, assets/sounds/music/)
    FlameAudio.updatePrefix('assets/sounds/');
    FlameAudio.bgm.initialize();
    FlameAudio.play('sfx/game-start.mp3');
    FlameAudio.bgm.play('music/music.mp3');
  }

  void _startAccelerometer() {
    if (_isInitialized) return;

    try {
      _accelerometerSubscription = accelerometerEventStream(
              samplingPeriod: const Duration(milliseconds: 10))
          .listen(
        (AccelerometerEvent event) {
          // Store current tilt value
          // Negative X = tilt left (move left), Positive X = tilt right (move right)
          _currentTiltX = event.x;
        },
        onError: (error) {
          _currentTiltX = 0.0;
          character.stop();
        },
        cancelOnError: false,
      );
      _isInitialized = true;
    } catch (e) {
      _currentTiltX = 0.0;
      character.stop();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameWon || _gameLost) return; // Stop updates if game is won or lost

    // Update character velocity based on tilt
    character.updateVelocity(_currentTiltX, dt);

    // Update character position
    character.updatePosition(dt, _cameraY);

    // Update camera to follow character upward (only upward, not downward)
    if (character.worldY > _highestCharacterY) {
      _highestCharacterY = character.worldY;
      // Camera follows character, but keep character in upper portion of screen
      _cameraY =
          _highestCharacterY - size.y * 0.3; // Character stays at 30% from top
      if (_cameraY < 0) _cameraY = 0; // Don't go below world bottom
    }

    // Update all component positions based on camera
    basePlatform.updatePosition(_cameraY);
    vent.updatePosition(_cameraY);
    for (final platform in platforms) {
      platform.updatePosition(_cameraY);
    }
    for (final obstacle in obstacles) {
      obstacle.updatePosition(_cameraY);
    }

    // Check collision with base platform and apply bounce
    character.checkPlatformCollision(basePlatform, _cameraY);

    // Check collision with all spawned platforms
    for (final platform in platforms) {
      character.checkPlatformCollision(platform, _cameraY);
    }

    // Check collision with all obstacles (lose condition)
    for (final obstacle in obstacles) {
      if (character.checkObstacleCollision(obstacle)) {
        onLose();
        break;
      }
    }

    // Remove platforms that are too far below camera
    platforms.removeWhere((platform) {
      if (platform.worldY < _cameraY - GameConfig.platformDespawnDistance) {
        platform.removeFromParent();
        return true;
      }
      return false;
    });

    // Remove obstacles that are too far below camera
    obstacles.removeWhere((obstacle) {
      if (obstacle.worldY < _cameraY - GameConfig.platformDespawnDistance) {
        obstacle.removeFromParent();
        return true;
      }
      return false;
    });

    // Spawn new platforms above camera view (but stop before vent)
    if (!_gameWon) {
      double currentHighestY = _cameraY;
      if (platforms.isNotEmpty) {
        currentHighestY =
            platforms.map((p) => p.worldY).reduce((a, b) => a > b ? a : b);
      }

      final spawnThreshold =
          _cameraY + size.y + GameConfig.platformSpawnDistance;
      // Don't spawn platforms beyond the vent - stop spawning if we'd go past the vent
      final ventY = vent.worldY;

      while (currentHighestY < spawnThreshold &&
          currentHighestY < ventY - GameConfig.platformSpacing) {
        final newPlatformY = currentHighestY + GameConfig.platformSpacing;
        // Make sure we don't spawn a platform at or above the vent
        if (newPlatformY >= ventY - GameConfig.platformSpacing) {
          break;
        }

        final newPlatform = PlatformSpawner.spawnPlatformAt(
          newPlatformY,
          size.x,
          gameLevel,
        );
        platforms.add(newPlatform);
        add(newPlatform);
        newPlatform.updatePosition(_cameraY);

        // Spawn obstacle near this platform (if we haven't reached obstacle limit)
        if (obstacles.length < gameLevel.obstacleCount * 2) {
          final obstacleY = newPlatformY + GameConfig.platformSpacing * 0.3;
          final newObstacle = PlatformSpawner.spawnObstacleAt(
            obstacleY,
            size.x,
            gameLevel,
            platforms,
          );
          obstacles.add(newObstacle);
          add(newObstacle);
          newObstacle.updatePosition(_cameraY);
        }

        currentHighestY = newPlatformY;
      }
    }

    // Check collision with vent (win condition)
    if (character.checkVentCollision(vent)) {
      onWin();
    }

    // Check if character fell off the bottom of the screen (lose condition)
    // Character's position is already in screen coordinates (center anchor)
    if (size.y > 0) {
      final characterBottom = character.position.y + character.size.y / 2;
      // Character is below the screen (with some margin)
      if (characterBottom > size.y + 50) {
        onLose();
      }
    }

    // Update screen dimensions if screen size changed
    if (size.x > 0) {
      if (character.screenWidth != size.x) {
        character.updateScreenDimensions(size.x, _cameraY);
      }
      if (basePlatform.screenWidth != size.x) {
        basePlatform.updateScreenDimensions(size.x, _cameraY);
      }
      if (vent.screenWidth != size.x) {
        vent.updateScreenDimensions(size.x, _cameraY);
      }
      for (final platform in platforms) {
        if (platform.screenWidth != size.x) {
          platform.updateScreenDimensions(size.x, _cameraY);
        }
      }
    }
  }

  /// Called when player wins
  void onWin() {
    if (!_gameWon && !_gameLost) {
      _gameWon = true;
      gameWonNotifier.value = true;
      FlameAudio.bgm.stop();
      pauseEngine();
    }
  }

  /// Called when player loses
  void onLose() {
    if (!_gameLost && !_gameWon) {
      _gameLost = true;
      gameLostNotifier.value = true;
      FlameAudio.bgm.stop();
      FlameAudio.play('sfx/game-over.mp3');
      pauseEngine();
    }
  }

  @override
  void onRemove() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isInitialized = false;
    FlameAudio.bgm.stop();
    gameWonNotifier.dispose();
    super.onRemove();
  }

  /// Reset game state
  void resetGame() {
    _gameWon = false;
    gameWonNotifier.value = false;
    _gameLost = false;
    gameLostNotifier.value = false;
    _cameraY = 0.0;
    _highestCharacterY = 0.0;

    // Remove all spawned platforms
    for (final platform in platforms) {
      platform.removeFromParent();
    }
    platforms.clear();

    // Remove all spawned obstacles
    for (final obstacle in obstacles) {
      obstacle.removeFromParent();
    }
    obstacles.clear();

    // Respawn initial platforms
    platforms = PlatformSpawner.spawnInitialPlatforms(gameLevel, size.x);
    for (final platform in platforms) {
      add(platform);
      platform.updatePosition(_cameraY);
    }

    // Respawn initial obstacles
    obstacles =
        PlatformSpawner.spawnInitialObstacles(gameLevel, size.x, platforms);
    for (final obstacle in obstacles) {
      add(obstacle);
      obstacle.updatePosition(_cameraY);
    }

    // Reset vent position
    final highestPlatformY = platforms.isEmpty
        ? GameConfig.platformSpacing
        : platforms.map((p) => p.worldY).reduce((a, b) => a > b ? a : b);
    vent.setWorldY(highestPlatformY + GameConfig.platformSpacing);
    vent.updatePosition(_cameraY);

    // Reset base platform
    basePlatform.updatePosition(_cameraY);

    character.reset();
    character.updateScreenDimensions(size.x, _cameraY);
    FlameAudio.play('sfx/game-start.mp3');
    FlameAudio.bgm.play('music/music.mp3');
    resumeEngine();
  }
}
