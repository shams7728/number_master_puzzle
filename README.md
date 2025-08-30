# Level System (Reusable)

Decoupled, extensible level progression for Flutter/Dart games. Compose multiple strategies to match different rules.

## Features
- Strategy-based progression (compose rules)
- Observer pattern for UI/state updates
- Simple factory config
- Built-in strategies: grid completion, sublevels, XP

## Import
Use `lib/level_system/app_export.dart` to import all public APIs.

## Quick Start (pseudo)
- Create via factory with desired strategies
- Listen to events for UI/state
- Forward game events like `grid_completed`, `sublevel_completed`, `xp_gained`

## Extend
Implement `LevelProgressionStrategy` and add it to the manager or extend the factory.
