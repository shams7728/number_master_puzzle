import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievement_summary_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/celebration_animation_widget.dart';
import './widgets/countdown_timer_widget.dart';
import './widgets/score_breakdown_widget.dart';

class GameCompletionScreen extends StatefulWidget {
  const GameCompletionScreen({Key? key}) : super(key: key);

  @override
  State<GameCompletionScreen> createState() => _GameCompletionScreenState();
}

class _GameCompletionScreenState extends State<GameCompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Game completion data
  final Map<String, dynamic> gameCompletionData = {
    "totalScore": 2850,
    "level1Score": 450,
    "level2Score": 675,
    "level3Score": 900,
    "bonusPoints": 825,
    "levelsCompleted": 3,
    "totalMatches": 67,
    "hintsUsed": 2,
    "completionTime": "12m 45s",
    "previousHighScore": 2100,
    "isNewHighScore": true,
    "gameStartTime": "2025-08-22 10:54:32",
    "gameEndTime": "2025-08-22 11:07:17",
  };

  bool _isNewHighScore = false;
  int _currentHighScore = 0;
  late CountdownTimerWidget _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGameData();
    _startAnimations();
    _updateHighScore();
    _clearGameSave();
    _provideCelebrationFeedback();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  void _loadGameData() {
    _isNewHighScore = gameCompletionData["isNewHighScore"] as bool;
    _currentHighScore = gameCompletionData["totalScore"] as int;
  }

  Future<void> _updateHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentScore = gameCompletionData["totalScore"] as int;
      final previousHigh = prefs.getInt('high_score') ?? 0;

      if (currentScore > previousHigh) {
        await prefs.setInt('high_score', currentScore);
        setState(() {
          _isNewHighScore = true;
        });
      }
    } catch (e) {
      debugPrint('Error updating high score: $e');
    }
  }

  Future<void> _clearGameSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_game_state');
      await prefs.remove('current_level');
      await prefs.remove('current_score');
    } catch (e) {
      debugPrint('Error clearing game save: $e');
    }
  }

  void _provideCelebrationFeedback() {
    if (_isNewHighScore) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        HapticFeedback.lightImpact();
      });
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _handlePlayAgain() {
    HapticFeedback.lightImpact();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/game-screen',
      (route) => false,
    );
  }

  void _handleMainMenu() {
    HapticFeedback.lightImpact();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-screen',
      (route) => false,
    );
  }

  void _handleShare() {
    HapticFeedback.lightImpact();
    final shareText = _generateShareText();
    _shareScore(shareText);
  }

  String _generateShareText() {
    final score = gameCompletionData["totalScore"] as int;
    final time = gameCompletionData["completionTime"] as String;
    final matches = gameCompletionData["totalMatches"] as int;
    final hints = gameCompletionData["hintsUsed"] as int;

    String shareText = "🎯 Just completed Number Master! 🎯\n\n";
    shareText += "📊 Final Score: $score points\n";
    shareText += "⏱️ Time: $time\n";
    shareText += "🔗 Total Matches: $matches\n";
    shareText += "💡 Hints Used: $hints\n";

    if (_isNewHighScore) {
      shareText += "🏆 NEW HIGH SCORE! 🏆\n";
    }

    shareText += "\nCan you beat my score? 🚀";

    return shareText;
  }

  void _shareScore(String text) {
    try {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Score copied to clipboard!',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error sharing score: $e');
    }
  }

  void _handleTimeout() {
    _handleMainMenu();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primaryContainer,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),

                        // Countdown timer
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: CountdownTimerWidget(
                              initialSeconds: 10,
                              onTimeout: _handleTimeout,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Celebration animation
                        CelebrationAnimationWidget(
                          isNewHighScore: _isNewHighScore,
                        ),

                        SizedBox(height: 2.h),

                        // Game complete header
                        Text(
                          'GAME COMPLETE!',
                          style: AppTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        if (_isNewHighScore) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.lightTheme.colorScheme.tertiary,
                                  Colors.amber,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(3.w),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme
                                      .lightTheme.colorScheme.tertiary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'emoji_events',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'NEW HIGH SCORE!',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 4.h),

                        // Score breakdown
                        ScoreBreakdownWidget(
                          totalPoints: gameCompletionData["totalScore"] as int,
                          level1Score: gameCompletionData["level1Score"] as int,
                          level2Score: gameCompletionData["level2Score"] as int,
                          level3Score: gameCompletionData["level3Score"] as int,
                          bonusPoints: gameCompletionData["bonusPoints"] as int,
                          isNewHighScore: _isNewHighScore,
                        ),

                        SizedBox(height: 3.h),

                        // Achievement summary
                        AchievementSummaryWidget(
                          levelsCompleted:
                              gameCompletionData["levelsCompleted"] as int,
                          totalMatches:
                              gameCompletionData["totalMatches"] as int,
                          hintsUsed: gameCompletionData["hintsUsed"] as int,
                          completionTime:
                              gameCompletionData["completionTime"] as String,
                        ),

                        SizedBox(height: 4.h),

                        // Action buttons
                        ActionButtonsWidget(
                          onPlayAgain: _handlePlayAgain,
                          onMainMenu: _handleMainMenu,
                          onShare: _handleShare,
                        ),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
