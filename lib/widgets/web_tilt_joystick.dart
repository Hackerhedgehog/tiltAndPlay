import 'package:flutter/material.dart';

/// Horizontal drag control that reports [-1, 1] for fake accelerometer input on web.
class WebTiltJoystick extends StatefulWidget {
  const WebTiltJoystick({
    super.key,
    required this.onTiltChanged,
  });

  final ValueChanged<double> onTiltChanged;

  @override
  State<WebTiltJoystick> createState() => _WebTiltJoystickState();
}

class _WebTiltJoystickState extends State<WebTiltJoystick> {
  static const double _trackWidth = 200;
  static const double _trackHeight = 48;
  static const double _thumbSize = 40;

  double _normalized = 0.0;
  int _activePointers = 0;

  void _updateFromLocalDx(double dx, double width) {
    final center = width / 2;
    final halfRange = (width - _thumbSize) / 2;
    if (halfRange <= 0) return;
    final clampedX = dx.clamp(center - halfRange, center + halfRange);
    final n = (clampedX - center) / halfRange;
    setState(() => _normalized = n.clamp(-1.0, 1.0));
    widget.onTiltChanged(_normalized);
  }

  void _reset() {
    setState(() => _normalized = 0.0);
    widget.onTiltChanged(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        _activePointers++;
        _updateFromLocalDx(e.localPosition.dx, _trackWidth);
      },
      onPointerMove: (e) {
        if (e.down) {
          _updateFromLocalDx(e.localPosition.dx, _trackWidth);
        }
      },
      onPointerUp: (_) {
        _activePointers = (_activePointers - 1).clamp(0, 100);
        if (_activePointers == 0) _reset();
      },
      onPointerCancel: (_) {
        _activePointers = (_activePointers - 1).clamp(0, 100);
        if (_activePointers == 0) _reset();
      },
      child: SizedBox(
        width: _trackWidth,
        height: _trackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: _trackWidth,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            Positioned(
              left: (_trackWidth - _thumbSize) / 2 +
                  _normalized * ((_trackWidth - _thumbSize) / 2),
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
