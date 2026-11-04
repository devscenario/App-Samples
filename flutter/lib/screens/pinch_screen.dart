import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

// A standard two-finger pinch, as in a photo viewer: fingers apart zoom in,
// together zoom out. Same limits as the Compose sample `PinchScreen.kt`.
const double _kMinScale = 0.6;
const double _kMaxScale = 2.2;

class PinchScreen extends StatefulWidget {
  const PinchScreen({super.key});
  @override
  State<PinchScreen> createState() => _PinchScreenState();
}

class _PinchScreenState extends State<PinchScreen> {
  double _scale = 1.0;
  double _startScale = 1.0;
  // Internal direction key ('in' / 'out' / 'none'); mapped to a localized
  // label for display. Kept as a key so the gesture logic stays language-free.
  String _direction = 'none';
  int _events = 0;

  String _directionLabel(SampleStrings s) {
    switch (_direction) {
      case 'in':
        return s.pinchDirIn;
      case 'out':
        return s.pinchDirOut;
      default:
        return s.pinchDirNone;
    }
  }
  void _onScaleStart(ScaleStartDetails d) => _startScale = _scale;

  void _onScaleUpdate(ScaleUpdateDetails d) {
    // One finger only pans; a pinch needs two.
    if (d.pointerCount < 2) return;
    setState(() {
      final next = (_startScale * d.scale).clamp(_kMinScale, _kMaxScale);
      if (next > _scale) {
        _direction = 'in';
      } else if (next < _scale) {
        _direction = 'out';
      }
      _scale = next;
      _events++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(strings.pinchTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(strings.pinchIntro),
          const SizedBox(height: 12),
          Text(
            strings.pinchStatus(_scale, _directionLabel(strings), _events),
            key: const ValueKey(TestTags.pinchStatus),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              key: const ValueKey(TestTags.pinchPlayground),
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: Container(
                color: Colors.indigo.withValues(alpha: 0.12),
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: _scale,
                  child: Container(
                    key: const ValueKey(TestTags.pinchTarget),
                    width: 160,
                    height: 160,
                    color: Colors.indigo,
                    alignment: Alignment.center,
                    child: Text(strings.pinchMe,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
