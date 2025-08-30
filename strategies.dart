// Built-in progression strategies: grid, sublevels, XP.

import 'strategy.dart';
import 'models.dart';

/// Grid completion strategy: advance when a grid is completed.
class GridCompletionStrategy extends LevelProgressionStrategy {
  static const String _completedKey = 'gridCompleted';

  @override
  void onLevelStart(ProgressContext context) {
    context.updateMetadata(_completedKey, false);
  }

  @override
  void onGameEvent(ProgressContext context, String event, {Object? data}) {
    if (event == 'grid_completed') {
      context.updateMetadata(_completedKey, true);
    }
  }

  @override
  bool shouldAdvance(ProgressContext context) {
    final value = context.snapshot.metadata[_completedKey];
    return value == true;
  }
}

/// Sublevels strategy: each level has N sublevels; advance after all done.
class SublevelsStrategy extends LevelProgressionStrategy {
  static const String _completedCountKey = 'completedSublevels';
  final SublevelRuleConfig config;

  const SublevelsStrategy(this.config);

  @override
  void onLevelStart(ProgressContext context) {
    context.updateMetadata(_completedCountKey, 0);
  }

  @override
  void onGameEvent(ProgressContext context, String event, {Object? data}) {
    if (event == 'sublevel_completed') {
      final current =
          (context.snapshot.metadata[_completedCountKey] as int?) ?? 0;
      context.updateMetadata(_completedCountKey, current + 1);
    }
  }

  @override
  bool shouldAdvance(ProgressContext context) {
    final levelId = context.snapshot.currentLevelId;
    final total = config.sublevelsForLevel(levelId);
    final done = (context.snapshot.metadata[_completedCountKey] as int?) ?? 0;
    return total > 0 && done >= total;
  }
}

/// XP strategy: accumulate XP; advance when threshold met for current level.
class XPStrategy extends LevelProgressionStrategy {
  static const String _xpKey = 'currentXp';
  final XPRuleConfig config;

  const XPStrategy(this.config);

  @override
  void onLevelStart(ProgressContext context) {
    context.updateMetadata(_xpKey, 0);
  }

  @override
  void onGameEvent(ProgressContext context, String event, {Object? data}) {
    if (event == 'xp_gained') {
      final delta = (data as int?) ?? 0;
      final current = (context.snapshot.metadata[_xpKey] as int?) ?? 0;
      context.updateMetadata(_xpKey, current + delta);
    }
  }

  @override
  bool shouldAdvance(ProgressContext context) {
    final levelId = context.snapshot.currentLevelId;
    final threshold = config.thresholdFor(levelId);
    final current = (context.snapshot.metadata[_xpKey] as int?) ?? 0;
    return threshold > 0 && current >= threshold;
  }
}
