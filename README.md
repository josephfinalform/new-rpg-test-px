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

Open the project in **Godot 4.4+** and run the main scene: `aarpg/Levels/level_1_meadow.tscn`

### Controls

| Action | Key |
|---|---|
| Move | WASD / Arrow Keys |
| Sprint | Hold Shift |
| Attack | Space / X |
| Dash | F / C |

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
- Level & XP progression system (see below)
- **7 playable levels** with portal-based progression (meadow → dungeon → wizard arena → forest → graveyard → ice cavern → shadow keep)
- GameManager autoload: level flow, restart-on-death, victory screen
- Runtime tile painting (grass meadow & dungeon floor/decorations) with arena bounds
- Treasure chest pickups (heal + XP) and torch lights in the dungeon
- Title screen (`aarpg/UI/title_screen.tscn`) — Enter/Space to start
- Pause menu — `ESC` to pause/resume (autoload, persists across levels)
- Elite Goblin enemy (stronger, faster, drops 20 XP)
- HUD shows current level name; later levels scale up enemy XP/damage
- Enemy drops: healing orbs (heart drops) + floating XP popups
- Kill counter in HUD; boss intro banner in the arena
- **New enemies**: Bat (fast, low HP), Skeleton (tanky undead), Orc Brute (heavy, drops XP gems)
- **New enemies v2**: Wolf (fast forest predator), Zombie (slow graveyard tank), Goblin Archer (ranged, kites & shoots arrows)
- **New pickups**: Potion (heals 4 HP, dropped by zombies/elites/orcs, found in levels)
- **New player ability**: Dash (`F`/`C`) — quick directional burst with cooldown
- **New bosses**: Ice Golem (ice balls, charge, ice minions) & Shadow Knight (dash, whirlwind, shadow bats — final boss)
- **Locked boss gates**: portals stay locked until the arena boss is defeated
- **XP gem drops**: blue crystals (5 XP each) dropped by stronger enemies
- **Difficulty scaling**: enemy HP/damage/XP scale up per campaign level

### Level & XP System

- **XP rewards**: Enemies grant XP on death (`xp_reward`, e.g. 8 per slime/goblin).
- **XP curve**: Configurable via `aarpg/config/level_config.tres` (`xp_curve` array, up to `max_level` = 50). Falls back to `5 + level * 3` beyond the curve.
- **Per-level bonuses** (configurable in `level_config.tres`):
  - Max health `+2`, heal `+3` on level up
  - Attack damage `+1`
  - Move speed `+5`, sprint speed `+8`
- **Max level**: Leveling stops at `max_level`; further XP is ignored.
- **UI**: Current level & XP shown in the health bar overlay with level-up feedback.
- **XP gems**: Orc Brutes (35%) and Skeletons (20%) drop blue XP crystals worth 5 XP.
- **Difficulty scaling**: Each campaign level past the first scales enemy HP (`+35%/level`), damage (`+20%/level`) and XP reward (`+25%/level`).

### Planned

