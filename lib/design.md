# Design Document

## Overview

The Generic Level System is a flexible, strategy-based progression system designed to work with any game type. It uses the Strategy pattern to compose different progression rules, the Observer pattern for event-driven updates, and a Factory pattern for easy configuration. The system is completely decoupled from specific game mechanics and communicates through generic events.

The design builds upon proven patterns from the existing level system implementation, enhancing it for broader reusability and easier integration across different game types.

## Architecture

### Core Components

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Game Logic    │───▶│  LevelManager    │───▶│   UI/Observers  │
│                 │    │                  │    │                 │
│ - Grid Events   │    │ - Orchestrates   │    │ - Progress UI   │
│ - XP Events     │    │ - Evaluates      │    │ - Notifications │
│ - Custom Events │    │ - Emits Events   │    │ - State Saving  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Strategies     │
                    │                  │
                    │ - Grid Complete  │
                    │ - Sublevels      │
                    │ - XP Threshold   │
                    │ - Custom Rules   │
                    └──────────────────┘
```

### Strategy Pattern Implementation

Each progression rule is implemented as a separate strategy that can be composed with others:

- **GridCompletionStrategy**: Advances when a grid/board is completed
- **SublevelsStrategy**: Requires completing N sublevels per level
- **XPStrategy**: Accumulates experience points with configurable thresholds
- **Custom Strategies**: Extensible interface for game-specific rules

### Event-Driven Communication

The system uses events to maintain loose coupling:
- Game → LevelManager: Generic game events (strings + optional data)
- LevelManager → Observers: Typed level events (advancement, progress, metadata changes)

## Components and Interfaces

### Core Models

```dart
// Strongly-typed level identifier
class LevelId {
  final int value;
  LevelId next() => LevelId(value + 1);
}

// Immutable progress snapshot
class ProgressSnapshot {
  final LevelId currentLevelId;
  final Map<String, Object?> metadata;
  
  ProgressSnapshot copyWith({...}) => ...;
}
```

### Strategy Interface

```dart
abstract class LevelProgressionStrategy {
  // Initialize strategy when level starts
  void onLevelStart(ProgressContext context);
  
  // Handle game events and update metadata
  void onGameEvent(ProgressContext context, String event, {Object? data});
  
  // Determine if level should advance
  bool shouldAdvance(ProgressContext context);
}

abstract class ProgressContext {
  ProgressSnapshot get snapshot;
  void updateMetadata(String key, Object? value);
}
```

### Level Manager

The central orchestrator that:
- Manages multiple strategies
- Forwards game events to all strategies
- Evaluates advancement conditions
- Emits progress events
- Maintains current state snapshot

```dart
class LevelManager {
  LevelManager({
    required LevelId startingLevel,
    required List<LevelProgressionStrategy> strategies,
    Map<String, Object?> initialMetadata = const {},
  });
  
  // Event handling
  void onGameEvent(String event, {Object? data});
  void addListener(LevelEventListener listener);
  
  // State access
  ProgressSnapshot get snapshot;
}
```

### Factory Configuration

Simplified setup through configuration objects:

```dart
enum StrategyType { gridCompletion, sublevels, xp }

class StrategyConfig {
  final StrategyType type;
  final Map<String, Object?> params;
}

class LevelSystemFactory {
  static LevelManager create({
    required int startingLevel,
    required List<StrategyConfig> strategies,
  });
}
```

## Data Models

### Configuration Models

```dart
// Sublevel progression configuration
class SublevelRuleConfig {
  final Map<int, int> levelToSublevelCount;
  int sublevelsForLevel(LevelId levelId);
}

// XP progression configuration  
class XPRuleConfig {
  final Map<int, int> levelToXpThreshold;
  int thresholdFor(LevelId levelId);
}
```

### Event Models

```dart
abstract class LevelEvent {}

class LevelAdvancedEvent extends LevelEvent {
  final LevelId fromLevel;
  final LevelId toLevel;
}

class MetadataChangedEvent extends LevelEvent {
  final ProgressSnapshot snapshot;
}

class SublevelProgressEvent extends LevelEvent {
  final LevelId levelId;
  final int completedSublevels;
  final int totalSublevels;
}

