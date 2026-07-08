# AARPG

A top-down pixel-art action RPG prototype built with **Godot 4.4**.

## Getting Started

1. Open the project in **Godot 4.4+**
2. Run the main scene: `aarpg/playground.tscn`
3. Controls: **WASD** / **Arrow Keys** to move

## Current Features

- Player movement with 4-directional animated sprites (idle/walk)
- State machine architecture for player states (Idle, Walk)
- Pixel-art 480x270 viewport, stretched to 1600x900
- 15+ sound effects (sword, hits, items, doors, levers, etc.)
- Enemy sprites ready (Goblin, Slime, Wizard Boss)

## Planned Features

| Feature | Status |
|---|---|
| Combat (melee, boomerang, bow, bombs) | Assets ready |
| NPC & Dialogue system | Assets ready |
| Quest system | Assets ready |
| Shop system | Assets ready |
| Equipment system | Assets ready |
| Dungeons & puzzles | Assets ready |
| Title screen | Assets ready |
| BGM music | Assets ready |

## Project Structure

```
aarpg/                                # Main game directory
  playground.tscn                     # Main scene (entry point)
  Player/                             # Player character
    player.tscn
    Scripts/
      player.gd                       # Player movement & animation
      player_state_machine.gd         # Finite state machine
      state.gd                        # Base state class
      idle_state.gd                   # Idle state
      walk_state.gd                   # Walk state
assets/                               # Game assets
  sprites/                            # Textures and spritesheets
  audio/                              # Sound effects (15 WAVs)
  archives/                           # Zipped assets for future features
```

## Development

Built with Godot 4.4 using the Forward Plus renderer.

Viewport resolution: **480x270**, window: **1600x900** (stretch).

---

*Last updated: 2026-07-08*
