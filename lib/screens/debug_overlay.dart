import 'package:flutter/material.dart';
import 'dart:async';
import '../game/flame_game.dart';

/// Debug overlay widget that displays game information
class DebugOverlay extends StatefulWidget {
  final TiltAndPlayGame game;

  const DebugOverlay({
    super.key,
    required this.game,
  });

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  Timer? _updateTimer;
  double _fps = 0.0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update debug info every frame (60 FPS)
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted) {
        _updateFps();
        setState(() {});
      }
    });
  }

  void _updateFps() {
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;
    
    if (elapsed >= 1000) {
      _fps = _frameCount / (elapsed / 1000.0);
      _frameCount = 0;
      _lastFpsUpdate = now;
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: IgnorePointer(
        // Don't interfere with game input
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugRow('FPS', _fps.toStringAsFixed(1)),
              _buildDebugRow(
                'Velocity',
                widget.game.character.velocity.toStringAsFixed(2),
              ),
              _buildDebugRow(
                'Accel X',
                widget.game.currentTiltX.toStringAsFixed(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.lightGreen,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
