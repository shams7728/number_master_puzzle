import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PreviewGridWidget extends StatefulWidget {
  final VoidCallback? onAddRows;

  const PreviewGridWidget({
    Key? key,
    this.onAddRows,
  }) : super(key: key);

  @override
  State<PreviewGridWidget> createState() => _PreviewGridWidgetState();
}

class _PreviewGridWidgetState extends State<PreviewGridWidget> {
  static const int totalRows = 4;
  static const int columns = 9;

  late List<List<int>> grid;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(totalRows, (rowIndex) {
      return List.generate(columns, (colIndex) {
        return Random().nextInt(9) + 1;
      });
    });
  }

  Color _getNumberColor(int number) {
    switch (number % 6) {
      case 0:
        return AppTheme.numberOrangeLight;
      case 1:
        return AppTheme.numberPinkLight;
      case 2:
        return AppTheme.numberCyanLight;
      case 3:
        return AppTheme.successLight;
      case 4:
        return AppTheme.warningLight;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grid Preview Display - Simplified to 4 rows for home screen preview
        Container(
          constraints: BoxConstraints(
            maxWidth: 90.w,
            maxHeight: 35.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(totalRows, (rowIndex) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.3.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(columns, (colIndex) {
                      final number = grid[rowIndex][colIndex];

                      return Container(
                        width: 7.w,
                        height: 4.5.h,
                        margin: EdgeInsets.symmetric(horizontal: 0.3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          child: Center(
                            child: Text(
                              number.toString(),
                              style: AppTheme.numberStyle(
                                isLight: true,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: _getNumberColor(number),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Preview text
        Text(
          'Preview: 7-row grid system in game',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
