import 'package:flutter/material.dart';
import '../game/character.dart';
import '../game/game_controller.dart';
import '../game/game_config.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Character _character;
  late GameController _gameController;

  @override
  void initState() {
    super.initState();

    // Initialize game logic
    _character = Character();
    _gameController = GameController(_character);

    // Initialize animation controller for smooth updates
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: GameConfig.animationFrameDuration),
    );

    // Update game state each frame
    _animationController.addListener(() {
      if (mounted) {
        _gameController.update();
        setState(() {}); // Trigger rebuild to show updated position
      }
    });

    // Start continuous animation
    _animationController.repeat();

    // Delay accelerometer start to ensure widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gameController.startAccelerometer();
      }
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showMenu(BuildContext context) {
    showDialog(
      context: context,
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
                  // TODO: Implement restart functionality
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Update screen dimensions in character
    final screenSize = MediaQuery.of(context).size;
    _character.updateScreenDimensions(screenSize.width);

    // Calculate center position
    final centerX = screenSize.width / 2 - _character.characterWidth / 2;
    final centerY = screenSize.height / 2 - _character.characterWidth / 2;

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
              // Character image that moves based on accelerometer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                left: centerX + _character.position,
                top: centerY,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(_character.isMovingLeft ? -1.0 : 1.0,
                        1.0), // Mirror when moving left
                  child: Image.asset(
                    'assets/character.png',
                    width: _character.characterWidth,
                    height: _character.characterWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Menu button in bottom left
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
