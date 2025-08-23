import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/game_screen/game_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/game_completion_screen/game_completion_screen.dart';
import '../presentation/level_completion_screen/level_completion_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String game = '/game-screen';
  static const String home = '/home-screen';
  static const String gameCompletion = '/game-completion-screen';
  static const String levelCompletion = '/level-completion-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    game: (context) => const GameScreen(),
    home: (context) => const HomeScreen(),
    gameCompletion: (context) => const GameCompletionScreen(),
    levelCompletion: (context) => const LevelCompletionScreen(),
    // TODO: Add your other routes here
  };
}
