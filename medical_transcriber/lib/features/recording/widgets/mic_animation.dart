import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MicAnimation extends StatefulWidget {
  final int level;
  const MicAnimation({super.key, required this.level});

  @override
  State<MicAnimation> createState() => _MicAnimationState();
}

class _MicAnimationState extends State<MicAnimation> with SingleTickerProviderStateMixin {

  late AnimationController _scaleController;

  late Animation<double> _glowOpacity;

  late Animation<double> _rippleProgress;

  late Animation<double> _wavePhase;

  late Animation<double> _scaleOut;
  late Animation<double> _scaleIn;

  final double size = 150;

  final List<MicLayerState> _activeLayers = [];

  double sizeFromLevel(int level) {
    return 150 + (level * 20);
  }

  static const int _minLevel = 0;
  static const int _maxLevel = 4;

  int level = 0;

  @override
  void initState() {
    level = widget.level;
    _scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350)
    );

    _scaleOut = Tween<double>(
      begin: 1.05,
      end: 0.995,
    ).animate(
      CurvedAnimation(
          parent: _scaleController,
          curve: Interval(0.0, 0.7, curve: Curves.easeOutBack)
      )
    );

    _scaleIn = Tween<double>(
      begin: 0.995,
      end: 1.0
    ).animate(
        CurvedAnimation(
            parent: _scaleController,
            curve: Interval(0.7, 1, curve: Curves.easeOut)
        )
    );

    _glowOpacity = Tween<double>(
      begin: 0.4,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _rippleProgress = CurvedAnimation(
      parent: _scaleController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _wavePhase = Tween<double>(
      begin: 0,
      end: 2 * 3.1415926,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.linear,
      ),
    );

    _updateLayersOnLevelChange();
    _scaleController.forward(from: 0);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MicAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.level != widget.level) {
      level = widget.level.clamp(_minLevel, _maxLevel);

      _updateLayersOnLevelChange();

      _scaleController.forward(from: 0);
    }
  }

  void _updateLayersOnLevelChange() {
    for (final config in micLayerConfigs) {
      final alreadyAdded =
      _activeLayers.any((l) => l.startLevel == config.startLevel);

      if (!alreadyAdded && level >= config.startLevel) {
        _activeLayers.insert(
          0,
          MicLayerState(
            color: config.color,
            startLevel: config.startLevel,
            size: sizeFromLevel(config.startLevel),
          ),
        );
      }
      if (alreadyAdded && level < config.startLevel) {
        _activeLayers.removeWhere((l) => l.startLevel == config.startLevel);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final double baseSize = sizeFromLevel(level);
    return Container(
      alignment: Alignment.center,
      height: 250,
      width: 250,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (_, child) {
          double scale;

          if (_scaleController.value < 0.7) {
            scale = _scaleOut.value;
          } else {
            scale = _scaleIn.value;
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple (unchanged)
              CustomPaint(
                painter: RipplePainter(
                  _rippleProgress.value,
                  Colors.deepPurple,
                ),
              ),

              for (final layer in _activeLayers)
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: layer.size,
                    height: layer.size,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5E2B97),
                    ),
                    child: Container(
                      width: layer.size,
                      height: layer.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: layer.color,
                      ),
                    ),
                  ),
                ),

              // Glow (unchanged)
              Container(
                width: ((_activeLayers).isEmpty? baseSize: _activeLayers.first.size)+30,
                height: ((_activeLayers).isEmpty? baseSize: _activeLayers.first.size)+30,
                // constraints: BoxConstraints(
                //   maxHeight: ((_activeLayers).isEmpty? baseSize: _activeLayers.last.size)+30,
                //   maxWidth: ((_activeLayers).isEmpty? baseSize: _activeLayers.last.size)+30,
                // ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(_glowOpacity.value),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),

              // Core mic (unchanged)
              Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4B1E78),
                  ),
                  child: ClipOval(
                    child: CustomPaint(
                      painter: InnerWavePainter(
                        _wavePhase.value,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Mic icon (unchanged)
              const Icon(
                CupertinoIcons.mic,
                color: Colors.white,
                size: 50,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  RipplePainter( this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withOpacity(1 - progress);

    final radius = size.width / 2 * progress;
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class InnerWavePainter extends CustomPainter {
  final double phase;
  final Color color;

  InnerWavePainter(this.phase, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final midY = size.height / 2;
    final amp = size.height * 0.12;

    for (double x = 0; x <= size.width ; x += 4) {
      final y = midY + amp * Math.sin((x / size.width * 2 + Math.pi) + phase);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant InnerWavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

class MicLayerState {
  final Color color;
  final int startLevel;
  final double size;

  MicLayerState({
    required this.color,
    required this.startLevel,
    required this.size,
  });
}

class MicLayerConfig {
  final Color color;
  final int startLevel;

  MicLayerConfig({
    required this.color,
    required this.startLevel,
  });
}

final List<MicLayerConfig> micLayerConfigs = [
  MicLayerConfig(
    color: const Color(0xFF5E2B97),
    startLevel: 1,
  ),
  MicLayerConfig(
    color: const Color(0xFF6A20B6),
    startLevel: 2,
  ),
  MicLayerConfig(
    color: const Color(0xFF8A5ED6),
    startLevel: 3,
  ),
  MicLayerConfig(
    color: const Color(0xFFB08AE8),
    startLevel: 4,
  ),
];

