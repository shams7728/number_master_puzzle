import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/game_logo_widget.dart';
import './widgets/score_display_widget.dart';
import './widgets/starry_background_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScore = 0;
  int _highScore = 0;
  bool _hasSavedGame = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _currentScore = prefs.getInt('current_score') ?? 0;
        _highScore = prefs.getInt('high_score') ?? 0;
        _hasSavedGame = prefs.getBool('has_saved_game') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentScore = 0;
        _highScore = 0;
        _hasSavedGame = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _startNewGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_score', 0);
      await prefs.setBool('has_saved_game', false);
      await prefs.setInt('current_level', 1);
      await prefs.setInt('current_rows', 3);

      if (mounted) {
        Navigator.pushNamed(context, '/game-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start new game. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _resumeGame() async {
    if (mounted) {
      Navigator.pushNamed(context, '/game-screen');
    }
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings-screen');
  }

  Future<void> _refreshData() async {
    await _loadGameData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarryBackgroundWidget(
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 100.h - MediaQuery.of(context).padding.top,
                      ),
                      child: Column(
                        children: [
                          // Settings Button
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 2.h,
                                right: 4.w,
                              ),
                              child: GestureDetector(
                                onTap: _navigateToSettings,
                                child: Container(
                                  width: 12.w,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .lightTheme.colorScheme.surface
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: CustomIconWidget(
                                      iconName: 'settings',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 6.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Game Logo
                          const GameLogoWidget(),

                          SizedBox(height: 3.h),

                          // Score Display
                          ScoreDisplayWidget(
                            currentScore: _currentScore,
                            highScore: _highScore,
                          ),

                          SizedBox(height: 6.h),

                          // Action Buttons
                          ActionButtonsWidget(
                            hasSavedGame: _hasSavedGame,
                            onNewGame: _startNewGame,
                            onResumeGame: _hasSavedGame ? _resumeGame : null,
                          ),

                          SizedBox(height: 4.h),

                          // Footer text
                          Text(
                            'Match identical numbers or pairs that sum to 10',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary
                                  .withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
