// Re-export for easy importing.
//
// Quick start:
//
// final manager = LevelSystemFactory.create(
//   startingLevel: 0,
//   strategies: [
//     StrategyConfig(StrategyType.gridCompletion),
//     StrategyConfig(
//       StrategyType.sublevels,
//       params: {
//         'levelToSublevelCount': {0: 3, 1: 4},
//       },
//     ),
//     StrategyConfig(
//       StrategyType.xp,
//       params: {
//         'levelToXpThreshold': {0: 100, 1: 150},
//       },
//     ),
//   ],
// );
//
// manager.addListener((event) {
//   // Update UI, persist progress, etc.
// });
//
// // From your game logic:
// manager.onGameEvent('grid_completed');
// manager.onGameEvent('sublevel_completed');
// manager.onGameEvent('xp_gained', data: 25);

export 'models.dart';
export 'events.dart';
export 'strategy.dart';
export 'strategies.dart';
export 'level_manager.dart';
export 'factory.dart';
