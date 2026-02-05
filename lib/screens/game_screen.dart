import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  double _currentPosition = 0.0;
  double _targetPosition = 0.0;
  double _screenWidth = 0.0;
  static const double _characterWidth = 300.0;
  static const double _sensitivity = 50.0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _positionAnimation = Tween<double>(
      begin: _currentPosition,
      end: _targetPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _positionAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _positionAnimation.value;
        });
      }
    });

    // Delay accelerometer start to ensure widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAccelerometer();
      }
    });
  }

  void _startAccelerometer() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          if (!mounted) return;

          // Use X-axis for left/right movement
          // Negative X = tilt left, Positive X = tilt right
          double newPosition = event.x * _sensitivity;

          // Clamp position to screen bounds (will be updated in build)
          if (_screenWidth > 0) {
            final maxPosition = (_screenWidth - _characterWidth) / 2;
            newPosition = newPosition.clamp(-maxPosition, maxPosition);
          }

          if ((_targetPosition - newPosition).abs() > 0.1) {
            if (mounted) {
              setState(() {
                _targetPosition = newPosition;
                _positionAnimation = Tween<double>(
                  begin: _currentPosition,
                  end: _targetPosition,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ));
              });
              if (mounted) {
                _animationController.forward(from: 0.0);
              }
            }
          }
        },
        onError: (error) {
          // Handle error (e.g., sensor not available)
          if (mounted) {
            print('Accelerometer error: $error');
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        print('Failed to start accelerometer: $e');
      }
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
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
    // Update screen width for bounds calculation
    final screenSize = MediaQuery.of(context).size;
    _screenWidth = screenSize.width;

    // Calculate center position
    final centerX = screenSize.width / 2 - _characterWidth / 2;
    final centerY = screenSize.height / 2 - _characterWidth / 2;

    // Calculate clamped position
    final maxPosition = (_screenWidth - _characterWidth) / 2;
    final clampedPosition = _currentPosition.clamp(-maxPosition, maxPosition);

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
                left: centerX + clampedPosition,
                top: centerY,
                child: Image.asset(
                  'assets/character.png',
                  width: _characterWidth,
                  height: _characterWidth,
                  fit: BoxFit.contain,
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
