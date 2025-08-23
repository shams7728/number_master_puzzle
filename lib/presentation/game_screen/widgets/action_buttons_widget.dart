import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final int addRowCount;
  final VoidCallback onAddRow;
  final VoidCallback onRestart;
  final bool canAddRow;

  const ActionButtonsWidget({
    Key? key,
    required this.addRowCount,
    required this.onAddRow,
    required this.onRestart,
    required this.canAddRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: 'add',
            count: addRowCount,
            onTap: canAddRow ? onAddRow : null,
            isEnabled: canAddRow,
          ),
          _buildActionButton(
            icon: 'refresh',
            count: 0,
            onTap: onRestart,
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
  }) {
    return Stack(
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppTheme.primaryLight
                : AppTheme.matchedGrayLight.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.3),
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
