import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RulesPanelWidget extends StatelessWidget {
  const RulesPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      constraints: BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                '📝',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 2.w),
              Text(
                'How to Play',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          // Rules list
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRuleItem('Match numbers that are equal or sum to 10'),
              SizedBox(height: 1.h),
              _buildRuleItem('Connect horizontally, vertically, or diagonally'),
              SizedBox(height: 1.h),
              _buildRuleItem('Path must be clear through matched cells'),
              SizedBox(height: 1.h),
              _buildRuleItem('Complete all active rows to advance level'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            color: const Color(0xFF4FACFE),
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: const Color(0xFF555555),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
