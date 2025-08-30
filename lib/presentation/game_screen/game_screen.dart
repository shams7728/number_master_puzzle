import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/game_grid_widget.dart';
import './widgets/score_display_widget.dart';
import './widgets/star_decoration_widget.dart';

class MatchValidationResult {
  final bool isValid;
  final String errorMessage;

  MatchValidationResult(this.isValid, this.errorMessage);
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game state variables
  List<List<int>> grid = [];
  List<List<bool>> matchedCells = [];
  int currentLevel = 1;
  int currentScore = 0;
  int? selectedRow;
  int? selectedCol;
  int addRowCount = 3;
  int hintCount = 5;
  final Random _random = Random();

  // 7-row grid system variables
  static const int totalRows = 7;
  static const int columns = 9;
  int activeRows = 3;

  // Animation controllers
  late AnimationController _matchAnimationController;
  late AnimationController _levelTransitionController;

  // Timer variables
  late Timer _gameTimer;
  Duration _timeRemaining = const Duration(minutes: 2);
  bool _isTimerRunning = false;

  // Global key for accessing GameGridWidget state
  final GlobalKey<State<GameGridWidget>> _gameGridKey =
      GlobalKey<State<GameGridWidget>>();

  // Global key for accessing ActionButtonsWidget state
  final GlobalKey<State<ActionButtonsWidget>> _actionButtonsKey =
      GlobalKey<State<ActionButtonsWidget>>();

