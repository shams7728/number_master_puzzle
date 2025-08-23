import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class StarDecorationWidget extends StatelessWidget {
  const StarDecorationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top left stars
            Positioned(
              top: 10.h,
              left: 5.w,
              child: _buildStar(size: 3),
            ),
            Positioned(
              top: 15.h,
              left: 15.w,
              child: _buildStar(size: 2),
            ),
            // Top right stars
            Positioned(
              top: 8.h,
              right: 10.w,
              child: _buildStar(size: 4),
            ),
            Positioned(
              top: 20.h,
              right: 5.w,
              child: _buildStar(size: 2),
            ),
            // Middle left stars
            Positioned(
              top: 40.h,
              left: 8.w,
              child: _buildStar(size: 3),
            ),
            Positioned(
              top: 50.h,
              left: 3.w,
              child: _buildStar(size: 2),
            ),
            // Middle right stars
            Positioned(
              top: 45.h,
              right: 12.w,
              child: _buildStar(size: 3),
            ),
            Positioned(
              top: 55.h,
              right: 8.w,
              child: _buildStar(size: 2),
            ),
            // Bottom stars
            Positioned(
              bottom: 15.h,
              left: 20.w,
              child: _buildStar(size: 2),
            ),
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: _buildStar(size: 3),
            ),
            Positioned(
              bottom: 10.h,
              left: 50.w,
              child: _buildStar(size: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar({required double size}) {
    return CustomIconWidget(
      iconName: 'star',
      color: Colors.white.withValues(alpha: 0.6),
      size: size,
    );
  }
}
