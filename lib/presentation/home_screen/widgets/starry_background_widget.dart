import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StarryBackgroundWidget extends StatelessWidget {
  final Widget child;

  const StarryBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Stars decoration
          ...List.generate(20, (index) {
            return Positioned(
              left: (index * 17.3) % 100.w,
              top: (index * 23.7) % 100.h,
              child: Container(
                width: 1.w,
                height: 1.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          // Larger stars
          ...List.generate(8, (index) {
            return Positioned(
              left: (index * 31.2) % 100.w,
              top: (index * 41.5) % 100.h,
              child: CustomIconWidget(
                iconName: 'star',
                color: Colors.white.withValues(alpha: 0.6),
                size: 2.w,
              ),
            );
          }),
          // Main content
          child,
        ],
      ),
    );
  }
}
