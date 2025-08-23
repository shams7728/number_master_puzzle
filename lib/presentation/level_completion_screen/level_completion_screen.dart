import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/auto_advance_timer_widget.dart';
import './widgets/celebration_animation_widget.dart';
import './widgets/level_progress_indicator_widget.dart';
import './widgets/score_summary_widget.dart';

class LevelCompletionScreen extends StatefulWidget {
  const LevelCompletionScreen({Key? key}) : super(key: key);

  @override
  State<LevelCompletionScreen> createState() => _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends State<LevelCompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // Mock game data - would normally come from game state
  final Map<String, dynamic> gameData = {
    "completedLevel": 2,
    "levelScore": 850,
    "totalScore": 2150,
    "multiplier": 1.5,
    "isGameComplete": false,
  };

  bool _showTimer = true;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundController.forward();

    // Trigger celebration haptics
    _triggerCelebrationHaptics();

    // Show timer after initial animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showTimer = true;
        });
      }
    });
  }

  void _triggerCelebrationHaptics() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final completedLevel = gameData["completedLevel"] as int;

    if (completedLevel >= 3) {
      // Navigate to game completion screen
      Navigator.pushReplacementNamed(context, '/game-completion-screen');
    } else {
      // Continue to next level
      Navigator.pushReplacementNamed(context, '/game-screen');
    }
  }

  void _handleMainMenu() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-screen',
      (route) => false,
    );
  }

  void _handleAutoAdvance() {
    _handleContinue();
  }

  Widget _buildStarryBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
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
              // Animated stars
              ...List.generate(20, (index) {
                final random = (index * 17) % 100;
                final x = (random % 100) / 100.0;
                final y = ((random * 3) % 100) / 100.0;
                final delay = (index % 5) * 0.2;

                return Positioned(
                  left: x * 100.w,
                  top: y * 100.h,
                  child: Opacity(
                    opacity:
                        (_backgroundAnimation.value - delay).clamp(0.0, 1.0) *
                            0.8,
                    child: Container(
                      width: 0.8.w,
                      height: 0.8.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 2,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedLevel = gameData["completedLevel"] as int;
    final levelScore = gameData["levelScore"] as int;
    final totalScore = gameData["totalScore"] as int;
    final multiplier = gameData["multiplier"] as double;

    return Scaffold(
      body: Stack(
        children: [
          // Starry background
          _buildStarryBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 100.h -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 4.h),

                    // Celebration animation
                    CelebrationAnimationWidget(
                      completedLevel: completedLevel,
                    ),

                    SizedBox(height: 4.h),

                    // Level progress indicator
                    LevelProgressIndicatorWidget(
                      completedLevel: completedLevel,
                    ),

                    SizedBox(height: 3.h),

                    // Score summary
                    ScoreSummaryWidget(
                      levelScore: levelScore,
                      multiplier: multiplier,
                      totalScore: totalScore,
                      completedLevel: completedLevel,
                    ),

                    SizedBox(height: 4.h),

                    // Auto-advance timer
                    if (_showTimer)
                      AutoAdvanceTimerWidget(
                        onTimerComplete: _handleAutoAdvance,
                        timerDuration: 5,
                      ),

                    if (_showTimer) SizedBox(height: 3.h),

                    // Action buttons
                    ActionButtonsWidget(
                      completedLevel: completedLevel,
                      onContinue: _handleContinue,
                      onMainMenu: _handleMainMenu,
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