  // Mock game data
  final Map<String, dynamic> gameData = {
    "levels": [
      {
        "level": 1,
        "initialRows": 3,
        "maxRows": 7,
        "scoreMultiplier": 1.0,
        "addRowsAvailable": 4,
        "hintsAvailable": 5
      },
      {
        "level": 2,
        "initialRows": 4,
        "maxRows": 7,
        "scoreMultiplier": 1.5,
        "addRowsAvailable": 3,
        "hintsAvailable": 3
      },
      {
        "level": 3,
        "initialRows": 4,
        "maxRows": 7,
        "scoreMultiplier": 2.0,
        "addRowsAvailable": 2,
        "hintsAvailable": 2
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGameState();
  }

  void _initializeAnimations() {
    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _levelTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLevel = prefs.getInt('current_level') ?? 1;
      final savedScore = prefs.getInt('current_score') ?? 0;
      final savedAddRowCount = prefs.getInt('add_row_count') ?? 4;
      final savedHintCount = prefs.getInt('hint_count') ?? 5;
      final savedActiveRows = prefs.getInt('active_rows') ?? 3;
      final hasActiveGame = prefs.getBool('has_saved_game') ?? false;

      setState(() {
        currentLevel = savedLevel;
        currentScore = savedScore;
        addRowCount = savedAddRowCount;
        hintCount = savedHintCount;
        activeRows = savedActiveRows;
      });

      if (hasActiveGame) {
        // Load saved grid state for resume
        await _loadGridState(prefs);
        setState(() {}); // Trigger rebuild with loaded state
        _startTimer(); // Resume timer
      } else {
        _initializeLevel();
      }
    } catch (e) {
      _initializeLevel();
    }
  }

  void _initializeLevel({bool startTimer = true}) {
    setState(() {
      // Initialize full 7-row grid
      grid = _generateFullGrid();
      matchedCells = List.generate(
        totalRows,
        (index) => List.generate(columns, (index) => false),
      );
      selectedRow = null;
      selectedCol = null;
    });

    // Start the timer only if specified (for new games, not level progression)
    if (startTimer) {
      _startTimer();
    }
  }

  void _startTimer() {
    // Cancel existing timer if running
    if (_isTimerRunning) {
      _gameTimer.cancel();
    }

    // Reset timer to full duration for new level
    _timeRemaining = const Duration(minutes: 2);
    _isTimerRunning = true;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        });
      } else {
        _gameTimer.cancel();
        _isTimerRunning = false;
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Time Up!'),
          content: const Text('You have run out of time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  List<List<int>> _generateFullGrid() {
    final grid = List.generate(totalRows, (_) => List<int>.filled(columns, 0));

    // Create a strategic number pool that ensures cross-row matching
    final List<int> strategicNumbers = [
      1,
      2,
      3,
      4,
      6,
      7,
      8,
      9
    ]; // Avoid 5 for better sum-to-10 pairs
    final Map<int, int> crossRowTargets =
        <int, int>{}; // Track numbers that should appear across rows

    // Fill active rows with strategic content
    for (int row = 0; row < activeRows; row++) {
      final List<int> rowValues = List<int>.filled(columns, 0);
      final Set<int> occupied = <int>{};

      // 1) Create cross-row connections (30% of cells should connect to other rows)
      final int crossRowConnections = (columns * 0.3).round();
      for (int i = 0; i < crossRowConnections && i < columns; i++) {
        final int col = i * 3; // Spread them out
        if (col >= columns) break;

        if (row == 0) {
          // First row: establish target numbers
          final int baseNum =
              strategicNumbers[_random.nextInt(strategicNumbers.length)];
          rowValues[col] = baseNum;
          crossRowTargets[col] = baseNum;
        } else {
          // Other rows: create matches with previous rows
          if (crossRowTargets.containsKey(col)) {
            final int target = crossRowTargets[col]!;
            if (_random.nextBool()) {
              rowValues[col] = target; // Same number
            } else {
              final int comp = target == 5 ? target : (10 - target);
              rowValues[col] = comp.clamp(1, 9); // Sum to 10
            }
          }
        }
        occupied.add(col);
      }

      // 2) Create adjacent pairs within the row
      final int pairDensity =
          currentLevel <= 1 ? 3 : (currentLevel == 2 ? 2 : 2);
      final List<int> availableStarts = <int>[];
      for (int i = 0; i < columns - 1; i++) {
        if (!occupied.contains(i) && !occupied.contains(i + 1)) {
          availableStarts.add(i);
        }
      }
      availableStarts.shuffle(_random);

      int pairsPlaced = 0;
      for (final start in availableStarts) {
        if (pairsPlaced >= pairDensity) break;
        final next = start + 1;

        if (pairsPlaced % 2 == 0) {
          final v = strategicNumbers[_random.nextInt(strategicNumbers.length)];
          rowValues[start] = v;
          rowValues[next] = v;
        } else {
          int x = strategicNumbers[_random.nextInt(strategicNumbers.length)];
          if (x == 5) x = 4;
          rowValues[start] = x;
          rowValues[next] = 10 - x;
        }
        occupied.add(start);
        occupied.add(next);
        pairsPlaced++;
      }

      // 3) Fill remaining slots strategically
      for (int c = 0; c < columns; c++) {
        if (rowValues[c] != 0) continue;

        // 60% chance to use numbers that can match with other rows
        if (_random.nextDouble() < 0.6) {
          final List<int> existingNumbers = <int>[];
          for (int r = 0; r < row; r++) {
            for (int col = 0; col < columns; col++) {
              if (grid[r][col] != 0) existingNumbers.add(grid[r][col]);
            }
          }

          if (existingNumbers.isNotEmpty) {
            final int base =
                existingNumbers[_random.nextInt(existingNumbers.length)];
            if (_random.nextBool()) {
              rowValues[c] = base; // Same number
            } else {
              final int comp = base == 5 ? base : (10 - base);
              rowValues[c] = comp.clamp(1, 9); // Sum to 10
            }
          } else {
            rowValues[c] =
                strategicNumbers[_random.nextInt(strategicNumbers.length)];
          }
        } else {
          rowValues[c] =
              strategicNumbers[_random.nextInt(strategicNumbers.length)];
        }
      }

      grid[row] = rowValues;
    }

    // Ensure at least one valid match exists with better placement
    if (!_hasAnyValidMatch(grid)) {
      _ensureValidMatches(grid, strategicNumbers);
    }

    return grid;
  }

  bool _hasAnyValidMatch(List<List<int>> candidateGrid) {
    for (int i = 0; i < activeRows; i++) {
      for (int j = 0; j < columns; j++) {
        if (matchedCells.isNotEmpty && matchedCells[i][j]) continue;
        for (int k = 0; k < activeRows; k++) {
          for (int l = 0; l < columns; l++) {
            if (i == k && j == l) continue;
            if (matchedCells.isNotEmpty && matchedCells[k][l]) continue;
            final a = candidateGrid[i][j];
            final b = candidateGrid[k][l];
            if (a == 0 || b == 0) continue;
            if ((a == b || a + b == 10) && _isValidConnection(i, j, k, l)) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void _ensureValidMatches(List<List<int>> grid, List<int> strategicNumbers) {
    // Try to place matches in different patterns to avoid clustering
    final patterns = [
      [0, 0, 0, 1], // Adjacent horizontal
      [0, 0, 1, 0], // Adjacent vertical
      [0, 0, 1, 1], // Adjacent diagonal
      [0, 0, 0, 2], // Horizontal with gap
      [0, 0, 2, 0], // Vertical with gap
    ];

    for (final pattern in patterns) {
      final r1 = pattern[0], c1 = pattern[1], r2 = pattern[2], c2 = pattern[3];

      // Ensure positions are within active area
      if (r1 < activeRows && r2 < activeRows && c1 < columns && c2 < columns) {
        final v = strategicNumbers[_random.nextInt(strategicNumbers.length)];
        grid[r1][c1] = v;
        grid[r2][c2] = v;

        // Verify this creates a valid match
        if (_hasAnyValidMatch(grid)) {
          return;
        }
      }
    }

    // Fallback: simple adjacent match
    final v = strategicNumbers[_random.nextInt(strategicNumbers.length)];
    grid[0][0] = v;
    grid[0][1] = v;
  }

  void _onCellTap(int row, int col) {
    // Only allow tapping on active rows
    if (row >= activeRows || matchedCells[row][col]) return;

    HapticFeedback.lightImpact();

    if (selectedRow == null || selectedCol == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else if (selectedRow == row && selectedCol == col) {
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    } else {
      _checkMatch(selectedRow!, selectedCol!, row, col);
    }
  }

  void _checkMatch(int row1, int col1, int row2, int col2) {
    final num1 = grid[row1][col1];
    final num2 = grid[row2][col2];

    // Comprehensive validation
    final matchResult = _validateMatch(row1, col1, row2, col2);

    if (matchResult.isValid) {
      _performMatch(row1, col1, row2, col2);
    } else {
      // Show visual feedback only (no SnackBar)
      _triggerInvalidAnimation(row2, col2);
      setState(() {
        selectedRow = row2;
        selectedCol = col2;
      });
    }
  }

  MatchValidationResult _validateMatch(int row1, int col1, int row2, int col2) {
    // 1. Check if both cells are within active area
    if (row1 >= activeRows || row2 >= activeRows) {
      return MatchValidationResult(
          false, "Cannot match cells outside active area");
    }

    // 2. Check if both cells are unmatched
    if (matchedCells[row1][col1] || matchedCells[row2][col2]) {
      return MatchValidationResult(false, "Cannot match already solved cells");
    }

    // 3. Check if cells are the same
    if (row1 == row2 && col1 == col2) {
      return MatchValidationResult(false, "Cannot match cell with itself");
    }

    final num1 = grid[row1][col1];
    final num2 = grid[row2][col2];

    // 4. Check if numbers are valid (not zero)
    if (num1 <= 0 || num2 <= 0) {
      return MatchValidationResult(false, "Invalid cell values");
    }

    // 5. Check number matching rules
    if (num1 != num2 && num1 + num2 != 10) {
      return MatchValidationResult(false, "Numbers must be equal or sum to 10");
    }

    // 6. Check connection path
    if (!_isValidConnection(row1, col1, row2, col2)) {
      return MatchValidationResult(false, "No clear path between cells");
    }

    return MatchValidationResult(true, "Valid match");
  }

  void _triggerInvalidAnimation(int row, int col) {
    if (_gameGridKey.currentState != null) {
      (_gameGridKey.currentState! as dynamic).triggerInvalidAnimation(row, col);
    }
  }

  void _useHint() {
    if (hintCount <= 0) return;

    // Scan for a guaranteed valid match across active rows
    for (int i = 0; i < activeRows; i++) {
      for (int j = 0; j < columns; j++) {
        if (matchedCells[i][j]) continue;
        for (int k = 0; k < activeRows; k++) {
          for (int l = 0; l < columns; l++) {
            if (matchedCells[k][l]) continue;
            if (i == k && j == l) continue;
            final a = grid[i][j];
            final b = grid[k][l];
            if (a == 0 || b == 0) continue;
            if ((a == b || a + b == 10) && _isValidConnection(i, j, k, l)) {
              HapticFeedback.lightImpact();
              setState(() {
                selectedRow = i;
                selectedCol = j;
                hintCount--;
              });
              _triggerInvalidAnimation(i, j);
              _triggerInvalidAnimation(k, l);
              _saveGameState();
              return;
            }
          }
        }
      }
    }

    // No matches available; trigger hint button error animation
    if (_actionButtonsKey.currentState != null) {
      (_actionButtonsKey.currentState! as dynamic).triggerHintError();
    }
  }

  bool _isValidConnection(int row1, int col1, int row2, int col2) {
    // 1. Adjacent cells (including diagonal) - always valid
    if ((row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1) {
      return true;
    }

    // 2. Line-by-line connections: end of row to beginning of next row
    if (_isLineByLineConnection(row1, col1, row2, col2)) {
      return true;
    }

    // 3. Horizontal line of sight (same row)
    if (row1 == row2) {
      return _isHorizontalPathClear(row1, col1, col2);
    }

    // 4. Vertical line of sight (same column)
    if (col1 == col2) {
      return _isVerticalPathClear(col1, row1, row2);
    }

    // 5. Diagonal line of sight - through matched cells only
    if ((row1 - row2).abs() == (col1 - col2).abs()) {
      return _isDiagonalPathClear(row1, col1, row2, col2);
    }

    return false;
  }

  // Enhanced line-by-line connections (end of row to start of next row)
  bool _isLineByLineConnection(int row1, int col1, int row2, int col2) {
    // Ensure we're dealing with consecutive rows
    if ((row2 - row1).abs() != 1) return false;

    // Determine which is the higher and lower row
    int upperRow = row1 < row2 ? row1 : row2;
    int lowerRow = row1 < row2 ? row2 : row1;
    int upperCol = row1 < row2 ? col1 : col2;
    int lowerCol = row1 < row2 ? col2 : col1;

    // Direct line connection: end of upper row to start of lower row
    if (upperCol == columns - 1 && lowerCol == 0) {
      return true; // Direct connection, no intermediate cells
    }

    // Near-end to near-start connections with intermediate cell checking
    if (upperCol == columns - 1 && lowerCol == 1) {
      // Check if cell [lowerRow, 0] is matched
      return matchedCells[lowerRow][0];
    }

    if (upperCol == columns - 2 && lowerCol == 0) {
      // Check if cell [upperRow, columns-1] is matched
      return matchedCells[upperRow][columns - 1];
    }

    // Extended connections with multiple intermediate cells
    if (upperCol >= columns - 3 && lowerCol <= 2) {
      // Check all cells between the end of upper row and start of lower row
      for (int c = upperCol + 1; c < columns; c++) {
        if (!matchedCells[upperRow][c]) return false;
      }
      for (int c = 0; c < lowerCol; c++) {
        if (!matchedCells[lowerRow][c]) return false;
      }
      return true;
    }

    return false;
  }

  // Improved horizontal path checking
  bool _isHorizontalPathClear(int row, int col1, int col2) {
    int startCol = col1 < col2 ? col1 + 1 : col2 + 1;
    int endCol = col1 < col2 ? col2 : col1;

    for (int c = startCol; c < endCol; c++) {
      if (!matchedCells[row][c]) return false;
    }
    return true;
  }

  // Improved vertical path checking
  bool _isVerticalPathClear(int col, int row1, int row2) {
    int startRow = row1 < row2 ? row1 + 1 : row2 + 1;
    int endRow = row1 < row2 ? row2 : row1;

    for (int r = startRow; r < endRow; r++) {
      if (!matchedCells[r][col]) return false;
    }
    return true;
  }

  bool _isDiagonalPathClear(int fromRow, int fromCol, int toRow, int toCol) {
    final rowDiff = toRow - fromRow;
    final colDiff = toCol - fromCol;

    // Ensure it's actually a diagonal (equal row and column differences)
    if (rowDiff.abs() != colDiff.abs()) return false;

    final rowStep = rowDiff > 0 ? 1 : -1;
    final colStep = colDiff > 0 ? 1 : -1;

    // Check all intermediate cells along the diagonal path
    int currentRow = fromRow + rowStep;
    int currentCol = fromCol + colStep;

    // According to the guide: "All intermediate cells along diagonal must be already matched"
    while (currentRow != toRow || currentCol != toCol) {
      // Bounds checking - ensure we stay within grid bounds
      if (currentRow < 0 ||
          currentRow >= totalRows ||
          currentCol < 0 ||
          currentCol >= columns) {
        return false;
      }

      // If any intermediate cell is still active (not matched), path is blocked
      if (!matchedCells[currentRow][currentCol]) {
        return false;
      }

      currentRow += rowStep;
      currentCol += colStep;
    }

    // All intermediate cells are matched - path is clear
    return true;
  }

  void _performMatch(int row1, int col1, int row2, int col2) {
    HapticFeedback.mediumImpact();

    setState(() {
      matchedCells[row1][col1] = true;
      matchedCells[row2][col2] = true;
      selectedRow = null;
      selectedCol = null;

      // Calculate score with level multiplier
      final List<dynamic> levels = gameData["levels"] as List<dynamic>;
      final levelData = levels.firstWhere(
        (level) => (level as Map<String, dynamic>)["level"] == currentLevel,
      ) as Map<String, dynamic>;

      final multiplier = levelData["scoreMultiplier"] as double;
      currentScore += (10 * multiplier).round();
    });

    // Dull the matched cells
    _matchAnimationController.forward().then((_) {
      _matchAnimationController.reset();
    });

    _saveGameState();
    _checkLevelCompletion();
  }

  // Removed unused _invalidMatchAnimation to satisfy lints.

  void _checkLevelCompletion() {
    // Check if any rows are completely matched and shift them up
    _shiftCompletedRows();

    // Check if all active rows are completed
    bool allActiveRowsMatched = true;
    for (int i = 0; i < activeRows; i++) {
      for (int j = 0; j < columns; j++) {
        if (!matchedCells[i][j]) {
          allActiveRowsMatched = false;
          break;
        }
      }
      if (!allActiveRowsMatched) break;
    }

    if (allActiveRowsMatched) {
      if (currentLevel < 3) {
        _completeLevel();
      } else {
        _completeGame();
      }
    }
  }

  void _shiftCompletedRows() {
    bool hasShifted = false;

    // Check each active row from bottom to top
    for (int row = activeRows - 1; row >= 0; row--) {
      bool isRowComplete = true;

      // Check if this row is completely matched
      for (int col = 0; col < columns; col++) {
        if (!matchedCells[row][col]) {
          isRowComplete = false;
          break;
        }
      }

      if (isRowComplete) {
        // Shift all rows above this one down
        for (int shiftRow = row; shiftRow < activeRows - 1; shiftRow++) {
          // Move grid data
          grid[shiftRow] = List.from(grid[shiftRow + 1]);
          // Move matched status
          matchedCells[shiftRow] = List.from(matchedCells[shiftRow + 1]);
        }

        // Clear the top row that's no longer active
        final topRow = activeRows - 1;
        grid[topRow] = List.generate(columns, (index) => 0);
        matchedCells[topRow] = List.generate(columns, (index) => false);

        // Reduce active rows instead of generating new content
        activeRows--;

        // Clear selection if it's now outside active rows
        if (selectedRow != null && selectedRow! >= activeRows) {
          selectedRow = null;
          selectedCol = null;
        }

        hasShifted = true;

        // Add haptic feedback for row shift
        HapticFeedback.mediumImpact();
      }
    }

    if (hasShifted) {
      // Update UI to reflect the shift
      setState(() {
        // Force rebuild of the grid
      });
      _saveGameState();
    }
  }

  void _completeLevel() {
    // Show brief celebration animation then advance to next level
    _levelTransitionController.forward().then((_) {
      _levelTransitionController.reset();

      // Advance to next level
      setState(() {
        currentLevel++;

        // Update level-specific settings from game data
        final List<dynamic> levels = gameData["levels"] as List<dynamic>;
        if (currentLevel <= levels.length) {
          final levelData = levels.firstWhere(
            (level) => (level as Map<String, dynamic>)["level"] == currentLevel,
          ) as Map<String, dynamic>;

          // Reset for new level
          activeRows = levelData["initialRows"] as int;
          addRowCount = levelData["addRowsAvailable"] as int;
          hintCount = levelData["hintsAvailable"] as int;
        }

        selectedRow = null;
        selectedCol = null;
      });

      // Initialize the new level with fresh timer
      _initializeLevel(startTimer: true);
      _saveGameState();
    });
  }

  void _completeGame() async {
    // Mark game as completed and clear saved game
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('game_completed', true);
      await prefs.setBool('has_saved_game', false);
      await prefs.remove('saved_grid');
      await prefs.remove('saved_matched_cells');
      await prefs.remove('saved_selected_row');
      await prefs.remove('saved_selected_col');
    } catch (e) {
      // Silent fail
    }

    // Show celebration and navigate to game completion screen
    _levelTransitionController.forward().then((_) {
      Navigator.pushNamed(context, '/game-completion-screen');
    });
  }

  void _addRow() {
    if (activeRows >= totalRows || addRowCount <= 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      final int rowIndex = activeRows;
      final List<int> rowValues = List<int>.filled(columns, 0);
      final Set<int> occupied = <int>{};

      // 1) Collect all unmatched numbers from existing active rows
      final Map<int, List<List<int>>> unmatchedPositions =
          <int, List<List<int>>>{};
      for (int r = 0; r < activeRows; r++) {
        for (int c = 0; c < columns; c++) {
          if (!matchedCells[r][c] && grid[r][c] != 0) {
            final int value = grid[r][c];
            unmatchedPositions.putIfAbsent(value, () => <List<int>>[]);
            unmatchedPositions[value]!.add([r, c]);
          }
        }
      }

      // 2) Create strategic matches for unmatched numbers (50% of new row)
      final List<int> unmatchedValues = unmatchedPositions.keys.toList()
        ..shuffle(_random);
      final int strategicMatches = (columns * 0.5).round();
      int matchesPlaced = 0;

      for (final value in unmatchedValues) {
        if (matchesPlaced >= strategicMatches) break;

        final int col = matchesPlaced * 2; // Spread them out
        if (col >= columns) break;

        // 70% chance for exact match, 30% for sum-to-10 match
        if (_random.nextDouble() < 0.7) {
          rowValues[col] = value; // Exact match
        } else {
          final int comp = value == 5 ? value : (10 - value);
          rowValues[col] = comp.clamp(1, 9); // Sum to 10
        }
        occupied.add(col);
        matchesPlaced++;
      }

      // 3) Create adjacent pairs in remaining space
      final int pairDensity = currentLevel <= 1 ? 2 : 1;
      final List<int> availableStarts = <int>[];
      for (int i = 0; i < columns - 1; i++) {
        if (!occupied.contains(i) && !occupied.contains(i + 1)) {
          availableStarts.add(i);
        }
      }
      availableStarts.shuffle(_random);

      int pairsPlaced = 0;
      for (final start in availableStarts) {
        if (pairsPlaced >= pairDensity) break;
        final next = start + 1;

        if (pairsPlaced % 2 == 0) {
          // Use numbers that might match with existing unmatched numbers
          final List<int> strategicNumbers = [1, 2, 3, 4, 6, 7, 8, 9];
          final int v =
              strategicNumbers[_random.nextInt(strategicNumbers.length)];
          rowValues[start] = v;
          rowValues[next] = v;
        } else {
          final List<int> strategicNumbers = [1, 2, 3, 4, 6, 7, 8, 9];
          int x = strategicNumbers[_random.nextInt(strategicNumbers.length)];
          if (x == 5) x = 4;
          rowValues[start] = x;
          rowValues[next] = 10 - x;
        }
        occupied.add(start);
        occupied.add(next);
        pairsPlaced++;
      }

      // 4) Fill remaining slots with strategic numbers
      for (int c = 0; c < columns; c++) {
        if (rowValues[c] != 0) continue;

        // 80% chance to create potential matches with existing unmatched numbers
        if (_random.nextDouble() < 0.8 && unmatchedValues.isNotEmpty) {
          final int target =
              unmatchedValues[_random.nextInt(unmatchedValues.length)];
          if (_random.nextBool()) {
            rowValues[c] = target; // Same number
          } else {
            final int comp = target == 5 ? target : (10 - target);
            rowValues[c] = comp.clamp(1, 9); // Sum to 10
          }
        } else {
          final List<int> strategicNumbers = [1, 2, 3, 4, 6, 7, 8, 9];
          rowValues[c] =
              strategicNumbers[_random.nextInt(strategicNumbers.length)];
        }
      }

      grid[rowIndex] = rowValues;
      matchedCells[rowIndex] = List.generate(columns, (index) => false);

      // Increase active rows after setting up the new row
      activeRows++;

      // Ensure at least one valid match exists across all active rows
      if (!_hasAnyValidMatch(grid)) {
        // Force a guaranteed match by placing identical numbers
        final List<int> strategicNumbers = [1, 2, 3, 4, 6, 7, 8, 9];
        final int v =
            strategicNumbers[_random.nextInt(strategicNumbers.length)];
        grid[rowIndex][0] = v;
        grid[rowIndex][1] = v;
      }

      addRowCount--;
    });

    _saveGameState();
  }

  void _restartGame() async {
    HapticFeedback.lightImpact();

    // Cancel current timer if running
    if (_isTimerRunning) {
      _gameTimer.cancel();
    }

    // Clear saved game data
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_saved_game', false);
      await prefs.setBool('game_completed', false);
      await prefs.remove('saved_grid');
      await prefs.remove('saved_matched_cells');
      await prefs.remove('saved_selected_row');
      await prefs.remove('saved_selected_col');
    } catch (e) {
      // Silent fail
    }

    // Reset to initial state
    setState(() {
      currentLevel = 1;
      currentScore = 0;
      addRowCount = 4;
      hintCount = 5;
      activeRows = 3;
      selectedRow = null;
      selectedCol = null;
      _timeRemaining = const Duration(minutes: 2);
      _isTimerRunning = false;
    });

    _initializeLevel();
    _saveGameState();
  }

  Future<void> _saveGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_level', currentLevel);
      await prefs.setInt('current_score', currentScore);
      await prefs.setInt('add_row_count', addRowCount);
      await prefs.setInt('hint_count', hintCount);
      await prefs.setInt('active_rows', activeRows);

      // Save game completion status
      final bool isGameComplete = currentLevel > 3;
      await prefs.setBool('game_completed', isGameComplete);

      // Save if there's an active game (not completed and not at initial state)
      final bool hasActiveGame = !isGameComplete &&
          (currentLevel > 1 || currentScore > 0 || activeRows > 3);
      await prefs.setBool('has_saved_game', hasActiveGame);

      // Save grid and matched cells state for resume
      if (hasActiveGame) {
        await _saveGridState(prefs);
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _saveGridState(SharedPreferences prefs) async {
    try {
      // Convert grid to string format for storage
      List<String> gridStrings = [];
      List<String> matchedStrings = [];

      for (int i = 0; i < totalRows; i++) {
        gridStrings.add(grid[i].join(','));
        matchedStrings.add(matchedCells[i].map((b) => b ? '1' : '0').join(','));
      }

      await prefs.setStringList('saved_grid', gridStrings);
      await prefs.setStringList('saved_matched_cells', matchedStrings);
      await prefs.setInt('saved_selected_row', selectedRow ?? -1);
      await prefs.setInt('saved_selected_col', selectedCol ?? -1);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadGridState(SharedPreferences prefs) async {
    try {
      final gridStrings = prefs.getStringList('saved_grid');
      final matchedStrings = prefs.getStringList('saved_matched_cells');
      final savedSelectedRow = prefs.getInt('saved_selected_row') ?? -1;
      final savedSelectedCol = prefs.getInt('saved_selected_col') ?? -1;

      if (gridStrings != null && matchedStrings != null) {
        // Restore grid
        grid = List.generate(totalRows,
            (i) => gridStrings[i].split(',').map((s) => int.parse(s)).toList());

        // Restore matched cells
        matchedCells = List.generate(totalRows,
            (i) => matchedStrings[i].split(',').map((s) => s == '1').toList());

        // Restore selection
        selectedRow = savedSelectedRow >= 0 ? savedSelectedRow : null;
        selectedCol = savedSelectedCol >= 0 ? savedSelectedCol : null;
      }
    } catch (e) {
      // If loading fails, initialize normally
      _initializeLevel(startTimer: false);
    }
  }

  void _onBackPressed() {
    _showExitDialog();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Exit Game?',
            style: TextStyle(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your progress will be saved and you can resume later.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exitToHome();
              },
              child: Text(
                'Exit',
                style: TextStyle(color: AppTheme.primaryLight),
              ),
            ),
          ],
        );
      },
    );
  }

  void _exitToHome() async {
    // Cancel timer
    if (_isTimerRunning) {
      _gameTimer.cancel();
    }

    // Save current state
    await _saveGameState();

    // Navigate to home
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home-screen');
    }
  }

  @override
  void dispose() {
    _matchAnimationController.dispose();
    _levelTransitionController.dispose();
    _gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryVariantLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const StarDecorationWidget(),
              Column(
                children: [
                  // Back Button Row
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _onBackPressed,
                          child: Container(
                            width: 12.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  ScoreDisplayWidget(
                    currentScore: currentScore,
                    level: currentLevel,
                  ),
                  Text(
                    'Time Remaining: ${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: grid.isEmpty || matchedCells.isEmpty
                          ? const CircularProgressIndicator()
                          : GameGridWidget(
                              key: _gameGridKey,
                              grid: grid,
                              matchedCells: matchedCells,
                              selectedRow: selectedRow,
                              selectedCol: selectedCol,
                              onCellTap: _onCellTap,
                              activeRows: activeRows,
                              totalRows: totalRows,
                            ),
                    ),
                  ),
                  ActionButtonsWidget(
                    key: _actionButtonsKey,
                    addRowCount: addRowCount,
                    hintCount: hintCount,
                    onAddRow: _addRow,
                    onRestart: _restartGame,
                    onHint: _useHint,
                    canAddRow: activeRows < totalRows && addRowCount > 0,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
