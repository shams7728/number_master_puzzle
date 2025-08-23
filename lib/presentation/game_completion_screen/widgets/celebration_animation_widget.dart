import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CelebrationAnimationWidget extends StatefulWidget {
  final bool isNewHighScore;

  const CelebrationAnimationWidget({
    Key? key,
    required this.isNewHighScore,
  }) : super(key: key);

  @override
  State<CelebrationAnimationWidget> createState() =>
      _CelebrationAnimationWidgetState();
}

class _CelebrationAnimationWidgetState extends State<CelebrationAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _starAnimationController;
  late AnimationController _trophyAnimationController;
  late AnimationController _confettiController;
  late Animation<double> _starOpacity;
  late Animation<double> _trophyScale;
  late Animation<double> _confettiOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _trophyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _starOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starAnimationController,
      curve: Curves.easeInOut,
    ));

    _trophyScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _trophyAnimationController,
      curve: Curves.elasticOut,
    ));

    _confettiOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _starAnimationController.repeat(reverse: true);
    _trophyAnimationController.forward();
    if (widget.isNewHighScore) {
      _confettiController.forward();
    }
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    _trophyAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 40.h,
      child: Stack(
        children: [
          // Animated stars
          AnimatedBuilder(
            animation: _starOpacity,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: StarFieldPainter(
                    opacity: _starOpacity.value,
                    isNewHighScore: widget.isNewHighScore,
                  ),
                ),
              );
            },
          ),

          // Trophy animation
          Center(
            child: AnimatedBuilder(
              animation: _trophyScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _trophyScale.value,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.tertiary,
                          AppTheme.lightTheme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'emoji_events',
                        color: Colors.white,
                        size: 8.w,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Confetti animation for new high score
          if (widget.isNewHighScore)
            AnimatedBuilder(
              animation: _confettiOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _confettiOpacity.value,
                  child: Positioned.fill(
                    child: CustomPaint(
                      painter: ConfettiPainter(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final double opacity;
  final bool isNewHighScore;

  StarFieldPainter({
    required this.opacity,
    required this.isNewHighScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill;

    final starPositions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.85, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.9),
    ];

    for (final position in starPositions) {
      _drawStar(canvas, position, 8.0, paint);
    }

    if (isNewHighScore) {
      paint.color = AppTheme.lightTheme.colorScheme.tertiary
          .withValues(alpha: opacity * 0.6);
      for (int i = 0; i < 5; i++) {
        final extraPosition = Offset(
          size.width * (0.1 + i * 0.2),
          size.height * (0.6 + (i % 2) * 0.2),
        );
        _drawStar(canvas, extraPosition, 6.0, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    const double angle = 2 * 3.14159 / points;

    for (int i = 0; i < points * 2; i++) {
      final currentRadius = i % 2 == 0 ? radius : radius * 0.5;
      final x = center.dx + currentRadius * cos(i * angle - 3.14159 / 2);
      final y = center.dy + currentRadius * sin(i * angle - 3.14159 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppTheme.lightTheme.colorScheme.tertiary,
      AppTheme.lightTheme.colorScheme.secondary,
      AppTheme.lightTheme.colorScheme.primary,
      Colors.yellow,
      Colors.pink,
    ];

    for (int i = 0; i < 20; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCenter(
        center: Offset(
          size.width * (0.1 + (i * 0.05) % 0.8),
          size.height * (0.1 + (i * 0.07) % 0.8),
        ),
        width: 8,
        height: 4,
      );

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(i * 0.5);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double cos(double radians) => radians.cos();
double sin(double radians) => radians.sin();

extension on double {
  double cos() {
    return (this * 180 / 3.14159).cos() * 3.14159 / 180;
  }

  double sin() {
    return (this * 180 / 3.14159).sin() * 3.14159 / 180;
  }
}
