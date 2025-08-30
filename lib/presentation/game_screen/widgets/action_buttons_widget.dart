import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatefulWidget {
  final int addRowCount;
  final int hintCount;
  final VoidCallback onAddRow;
  final VoidCallback onRestart;
  final VoidCallback onHint;
  final bool canAddRow;

  const ActionButtonsWidget({
    super.key,
    required this.addRowCount,
    required this.hintCount,
    required this.onAddRow,
    required this.onRestart,
    required this.onHint,
    required this.canAddRow,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget>
    with TickerProviderStateMixin {
  late AnimationController _hintShakeController;
  late Animation<double> _hintShakeAnimation;
  bool _isHintButtonRed = false;

  @override
  void initState() {
    super.initState();
    _hintShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hintShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hintShakeController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _hintShakeController.dispose();
    super.dispose();
  }

  void triggerHintError() {
    setState(() {
      _isHintButtonRed = true;
    });
    _hintShakeController.forward().then((_) {
      _hintShakeController.reset();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isHintButtonRed = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedBuilder(
            animation: _hintShakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _hintShakeAnimation.value *
                      10 *
                      (1 - _hintShakeAnimation.value) *
                      ((_hintShakeController.value * 4) % 2 == 0 ? 1 : -1),
                  0,
                ),
                child: _buildActionButton(
                  icon: 'lightbulb',
                  count: widget.hintCount,
                  onTap: widget.hintCount > 0 ? widget.onHint : null,
                  isEnabled: widget.hintCount > 0,
                  isError: _isHintButtonRed,
                ),
              );
            },
          ),
          _buildActionButton(
            icon: 'add',
            count: widget.addRowCount,
            onTap: widget.canAddRow ? widget.onAddRow : null,
            isEnabled: widget.canAddRow,
          ),
          _buildActionButton(
            icon: 'refresh',
            count: 0,
            onTap: widget.onRestart,
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required int count,
    required VoidCallback? onTap,
    required bool isEnabled,
    bool isError = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: isError
                ? AppTheme.errorLight
                : isEnabled
                    ? AppTheme.primaryLight
                    : AppTheme.matchedGrayLight.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: isError
                          ? AppTheme.errorLight.withValues(alpha: 0.3)
                          : AppTheme.primaryLight.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: isEnabled ? Colors.white : AppTheme.matchedGrayLight,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              constraints: BoxConstraints(
                minWidth: 5.w,
                minHeight: 5.w,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
