import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;
  final VoidCallback onShare;

  const ActionButtonsWidget({
    Key? key,
    required this.onPlayAgain,
    required this.onMainMenu,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Primary action buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildPrimaryButton(
                  label: 'PLAY AGAIN',
                  icon: 'refresh',
                  onPressed: onPlayAgain,
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: _buildPrimaryButton(
                  label: 'MAIN MENU',
                  icon: 'home',
                  onPressed: onMainMenu,
                  isPrimary: false,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Share button
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required String icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 6.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          foregroundColor: isPrimary
              ? Colors.white
              : AppTheme.lightTheme.colorScheme.primary,
          elevation: isPrimary ? 4 : 2,
          shadowColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isPrimary
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: isPrimary
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      width: double.infinity,
      height: 5.h,
      child: OutlinedButton(
        onPressed: onShare,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.lightTheme.colorScheme.secondary,
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          backgroundColor:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Share Your Score',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
