import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/settings_button_widget.dart';
import './widgets/settings_info_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_slider_widget.dart';
import './widgets/settings_toggle_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Sound settings
  bool _soundEffectsEnabled = true;
  bool _backgroundMusicEnabled = true;

  // Display settings
  double _animationSpeed = 1.0;

  // Gameplay settings
  String _difficultyLevel = 'Normal';
  bool _hintsEnabled = true;
  String _autoSaveFrequency = 'After each level';

  // Statistics data
  final Map<String, dynamic> _statisticsData = {
    'totalGamesPlayed': 47,
    'averageCompletionTime': '4m 32s',
    'favoriteLevel': 'Level 2',
    'totalHintsUsed': 23,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
        _backgroundMusicEnabled =
            prefs.getBool('background_music_enabled') ?? true;
        _animationSpeed = prefs.getDouble('animation_speed') ?? 1.0;
        _difficultyLevel = prefs.getString('difficulty_level') ?? 'Normal';
        _hintsEnabled = prefs.getBool('hints_enabled') ?? true;
        _autoSaveFrequency =
            prefs.getString('auto_save_frequency') ?? 'After each level';
      });
    } catch (e) {
      _showErrorToast('Failed to load settings');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_effects_enabled', _soundEffectsEnabled);
      await prefs.setBool('background_music_enabled', _backgroundMusicEnabled);
      await prefs.setDouble('animation_speed', _animationSpeed);
      await prefs.setString('difficulty_level', _difficultyLevel);
      await prefs.setBool('hints_enabled', _hintsEnabled);
      await prefs.setString('auto_save_frequency', _autoSaveFrequency);

      _showSuccessToast('Settings saved');
    } catch (e) {
      _showErrorToast('Failed to save settings');
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: Colors.white,
    );
  }

  void _clearHighScores() {
    ConfirmationDialogWidget.show(
      context: context,
      title: 'Clear High Scores',
      message:
          'Are you sure you want to clear all high scores? This action cannot be undone.',
      confirmText: 'Clear',
      cancelText: 'Cancel',
      isDestructive: true,
      onConfirm: () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('high_score');
          await prefs.remove('best_times');
          _showSuccessToast('High scores cleared');
        } catch (e) {
          _showErrorToast('Failed to clear high scores');
        }
      },
    );
  }

  void _resetAllProgress() {
    ConfirmationDialogWidget.show(
      context: context,
      title: 'Reset All Progress',
      message:
          'Are you sure you want to reset all game progress? This will delete all saved games, statistics, and achievements. This action cannot be undone.',
      confirmText: 'Reset',
      cancelText: 'Cancel',
      isDestructive: true,
      onConfirm: () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          _loadSettings(); // Reload default settings
          _showSuccessToast('All progress reset');
        } catch (e) {
          _showErrorToast('Failed to reset progress');
        }
      },
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Difficulty',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Easy', 'Normal', 'Hard'].map((difficulty) {
              return RadioListTile<String>(
                title: Text(difficulty),
                value: difficulty,
                groupValue: _difficultyLevel,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _difficultyLevel = value;
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  }
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAutoSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Auto-Save Frequency',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['After each move', 'After each level', 'Manual only']
                .map((frequency) {
              return RadioListTile<String>(
                title: Text(frequency),
                value: frequency,
                groupValue: _autoSaveFrequency,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _autoSaveFrequency = value;
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  }
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatAnimationSpeed(double value) {
    if (value == 0.5) return 'Slow';
    if (value == 1.0) return 'Normal';
    if (value == 1.5) return 'Fast';
    if (value == 2.0) return 'Very Fast';
    return '${value.toStringAsFixed(1)}x';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Sound Section
              SettingsSectionWidget(
                title: 'Sound',
                children: [
                  SettingsToggleWidget(
                    title: 'Sound Effects',
                    subtitle: 'Play sounds for game actions',
                    value: _soundEffectsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEffectsEnabled = value;
                      });
                      _saveSettings();
                    },
                    isFirst: true,
                  ),
                  SettingsToggleWidget(
                    title: 'Background Music',
                    subtitle: 'Play ambient music during gameplay',
                    value: _backgroundMusicEnabled,
                    onChanged: (value) {
                      setState(() {
                        _backgroundMusicEnabled = value;
                      });
                      _saveSettings();
                    },
                    isLast: true,
                  ),
                ],
              ),

              // Display Section
              SettingsSectionWidget(
                title: 'Display',
                children: [
                  SettingsSliderWidget(
                    title: 'Animation Speed',
                    subtitle: 'Adjust the speed of game animations',
                    value: _animationSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 3,
                    onChanged: (value) {
                      setState(() {
                        _animationSpeed = value;
                      });
                      _saveSettings();
                    },
                    labelFormatter: _formatAnimationSpeed,
                    isFirst: true,
                    isLast: true,
                  ),
                ],
              ),

              // Gameplay Section
              SettingsSectionWidget(
                title: 'Gameplay',
                children: [
                  SettingsButtonWidget(
                    title: 'Difficulty Level',
                    subtitle: _difficultyLevel,
                    onTap: _showDifficultyDialog,
                    isFirst: true,
                  ),
                  SettingsToggleWidget(
                    title: 'Hints System',
                    subtitle: 'Enable hint suggestions during gameplay',
                    value: _hintsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _hintsEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  SettingsButtonWidget(
                    title: 'Auto-Save Frequency',
                    subtitle: _autoSaveFrequency,
                    onTap: _showAutoSaveDialog,
                    isLast: true,
                  ),
                ],
              ),

              // Statistics Section
              SettingsSectionWidget(
                title: 'Statistics',
                children: [
                  SettingsInfoWidget(
                    title: 'Total Games Played',
                    value: _statisticsData['totalGamesPlayed'].toString(),
                    isFirst: true,
                  ),
                  SettingsInfoWidget(
                    title: 'Average Completion Time',
                    value: _statisticsData['averageCompletionTime'],
                  ),
                  SettingsInfoWidget(
                    title: 'Favorite Level',
                    value: _statisticsData['favoriteLevel'],
                  ),
                  SettingsInfoWidget(
                    title: 'Total Hints Used',
                    value: _statisticsData['totalHintsUsed'].toString(),
                    isLast: true,
                  ),
                ],
              ),

              // About Section
              SettingsSectionWidget(
                title: 'About',
                children: [
                  SettingsInfoWidget(
                    title: 'App Version',
                    value: '1.0.0',
                    isFirst: true,
                  ),
                  SettingsButtonWidget(
                    title: 'Developer',
                    subtitle: 'Number Master Team',
                    onTap: () {
                      _showSuccessToast('Thanks for playing Number Master!');
                    },
                  ),
                  SettingsButtonWidget(
                    title: 'Privacy Policy',
                    onTap: () {
                      _showSuccessToast('Opening privacy policy...');
                    },
                  ),
                  SettingsButtonWidget(
                    title: 'Terms of Service',
                    onTap: () {
                      _showSuccessToast('Opening terms of service...');
                    },
                    isLast: true,
                  ),
                ],
              ),

              // Reset Section
              SettingsSectionWidget(
                title: 'Reset',
                children: [
                  SettingsButtonWidget(
                    title: 'Clear High Scores',
                    subtitle: 'Remove all saved high scores',
                    onTap: _clearHighScores,
                    isDestructive: true,
                    isFirst: true,
                  ),
                  SettingsButtonWidget(
                    title: 'Reset All Progress',
                    subtitle: 'Delete all game data and start fresh',
                    onTap: _resetAllProgress,
                    isDestructive: true,
                    isLast: true,
                  ),
                ],
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
