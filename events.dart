// Events emitted by the level system. Consumers can observe these to update UI or save progress.

import 'models.dart';

abstract class LevelEvent {
  const LevelEvent();
}

class LevelAdvancedEvent extends LevelEvent {
  final LevelId fromLevel;
  final LevelId toLevel;

  const LevelAdvancedEvent({required this.fromLevel, required this.toLevel});
}

class SublevelProgressEvent extends LevelEvent {
  final LevelId levelId;
  final int completedSublevels;
  final int totalSublevels;

  const SublevelProgressEvent({
    required this.levelId,
    required this.completedSublevels,
    required this.totalSublevels,
  });
}

class XPChangedEvent extends LevelEvent {
  final LevelId levelId;
  final int currentXp;
  final int thresholdXp;

  const XPChangedEvent({
    required this.levelId,
    required this.currentXp,
    required this.thresholdXp,
  });
}

class MetadataChangedEvent extends LevelEvent {
  final ProgressSnapshot snapshot;

  const MetadataChangedEvent(this.snapshot);
}

typedef LevelEventListener = void Function(LevelEvent event);
