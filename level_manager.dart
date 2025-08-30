// LevelManager orchestrates strategies and emits events to observers.

import 'events.dart';
import 'models.dart';
import 'strategy.dart';

class _ProgressContextImpl implements ProgressContext {
  ProgressSnapshot _snapshot;
  final void Function(ProgressSnapshot) _onSnapshotChanged;

  _ProgressContextImpl(this._snapshot, this._onSnapshotChanged);

  @override
  ProgressSnapshot get snapshot => _snapshot;

  @override
  void updateMetadata(String key, Object? value) {
    final newMetadata = Map<String, Object?>.from(_snapshot.metadata);
    newMetadata[key] = value;
    _snapshot = _snapshot.copyWith(metadata: newMetadata);
    _onSnapshotChanged(_snapshot);
  }
}

class LevelManager {
  final List<LevelProgressionStrategy> _strategies;
  final List<LevelEventListener> _listeners = <LevelEventListener>[];

  late _ProgressContextImpl _context;

  LevelManager({
    required LevelId startingLevel,
    required List<LevelProgressionStrategy> strategies,
    Map<String, Object?> initialMetadata = const {},
  }) : _strategies = strategies {
    _context = _ProgressContextImpl(
      ProgressSnapshot(
          currentLevelId: startingLevel, metadata: initialMetadata),
      _onSnapshotChanged,
    );
    for (final strategy in _strategies) {
      strategy.onLevelStart(_context);
    }
  }

  ProgressSnapshot get snapshot => _context.snapshot;

  void addListener(LevelEventListener listener) => _listeners.add(listener);
  void removeListener(LevelEventListener listener) =>
      _listeners.remove(listener);

  void _emit(LevelEvent event) {
    for (final listener in List<LevelEventListener>.from(_listeners)) {
      listener(event);
    }
  }

  void _onSnapshotChanged(ProgressSnapshot snapshot) {
    _emit(MetadataChangedEvent(snapshot));
  }

  /// Called by the host game to forward its events to the level system.
  void onGameEvent(String event, {Object? data}) {
    for (final strategy in _strategies) {
      strategy.onGameEvent(_context, event, data: data);
    }
    _evaluateAdvance();
  }

  void _evaluateAdvance() {
    final shouldAdvance = _strategies.every((s) => s.shouldAdvance(_context));
    if (shouldAdvance) {
      final from = _context.snapshot.currentLevelId;
      final to = from.next();
      _context = _ProgressContextImpl(
        _context.snapshot.copyWith(currentLevelId: to, metadata: {}),
        _onSnapshotChanged,
      );
      for (final strategy in _strategies) {
        strategy.onLevelStart(_context);
      }
      _emit(LevelAdvancedEvent(fromLevel: from, toLevel: to));
    }
  }
}