| Feature | Status |
|---|---|
| Combat (boomerang, bow, bombs) | Assets ready |
| NPC & Dialogue system | Assets ready |
| Quest system | Assets ready |
| Shop system | Assets ready |
| Equipment system | Assets ready |
| Dungeons & puzzles | Assets ready |
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
│   │       ├── dash_state.gd
│   │       └── hurt_state.gd
│   ├── Enemies/
│   │   ├── enemy.gd
│   │   ├── boss_enemy.gd
│   │   ├── slime.gd
│   │   ├── slime.tscn
│   │   ├── goblin.gd
│   │   ├── goblin.tscn
│   │   ├── goblin_elite.gd
│   │   ├── goblin_elite.tscn
│   │   ├── wolf.gd / wolf.tscn                 # Fast forest predator
│   │   ├── zombie.gd / zombie.tscn             # Slow tanky graveyard undead
│   │   ├── goblin_archer.gd / goblin_archer.tscn # Ranged goblin, shoots arrows
│   │   ├── bat.gd / bat.tscn             # Fast flying enemy
│   │   ├── skeleton.gd / skeleton.tscn   # Tanky undead
│   │   ├── orc_brute.gd / orc_brute.tscn # Heavy melee, XP gem drops
│   │   ├── wizard_boss.gd
│   │   ├── wizard_boss.tscn
│   │   ├── ice_golem.gd / ice_golem.tscn # Boss: ice balls, charge, minions
│   │   ├── shadow_knight.gd / shadow_knight.tscn # Final boss: dash, whirlwind
│   │   ├── boss_projectile.gd
│   │   └── boss_projectile.tscn
│   ├── config/
│   │   ├── level_config.gd
│   │   └── level_config.tres
│   ├── Levels/
│   │   ├── level.gd               # Level flow (spawn, death, victory)
│   │   ├── portal.gd / portal.tscn # Level exit portal
│   │   ├── torch.tscn             # Dungeon torch + light
│   │   ├── level_1_meadow.tscn    # Entry level
│   │   ├── level_2_dungeon.tscn   # Dungeon level
│   │   ├── level_3_boss.tscn      # Wizard boss arena (gate to forest)
│   │   ├── level_4_forest.tscn    # Forest: bats, goblins, orcs
│   │   ├── level_5_graveyard.tscn # Graveyard: skeletons, bats
│   │   ├── level_6_ice_arena.tscn # Ice Golem arena (locked gate)
│   │   └── level_7_shadow_arena.tscn # Shadow Knight arena (final)
│   ├── Maps/
│   │   ├── map_painter.gd         # Runtime tile painting + bounds
│   │   ├── Scenes/                # grass_map.tscn, dungeon_map.tscn
│   │   └── TileSets/
│   ├── Pickups/
│   │   ├── treasure_chest.gd
│   │   ├── treasure_chest.tscn    # Heal + XP pickup
│   │   ├── heart_pickup.gd
│   │   ├── heart_pickup.tscn      # Enemy drop, heals 1 HP
│   │   ├── potion_pickup.gd
│   │   ├── potion_pickup.tscn     # Heals 4 HP, enemy/level drop
│   │   ├── xp_gem.gd
│   │   └── xp_gem.tscn            # Enemy drop, +5 XP
│   ├── Effects/
│   │   ├── floating_text.gd
│   │   └── floating_text.tscn     # "+XP" popup on kill
│   └── UI/
│       ├── health_bar.gd
│       ├── health_bar.tscn
│       ├── title_screen.gd / title_screen.tscn
│       └── pause_menu.gd / pause_menu.tscn
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
- kanka — bug fixes, combat system, knockback, enemy movement, state machine fixes, level & XP system

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for fork / clone / PR workflow.

## Changelog

| Date | Changes |
|---|---|
| 2026-08-05 | New enemies (Wolf, Zombie, Goblin Archer with ranged arrows), potion pickups + enemy drops, empty levels 4/5/1/2 refilled, player Dash (F/C) |
| 2026-08-04 | 7-level campaign: Forest & Graveyard levels, Bat/Skeleton/Orc enemies, Ice Golem & Shadow Knight bosses, XP gem drops, locked boss gates, difficulty scaling |
| 2026-08-03 | Drops: healing orbs + floating XP popups, kill counter, boss intro banner |
| 2026-08-02 | Title screen, pause (ESC), Elite Goblin, HUD seviye adı, level 2/3 zorluk ölçekleme |
| 2026-08-02 | Levels: 3-stage progression (meadow/dungeon/boss), GameManager autoload, portals, runtime-painted maps with bounds, treasure chests & torches |
| 2026-08-01 | Level & XP: curve extended to 50 levels, configurable per-level bonuses, max level cap |
| 2026-07-31 | README: level system reports, project structure & changelog update |
| 2026-07-30 | New bosses: Wizard Boss + goblin, boss projectiles |
| 2026-07-29 | Level config: XP curve now read from `level_config.tres` |
| 2026-07-28 | Fast level system: low XP curve, high enemy XP reward |
| 2026-07-27 | XP/level system with UI display |
| 2026-07-14 | Updated README, added changelog section |
| 2026-07-13 | Combat system, enemy AI, health system & state machine overhaul |

---

*Last updated: 2026-08-05*