class XPChangedEvent extends LevelEvent {
  final LevelId levelId;
  final int currentXp;
  final int thresholdXp;
}
```

## Error Handling

### Validation Strategy

- **Level ID Validation**: Assert non-negative values at construction
- **Strategy Validation**: Ensure at least one strategy is provided
- **Event Safety**: Handle null/invalid event data gracefully
- **Metadata Safety**: Use safe casting with fallback defaults

### Error Recovery

```dart
// Safe metadata access with defaults
final xp = (context.snapshot.metadata['currentXp'] as int?) ?? 0;

// Graceful event handling
void onGameEvent(ProgressContext context, String event, {Object? data}) {
  if (event == 'xp_gained') {
    final delta = (data as int?) ?? 0; // Safe with fallback
    // ... handle event
  }
}
```

### Boundary Conditions

- Empty strategy lists: Require at least one strategy
- Invalid configurations: Provide sensible defaults
- Missing metadata: Initialize with safe defaults
- Event listener failures: Isolate listener exceptions

## Testing Strategy

### Unit Testing Approach

1. **Strategy Testing**: Test each strategy in isolation
   - Mock ProgressContext for controlled testing
   - Verify metadata updates and advancement conditions
   - Test edge cases (zero values, missing data)

2. **Integration Testing**: Test strategy combinations
   - Multiple strategies working together
   - Event forwarding and coordination
   - State transitions and consistency

3. **Event Testing**: Verify event emission and handling
   - Correct event types and data
   - Listener notification order
   - Exception isolation

### Test Structure

```dart
// Strategy unit tests
class GridCompletionStrategyTest {
  void testInitialization();
  void testGridCompletedEvent();
  void testAdvancementCondition();
  void testInvalidEvents();
}

// Integration tests
class LevelManagerIntegrationTest {
  void testMultipleStrategies();
  void testEventForwarding();
  void testStateConsistency();
  void testListenerNotification();
}

// Factory tests
class LevelSystemFactoryTest {
  void testBasicConfiguration();
  void testComplexConfiguration();
  void testInvalidConfiguration();
}
```

### Mock Strategy for Testing

```dart
class MockStrategy extends LevelProgressionStrategy {
  bool _shouldAdvance = false;
  List<String> receivedEvents = [];
  
  void setShouldAdvance(bool value) => _shouldAdvance = value;
  
  @override
  bool shouldAdvance(ProgressContext context) => _shouldAdvance;
  
  @override
  void onGameEvent(ProgressContext context, String event, {Object? data}) {
    receivedEvents.add(event);
  }
}
```

## Integration Patterns

### Game Integration

```dart
// 1. Setup level system
final levelSystem = LevelSystemFactory.create(
  startingLevel: 1,
  strategies: [
    StrategyConfig(StrategyType.gridCompletion),
    StrategyConfig(StrategyType.xp, params: {
      'levelToXpThreshold': {1: 100, 2: 200, 3: 300}
    }),
  ],
);

// 2. Listen for progress updates
levelSystem.addListener((event) {
  if (event is LevelAdvancedEvent) {
    showLevelUpAnimation(event.toLevel);
    saveProgress(levelSystem.snapshot);
  }
});

// 3. Forward game events
void onGridCompleted() {
  levelSystem.onGameEvent('grid_completed');
}

void onXPGained(int amount) {
  levelSystem.onGameEvent('xp_gained', data: amount);
}
```

### State Persistence

```dart
// Save progress
Map<String, dynamic> saveState() => {
  'currentLevel': levelSystem.snapshot.currentLevelId.value,
  'metadata': levelSystem.snapshot.metadata,
};

// Restore progress
void restoreState(Map<String, dynamic> saved) {
  final levelSystem = LevelSystemFactory.create(
    startingLevel: saved['currentLevel'] ?? 1,
    strategies: [...],
  );
  // Restore metadata through initial game events if needed
}
```

### Custom Strategy Example

```dart
class TimeBasedStrategy extends LevelProgressionStrategy {
  final Duration requiredTime;
  static const String _startTimeKey = 'levelStartTime';
  
  @override
  void onLevelStart(ProgressContext context) {
    context.updateMetadata(_startTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  @override
  bool shouldAdvance(ProgressContext context) {
    final startTime = context.snapshot.metadata[_startTimeKey] as int?;
    if (startTime == null) return false;
    
    final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
    return elapsed >= requiredTime.inMilliseconds;
  }
}
```