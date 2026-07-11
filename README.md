# AARPG

A top-down pixel-art action RPG prototype built with **Godot 4.4**.

## Getting Started

1. Open the project in **Godot 4.4+**
2. Run the main scene: `aarpg/playground.tscn`
3. Controls: **WASD** / **Arrow Keys** to move, **Shift** to sprint

## Current Features

- Player movement with 4-directional animated sprites (idle/walk)
- Sprint mechanic (hold **Shift** to run faster — 180 vs 100 speed)
- Finite state machine architecture for player states (Idle, Walk)
- Input action mapping via `project.godot` (rebindable controls)
- Pixel-art 480x270 viewport, stretched to 1600x900
- 15+ sound effects (sword, hits, items, doors, levers, etc.)
- Enemy sprites ready (Goblin, Slime, Wizard Boss)
- Tile map scenes for grass environments

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
new-rpg-test-px/                      # Repository root
  project.godot                       # Godot project config (input maps, display)
  aarpg/                              # Main game directory
    playground.tscn                   # Main scene (entry point)
    Player/                           # Player character
      player.tscn
      Scripts/
        player.gd                     # Player movement, sprint & animation
        player_state_machine.gd       # Finite state machine
        state.gd                      # Base state class
        idle_state.gd                 # Idle state
        walk_state.gd                 # Walk state
  assets/                             # Game assets
    sprites/                          # Textures and spritesheets (14 sprites)
    audio/                            # Sound effects (15 WAVs)
    archives/                         # Zipped assets for future features
  Tile Maps/                          # Tile map scenes and sprites
    grass-01.tscn
    grass-011.tscn
    Sprites/
  CONTRIBUTING.md                     # Contribution guidelines
```

## Contributors

- [turut](https://github.com/turut) — project creator
- kanka — katkıda bulundu :)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for fork/clone/PR workflow.

## Development

Built with Godot 4.4 using the Forward Plus renderer.

Viewport resolution: **480x270**, window: **1600x900** (stretch mode: viewport).

Physics gravity set to **0** (pure top-down, no gravity).

---

*Last updated: 2026-07-11*
