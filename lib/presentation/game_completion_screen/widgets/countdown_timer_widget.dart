import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onTimeout;

  const CountdownTimerWidget({
    Key? key,
    required this.initialSeconds,
    required this.onTimeout,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late int _remainingSeconds;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _initializeAnimation();
    _startCountdown();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: Duration(seconds: widget.initialSeconds),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.addListener(() {
      if (mounted) {
        setState(() {
          _remainingSeconds =
              (widget.initialSeconds * (1 - _animationController.value))
                  .round();
        });
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isActive) {
        widget.onTimeout();
      }
    });
  }

  void _startCountdown() {
    _animationController.forward();
  }

  void pauseCountdown() {
    if (_isActive) {
      _animationController.stop();
      setState(() {
        _isActive = false;
      });
    }
  }

  void resumeCountdown() {
    if (!_isActive) {
      _animationController.forward();
      setState(() {
        _isActive = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: _remainingSeconds <= 3
              ? Colors.red.withValues(alpha: 0.5)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer icon
          CustomIconWidget(
            iconName: 'timer',
            color: _remainingSeconds <= 3
                ? Colors.red
                : AppTheme.lightTheme.colorScheme.primary,
            size: 4.w,
          ),

          SizedBox(width: 2.w),

          // Progress indicator
          SizedBox(
            width: 12.w,
            height: 1.h,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 3
                        ? Colors.red
                        : AppTheme.lightTheme.colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(0.5.h),
                );
              },
            ),
          ),

          SizedBox(width: 2.w),

          // Countdown text
          Text(
            '${_remainingSeconds}s',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: _remainingSeconds <= 3
                  ? Colors.red
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(width: 2.w),

          // Pause/Resume button
          GestureDetector(
            onTap: _isActive ? pauseCountdown : resumeCountdown,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: CustomIconWidget(
                iconName: _isActive ? 'pause' : 'play_arrow',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 3.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
