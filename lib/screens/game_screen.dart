import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/flame_game.dart';
import '../game/game_level.dart';
import 'main_menu_screen.dart';
import 'debug_overlay.dart';
import 'win_overlay.dart';
import 'lose_overlay.dart';

class GameScreen extends StatefulWidget {
  final GameLevel level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TiltAndPlayGame _game;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _game = TiltAndPlayGame();
    _game.initializeLevel(widget.level);
    // Pause the game during loading
    _game.pauseEngine();
    _waitForGameLoad();
  }

  Future<void> _waitForGameLoad() async {
    // Wait for the game to be fully loaded
    // Give it time to initialize all components
    await Future.delayed(const Duration(milliseconds: 100));

    // Wait for game size to be available and components to load
    while (_game.size.x == 0 || _game.size.y == 0) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Additional delay to ensure all sprites are loaded
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Resume the game once loading is complete
      _game.resumeEngine();
    }
  }

  void _showMenu(BuildContext context) {
    // Pause the game when menu opens
    _game.pauseEngine();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Restart'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Restart the game
                  _game.resetGame();
                  // Resume the game after restart
                  _game.resumeEngine();
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Quit'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainMenuScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Resume the game when menu is closed (if not quitting)
      if (mounted) {
        _game.resumeEngine();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Flame game widget - handles rendering and updates efficiently
              GameWidget<TiltAndPlayGame>.controlled(
                gameFactory: () => _game,
              ),
              // Loading overlay - shows while game is initializing
              if (_isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.9),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              // Debug overlay - shows FPS, velocity, and accelerometer data
              if (!_isLoading) DebugOverlay(game: _game),
              // Win overlay - shows when player wins
              if (!_isLoading) WinOverlay(game: _game),
              // Lose overlay - shows when player loses
              if (!_isLoading) LoseOverlay(game: _game),
              // Menu button in bottom left
              if (!_isLoading)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () => _showMenu(context),
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    child: const Icon(Icons.menu, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
