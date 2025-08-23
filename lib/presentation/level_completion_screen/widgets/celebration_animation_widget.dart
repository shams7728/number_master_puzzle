import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CelebrationAnimationWidget extends StatefulWidget {
  final int completedLevel;

  const CelebrationAnimationWidget({
    Key? key,
    required this.completedLevel,
  }) : super(key: key);

  @override
  State<CelebrationAnimationWidget> createState() =>
      _CelebrationAnimationWidgetState();
}

class _CelebrationAnimationWidgetState extends State<CelebrationAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _scaleController;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _scaleController.forward();
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sparkleAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background sparkles
              ...List.generate(8, (index) {
                final angle = (index * 45) * (3.14159 / 180);
                final radius = 15.w * _sparkleAnimation.value;
                final x = radius * (index % 2 == 0 ? 1 : -1) * 0.7;
                final y = radius * (index < 4 ? -1 : 1) * 0.7;

                return Transform.translate(
                  offset: Offset(x, y),
                  child: Opacity(
                    opacity: _sparkleAnimation.value,
                    child: Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Central trophy/star icon
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'emoji_events',
                    color: Colors.white,
                    size: 10.w,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
