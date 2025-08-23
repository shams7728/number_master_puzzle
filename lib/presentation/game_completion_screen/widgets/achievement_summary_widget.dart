import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class AchievementSummaryWidget extends StatelessWidget {
  final int levelsCompleted;
  final int totalMatches;
  final int hintsUsed;
  final String completionTime;

  const AchievementSummaryWidget({
    Key? key,
    required this.levelsCompleted,
    required this.totalMatches,
    required this.hintsUsed,
    required this.completionTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'military_tech',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Achievement Summary',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Achievement items
          Row(
            children: [
              Expanded(
                child: _buildAchievementItem(
                  'levels_completed',
                  'Levels\nCompleted',
                  levelsCompleted.toString(),
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAchievementItem(
                  'link',
                  'Total\nMatches',
                  totalMatches.toString(),
                  AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: _buildAchievementItem(
                  'lightbulb',
                  'Hints\nUsed',
                  hintsUsed.toString(),
                  AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAchievementItem(
                  'timer',
                  'Completion\nTime',
                  completionTime,
                  Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Achievement badges
          _buildAchievementBadges(),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
      String iconName, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 8.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadges() {
    final badges = <Map<String, dynamic>>[];

    // Perfect completion badge
    if (hintsUsed == 0) {
      badges.add({
        'icon': 'star',
        'label': 'Perfect!',
        'color': Colors.amber,
        'description': 'Completed without hints',
      });
    }

    // Speed completion badge
    final timeMinutes = _parseCompletionTime(completionTime);
    if (timeMinutes <= 10) {
      badges.add({
        'icon': 'flash_on',
        'label': 'Lightning Fast!',
        'color': Colors.orange,
        'description': 'Completed in under 10 minutes',
      });
    }

    // Master badge for high matches
    if (totalMatches >= 50) {
      badges.add({
        'icon': 'emoji_events',
        'label': 'Match Master!',
        'color': Colors.purple,
        'description': 'Made 50+ matches',
      });
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements Unlocked',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: badges.map((badge) => _buildBadge(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(Map<String, dynamic> badge) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (badge['color'] as Color).withValues(alpha: 0.8),
            (badge['color'] as Color),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [
          BoxShadow(
            color: (badge['color'] as Color).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: badge['icon'] as String,
            color: Colors.white,
            size: 4.w,
          ),
          SizedBox(width: 1.w),
          Text(
            badge['label'] as String,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _parseCompletionTime(String timeString) {
    // Parse time string like "5m 30s" or "1h 15m" to minutes
    final parts = timeString.toLowerCase().split(' ');
    int totalMinutes = 0;

    for (final part in parts) {
      if (part.contains('h')) {
        final hours = int.tryParse(part.replaceAll('h', '')) ?? 0;
        totalMinutes += hours * 60;
      } else if (part.contains('m')) {
        final minutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
        totalMinutes += minutes;
      }
    }

    return totalMinutes;
  }
}
