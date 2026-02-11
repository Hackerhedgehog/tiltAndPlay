import 'package:flutter/material.dart';
import '../game/game_level.dart';
import 'game_screen.dart';

class TutorialSlideshowScreen extends StatefulWidget {
  const TutorialSlideshowScreen({super.key});

  @override
  State<TutorialSlideshowScreen> createState() =>
      _TutorialSlideshowScreenState();
}

class _TutorialSlideshowScreenState extends State<TutorialSlideshowScreen> {
  static const _slides = [
    _Slide(
      imagePath: 'assets/images/character.png',
      text: 'Use your phone tilt to control the character',
    ),
    _Slide(
      imagePath: 'assets/images/platform.png',
      text: 'Jump up using the platform',
    ),
    _Slide(
      imagePath: 'assets/images/vent.png',
      text: 'Reach the vent to win',
    ),
    _Slide(
      imagePath: 'assets/images/obstacle.png',
      text: 'Watch out for obstacles',
    ),
  ];

  int _currentIndex = 0;

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const GameScreen(level: GameLevel.tutorial),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentIndex];

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
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        slide.imagePath,
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        slide.text,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ) ??
                            const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final String imagePath;
  final String text;

  const _Slide({required this.imagePath, required this.text});
}
