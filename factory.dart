// Factory for constructing level systems from simple configurations.

import 'level_manager.dart';
import 'models.dart';
import 'strategies.dart';
import 'strategy.dart';

enum StrategyType { gridCompletion, sublevels, xp }

class StrategyConfig {
  final StrategyType type;
  final Map<String, Object?> params;

  const StrategyConfig(this.type, {this.params = const {}});
}

class LevelSystemFactory {
  static LevelManager create({
    required int startingLevel,
    required List<StrategyConfig> strategies,
  }) {
    final built = <LevelProgressionStrategy>[];
    for (final conf in strategies) {
      switch (conf.type) {
        case StrategyType.gridCompletion:
          built.add(GridCompletionStrategy());
          break;
        case StrategyType.sublevels:
          final mapping =
              (conf.params['levelToSublevelCount'] as Map<int, int>?);
          if (mapping == null) {
            built.add(const SublevelsStrategy(
                SublevelRuleConfig(levelToSublevelCount: {})));
          } else {
            built.add(SublevelsStrategy(
                SublevelRuleConfig(levelToSublevelCount: mapping)));
          }
          break;
        case StrategyType.xp:
          final mapping = (conf.params['levelToXpThreshold'] as Map<int, int>?);
          if (mapping == null) {
            built.add(const XPStrategy(XPRuleConfig(levelToXpThreshold: {})));
          } else {
            built.add(XPStrategy(XPRuleConfig(levelToXpThreshold: mapping)));
          }
          break;
      }
    }

    return LevelManager(
      startingLevel: LevelId(startingLevel),
      strategies: built,
    );
  }
}
