// Strategy interfaces for different progression rules.

import 'models.dart';

/// Context provided to progression strategies to read/modify progress metadata.
abstract class ProgressContext {
  ProgressSnapshot get snapshot;
  void updateMetadata(String key, Object? value);
}

/// Strategy interface for determining when and how to advance levels.
abstract class LevelProgressionStrategy {
  const LevelProgressionStrategy();

  /// Called when a level starts; strategy can initialize metadata.
  void onLevelStart(ProgressContext context) {}

  /// Called when game-specific events happen, e.g., grid completed, xp gained.
  /// Implementations interpret [event] and may mutate metadata.
  void onGameEvent(ProgressContext context, String event, {Object? data}) {}

  /// Returns true if the current level should advance to the next.
  bool shouldAdvance(ProgressContext context);
}
