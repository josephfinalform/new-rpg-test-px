# AARPG

> A top-down pixel-art action RPG prototype built with **Godot 4.4**.

## Overview

AARPG is a classic top-down action RPG featuring animated player combat, enemy AI, and a modular state machine architecture. Designed as a prototype for expanding into a full dungeon-crawling RPG experience.

## Tech Stack

| Technology | Version |
|---|---|
| Godot Engine | 4.4+ |
| Renderer | Forward Plus |
| Language | GDScript |

## Getting Started

```bash
git clone https://github.com/turut/new-rpg-test-px.git
cd new-rpg-test-px
```

Open the project in **Godot 4.4+** and run the main scene: `aarpg/playground.tscn`

### Controls

| Action | Key |
|---|---|
| Move | WASD / Arrow Keys |
| Sprint | Hold Shift |
| Attack | Space / X |

## Features

### Implemented

- 4-directional animated player sprites (idle / walk / attack)
- Sprint mechanic (180 vs 100 speed)
- Melee combat system with sword swing
- Finite state machine (Idle, Walk, Attack, Hurt)
- Health system with invincibility frames and hit flash
- Slime enemy with chase AI and detection range
- Health bar UI overlay
- Knockback on hit
- Rebindable input mapping via `project.godot`
- Pixel-art viewport (480x270 stretched to 1600x900)
- 15+ sound effects

### Planned

| Feature | Status |
|---|---|
| Combat (boomerang, bow, bombs) | Assets ready |
| More enemy types (Goblin, Wizard Boss) | Assets ready |
| NPC & Dialogue system | Assets ready |
| Quest system | Assets ready |
| Shop system | Assets ready |
| Equipment system | Assets ready |
| Dungeons & puzzles | Assets ready |
| Title screen | Assets ready |
| BGM music | Assets ready |

## Project Structure

```
new-rpg-test-px/
├── project.godot              # Project config (input maps, display)
├── CONTRIBUTING.md
├── aarpg/                     # Main game directory
│   ├── playground.tscn        # Entry point scene
│   ├── Player/
│   │   ├── player.tscn
│   │   └── Scripts/
│   │       ├── player.gd
│   │       ├── player_state_machine.gd
│   │       ├── state.gd
│   │       ├── idle_state.gd
│   │       ├── walk_state.gd
│   │       ├── attack_state.gd
│   │       └── hurt_state.gd
│   ├── Enemies/
│   │   ├── enemy.gd
│   │   ├── slime.gd
│   │   └── slime.tscn
│   └── UI/
│       └── health_bar.gd
├── assets/
│   ├── sprites/               # Textures & spritesheets (14 sprites)
│   ├── audio/                 # Sound effects (15 WAVs)
│   └── archives/              # Zipped assets for future features
└── Tile Maps/
    ├── grass-01.tscn
    ├── grass-011.tscn
    └── Sprites/
```

## Configuration

| Setting | Value |
|---|---|
| Viewport | 480x270 |
| Window | 1600x900 |
| Stretch mode | Viewport |
| Physics gravity | 0 (pure top-down) |

## Contributors

- [turut](https://github.com/turut) — project creator
- kanka — bug fixes, combat system, knockback, enemy movement, state machine fixes

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for fork / clone / PR workflow.

## Changelog

| Date | Changes |
|---|---|
| 2026-07-14 | Updated README, added changelog section |
| 2026-07-13 | Combat system, enemy AI, health system & state machine overhaul |

---

*Last updated: 2026-07-18*
