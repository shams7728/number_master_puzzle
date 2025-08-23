import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GameGridWidget extends StatefulWidget {
  final List<List<int>> grid;
  final List<List<bool>> matchedCells;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int, int) onCellTap;
  final int activeRows;
  final int totalRows;

  const GameGridWidget({
    Key? key,
    required this.grid,
    required this.matchedCells,
    this.selectedRow,
    this.selectedCol,
    required this.onCellTap,
    required this.activeRows,
    required this.totalRows,
  }) : super(key: key);

  @override
  State<GameGridWidget> createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends State<GameGridWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _invalidRow;
  int? _invalidCol;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void triggerInvalidAnimation(int row, int col) {
    setState(() {
      _invalidRow = row;
      _invalidCol = col;
    });
    _animationController.forward().then((_) {
      _animationController.reset();
      setState(() {
        _invalidRow = null;
        _invalidCol = null;
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
        return AppTheme
            .errorLight; // Changed from Colors.white to a visible color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 90.w,
        maxHeight: 65.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(widget.totalRows, (rowIndex) {
            final isActiveRow = rowIndex < widget.activeRows;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 0.3.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(9, (colIndex) {
                  final isSelected = widget.selectedRow == rowIndex &&
                      widget.selectedCol == colIndex;
                  final isMatched =
                      isActiveRow && widget.matchedCells[rowIndex][colIndex];
                  final number = widget.grid[rowIndex][colIndex];
                  final isInvalid =
                      _invalidRow == rowIndex && _invalidCol == colIndex;

                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final shakeOffset = isInvalid
                          ? Tween<double>(begin: 0, end: 10)
                                  .animate(CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.easeInOut,
                                  ))
                                  .value *
                              (_animationController.value < 0.5 ? 1 : -1)
                          : 0.0;

                      return Transform.translate(
                        offset: Offset(shakeOffset, 0),
                        child: Container(
                          width: 7.w,
                          height: 5.h,
                          margin: EdgeInsets.symmetric(horizontal: 0.3.w),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? AppTheme.matchedGrayLight
                                    .withValues(alpha: 0.3)
                                : isActiveRow
                                    ? AppTheme.lightTheme.colorScheme.surface
                                    : Colors.grey[200]!,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.secondaryLight
                                  : isActiveRow
                                      ? Colors.transparent
                                      : Colors.grey[300]!,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.secondaryLight
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (isMatched || !isActiveRow)
                                  ? null
                                  : () => widget.onCellTap(rowIndex, colIndex),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                decoration: isMatched
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      )
                                    : null,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    number > 0
                                        ? Text(
                                            number.toString(),
                                            style: AppTheme.numberStyle(
                                              isLight: true,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: isMatched
                                                  ? AppTheme.warningLight
                                                      .withValues(alpha: 0.6)
                                                  : isActiveRow
                                                      ? _getNumberColor(number)
                                                      : Colors.grey[400]!,
                                            ),
                                          )
                                        : Container(),
                                    if (isMatched)
                                      Container(
                                        width: 4.w,
                                        height: 1,
                                        color: AppTheme.warningLight
                                            .withValues(alpha: 0.6),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
