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

  // Mock game data
  final Map<String, dynamic> gameData = {
    "levels": [
      {
        "level": 1,
        "initialRows": 3,
        "maxRows": 7,
        "scoreMultiplier": 1.0,
        "addRowsAvailable": 3,
        "hintsAvailable": 5
      },
      {
        "level": 2,
        "initialRows": 4,
        "maxRows": 7,
        "scoreMultiplier": 1.5,
        "addRowsAvailable": 2,
        "hintsAvailable": 3
      },
      {
        "level": 3,
        "initialRows": 4,
        "maxRows": 7,
        "scoreMultiplier": 2.0,
        "addRowsAvailable": 1,
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
      final savedAddRowCount = prefs.getInt('add_row_count') ?? 3;
      final savedHintCount = prefs.getInt('hint_count') ?? 5;
      final savedActiveRows = prefs.getInt('active_rows') ?? 3;

      setState(() {
        currentLevel = savedLevel;
        currentScore = savedScore;
        addRowCount = savedAddRowCount;
        hintCount = savedHintCount;
        activeRows = savedActiveRows;
      });

      _initializeLevel();
    } catch (e) {
      _initializeLevel();
    }
  }

  void _initializeLevel() {
    final List<dynamic> levels = gameData["levels"] as List<dynamic>;
    Map<String, dynamic> levelData;

    try {
      levelData = levels.firstWhere(
        (level) => (level as Map<String, dynamic>)["level"] == currentLevel,
      ) as Map<String, dynamic>;
    } catch (e) {
      levelData = levels[0] as Map<String, dynamic>;
    }

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

    // Start the timer
    _startTimer();
  }

  void _startTimer() {
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
    return List.generate(totalRows, (rowIndex) {
      // Only generate numbers for active rows, inactive rows get 0 (will be displayed as empty)
      if (rowIndex < activeRows) {
        return List.generate(columns, (colIndex) {
          return _random.nextInt(9) + 1;
        });
      } else {
        return List.generate(columns, (colIndex) => 0);
      }
    });
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

    bool isValidMatch = false;

    // Check if numbers are identical or sum to 10
    if (num1 == num2 || num1 + num2 == 10) {
      // Check if cells are adjacent or have clear line of sight
      if (_isValidConnection(row1, col1, row2, col2)) {
        isValidMatch = true;
      }
    }

    if (isValidMatch) {
      _performMatch(row1, col1, row2, col2);
    } else {
      // Trigger invalid animation on the second cell
      _triggerInvalidAnimation(row2, col2);
      setState(() {
        selectedRow = row2;
        selectedCol = col2;
      });
    }
  }

  void _triggerInvalidAnimation(int row, int col) {
    if (_gameGridKey.currentState != null) {
      (_gameGridKey.currentState! as dynamic).triggerInvalidAnimation(row, col);
    }
  }

  bool _isValidConnection(int row1, int col1, int row2, int col2) {
    // Adjacent cells (including diagonal)
    if ((row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1) {
      return true;
    }

    // End of row to start of next row
    if (row2 == row1 + 1 && col1 == 8 && col2 == 0) {
      return true;
    }

    // Check horizontal line of sight
    if (row1 == row2) {
      int startCol = col1 < col2 ? col1 + 1 : col2 + 1;
      int endCol = col1 < col2 ? col2 : col1;

      for (int c = startCol; c < endCol; c++) {
        if (!matchedCells[row1][c]) return false;
      }
      return true;
    }

    // Check vertical line of sight
    if (col1 == col2) {
      int startRow = row1 < row2 ? row1 + 1 : row2 + 1;
      int endRow = row1 < row2 ? row2 : row1;

      for (int r = startRow; r < endRow; r++) {
        if (!matchedCells[r][col1]) return false;
      }
      return true;
    }

    // Check diagonal line of sight
    if ((row1 - row2).abs() == (col1 - col2).abs()) {
      return _isDiagonalPathClear(row1, col1, row2, col2);
    }

    return false;
  }

  bool _isDiagonalPathClear(int fromRow, int fromCol, int toRow, int toCol) {
    final rowDiff = toRow - fromRow;
    final colDiff = toCol - fromCol;

    final rowStep = rowDiff > 0 ? 1 : -1;
    final colStep = colDiff > 0 ? 1 : -1;

    // Check all intermediate cells along the diagonal path
    int currentRow = fromRow + rowStep;
    int currentCol = fromCol + colStep;

    while (currentRow != toRow && currentCol != toCol) {
      // Check if the current cell is not matched (active cell blocks the path)
      if (!matchedCells[currentRow][currentCol]) {
        return false; // Path blocked by active cell
      }
      currentRow += rowStep;
      currentCol += colStep;
    }

    return true; // Path is clear
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

  void _invalidMatchAnimation(int row, int col) {
    // Implement shake or flash animation for invalid match
    // This can be done using an AnimationController
  }

  void _checkLevelCompletion() {
    bool allMatched = true;
    for (int i = 0; i < matchedCells.length; i++) {
      for (int j = 0; j < matchedCells[i].length; j++) {
        if (!matchedCells[i][j]) {
          allMatched = false;
          break;
        }
      }
      if (!allMatched) break;
    }

    if (allMatched) {
      if (currentLevel < 3) {
        _completeLevel();
      } else {
        _completeGame();
      }
    }
  }

  void _completeLevel() {
    _levelTransitionController.forward().then((_) {
      Navigator.pushNamed(context, '/level-completion-screen');
    });
  }

  void _completeGame() {
    Navigator.pushNamed(context, '/game-completion-screen');
  }

  void _addRow() {
    if (activeRows >= totalRows || addRowCount <= 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      activeRows++;
      // Generate new numbers for the newly activated row
      for (int col = 0; col < columns; col++) {
        grid[activeRows - 1][col] = _random.nextInt(9) + 1;
      }
      addRowCount--;
    });

    _saveGameState();
  }

  void _useHint() {
    if (hintCount <= 0) return;

    HapticFeedback.lightImpact();

    // Find a valid match in active rows and highlight it
    for (int i = 0; i < activeRows; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (matchedCells[i][j]) continue;

        for (int k = 0; k < activeRows; k++) {
          for (int l = 0; l < grid[k].length; l++) {
            if (matchedCells[k][l] || (i == k && j == l)) continue;

            final num1 = grid[i][j];
            final num2 = grid[k][l];

            if ((num1 == num2 || num1 + num2 == 10) &&
                _isValidConnection(i, j, k, l)) {
              setState(() {
                selectedRow = i;
                selectedCol = j;
                hintCount--;
              });
              _saveGameState();
              return;
            }
          }
        }
      }
    }
  }

  void _restartGame() {
    HapticFeedback.lightImpact();

    // Cancel current timer if running
    if (_isTimerRunning) {
      _gameTimer.cancel();
    }

    // Reset to initial state
    setState(() {
      currentLevel = 1;
      currentScore = 0;
      addRowCount = 3;
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
    } catch (e) {
      // Silent fail
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
                    addRowCount: addRowCount,
                    onAddRow: _addRow,
                    onRestart: _restartGame,
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
