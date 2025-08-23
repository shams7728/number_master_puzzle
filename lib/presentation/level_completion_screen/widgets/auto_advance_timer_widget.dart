import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AutoAdvanceTimerWidget extends StatefulWidget {
  final VoidCallback onTimerComplete;
  final int timerDuration;

  const AutoAdvanceTimerWidget({
    Key? key,
    required this.onTimerComplete,
    this.timerDuration = 5,
  }) : super(key: key);

  @override
  State<AutoAdvanceTimerWidget> createState() => _AutoAdvanceTimerWidgetState();
}

class _AutoAdvanceTimerWidgetState extends State<AutoAdvanceTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  int _remainingSeconds = 5;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timerDuration;

    _timerController = AnimationController(
      duration: Duration(seconds: widget.timerDuration),
      vsync: this,
    );

    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));

    _timerController.addListener(() {
      final newSeconds = (_timerAnimation.value * widget.timerDuration).ceil();
      if (newSeconds != _remainingSeconds && mounted) {
        setState(() {
          _remainingSeconds = newSeconds;
        });
      }
    });

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimerComplete();
      }
    });

    _startTimer();
  }

  void _startTimer() {
    _timerController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _timerAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer icon
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),

              SizedBox(width: 3.w),

              // Timer text
              Expanded(
                child: Text(
                  'Auto-advancing in $_remainingSeconds seconds',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(width: 3.w),

              // Circular progress indicator
              SizedBox(
                width: 6.w,
                height: 6.w,
                child: CircularProgressIndicator(
                  value: 1.0 - _timerAnimation.value,
                  strokeWidth: 3,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.secondary,
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
