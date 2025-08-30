// Level system core models and simple value types.

/// Represents a unique level identifier.
class LevelId {
  final int value;

  const LevelId(this.value)
      : assert(value >= 0, 'Level value must be non-negative');

  LevelId next() => LevelId(value + 1);

  @override
  String toString() => 'LevelId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LevelId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Snapshot of a level system's current progress.
class ProgressSnapshot {
  final LevelId currentLevelId;
  final Map<String, Object?> metadata;

  const ProgressSnapshot(
      {required this.currentLevelId, this.metadata = const {}});

  ProgressSnapshot copyWith(
      {LevelId? currentLevelId, Map<String, Object?>? metadata}) {
    return ProgressSnapshot(
      currentLevelId: currentLevelId ?? this.currentLevelId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'ProgressSnapshot(level: ${currentLevelId.value}, metadata: $metadata)';
}

/// Configuration for sublevel-based progression.
class SublevelRuleConfig {
  final Map<int, int> levelToSublevelCount;

  const SublevelRuleConfig({required this.levelToSublevelCount});

  int sublevelsForLevel(LevelId levelId) =>
      levelToSublevelCount[levelId.value] ?? 0;
}

/// Configuration for XP-based progression.
class XPRuleConfig {
  final Map<int, int>
      levelToXpThreshold; // required XP to advance from level N to N+1

  const XPRuleConfig({required this.levelToXpThreshold});

  int thresholdFor(LevelId levelId) => levelToXpThreshold[levelId.value] ?? 0;
}
