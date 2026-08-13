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
| Cycle Season | Q |

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
- **10 playable levels** with portal-based progression (meadow → dungeon → wizard arena → forest → graveyard → ice cavern → ember canyon → mystic grove → EXP grind arena → shadow keep)
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
- **XP gem magnet**: crystals fly to the player when nearby (radius scaling with size per XP value)
- **+XP popup**: collecting a gem shows a floating "+N XP" text
- **Damage numbers**: floating hit text on enemy and player hits
- **Level-up effect**: "LEVEL UP" banner + particle burst + jingle + stat summary (HP/ATK/SPD)
- **Player growth**: character scales up slightly with each level
- **HUD XP text**: `12 / 15` progress label + smoothly animated XP bar, pulsing level label
- **Difficulty scaling**: enemy HP/damage/XP scale up per campaign level
- **Weapon system**: `Weapon` resources (Iron, Fire, Frost, Royal swords) picked up in the world, affecting damage / attack speed / status effects; equipped weapon persists through the campaign and is shown on the HUD
- **Weapon status effects**: Fire Sword burns enemies over time, Frost Sword chills & slows them
- **Weapon pickups**: glowing sword drops with name labels & bob animation (Fire → Ember Canyon, Frost → Ice Cavern, Royal → Shadow Keep)
- **New enemy**: Fire Imp (fast, skittish ember goblin that drops XP gems)
- **New level**: Ember Canyon — lava-tinted dungeon arena between the Ice Cavern and the Shadow Keep, packed with fire imps, skeletons and orcs
- **Season system**: cycle Spring → Summer → Autumn → Winter (`Q`); outdoor maps get seasonal palettes and weather (falling leaves in autumn, snow in winter), shown on the HUD
- **New enemy**: Crystal Wisp — floating mystic crystal that drifts through the grove, dropping XP gems on death (60%)
- **New level**: Mystic Grove — calm, mostly-empty outdoor clearing between the Ember Canyon and the Shadow Keep, packed with XP gems, chests and potions
- **Armor system**: `Armor` resources (Cyan Cuirass, Cyan Plate, Royal Cyan Guard) picked up in the world, granting flat + percentage damage reduction, a speed multiplier and a cyan halo around the player; equipped armor persists and is shown on the HUD
- **Gear up pickups**: permanent stat boosts (ATK/HP/SPD/Dash cooldown) scattered through the levels, shown on the HUD with a fading label
- **New weapon**: Cyan Stormblade — electric cyan blade with a new SHOCK status effect that stuns enemies on hit
- **EXP rework**: level cap raised to 100, steeper late-game XP curve, and milestone bonuses every 10 levels (bonus ATK/HP/SPD + "MILESTONE!" banner)
- **New main menu**: animated title screen with cyan particle sparks, floating/swaying sword, pulsing glow title, clickable "BAŞLA" button and menu BGM
- **EXP rework v2**: parametrized 4-phase XP curve (fast early, grindy late), 11 rank titles (ROOKIE → GODLIKE) shown in the HUD & level-up banner, and milestone bonuses that scale up every 10 levels
- **Prestige system**: after max level (100), earned XP fills a prestige bar; every 1000 XP grants a Prestige ★ that permanently boosts ATK/HP/SPD, adds a star suffix to the rank title, and triggers a PRESTIGE effect — the HUD XP bar switches to prestige progress
- **Armor v2**: armor now also grants an XP multiplier, dash cooldown multiplier and move speed multiplier, plus 2 new legendary armors (Mystic Aegis → Ember Canyon, Stormlord Plate → Mystic Grove)
- **Gear up v2**: 4 new permanent upgrades — CRIT (chance to deal 2×, shown with a CRIT! popup), Lifesteal (heal a % of damage dealt), XP (all XP boosted), and Armor (flat damage reduction)
- **EXP refactor**: level / XP / prestige logic extracted from the player into a dedicated `XpProgression` class (`aarpg/Player/Scripts/xp_progression.gd`) — the player keeps read-only `level` / `xp` / `prestige` properties and applies stat bonuses via signals
- **Level settings (level setleme)**: `level_config.tres` now ships configurable `starting_level` / `starting_xp` plus a "Parchment" group (`parchment_xp`, `parchment_xp_multiplier`, `tome_levels`)
- **XP Scroll & Level Tome pickups**: new parchment/book pickups (`scroll_pickup.tscn`) — the XP Scroll grants configurable XP (respects XP multipliers), the Level Tome grants +1 level instantly (converts to prestige past max level)
- **Gear up v3**: 6 new permanent upgrades — Thorns (reflect damage to attackers), Magnet (wider XP gem vacuum), Regen (HP per second), Fury (faster attacks), Knockback (enemies pushed further), CRIT DMG (bigger crits) — spread across levels 1–9
- **EXP Grind Arena (boss grind map)**: new post-Mystic-Grove level (`level_10_exp_grind.tscn`) with 40+ respawning enemies and a respawning Shadow Knight boss — grind mode in `level.gd` doubles all enemy/boss XP (`grind_xp_multiplier`), auto-respawns killed enemies (`enemy_respawn_delay`) and the boss (`boss_respawn_delay`), plus a boss-respawn countdown banner

### Level & XP System

- **XP rewards**: Enemies grant XP on death (`xp_reward`, e.g. 8 per slime/goblin).
- **XP curve**: Parametrized in `aarpg/config/level_config.gd` / `.tres` as 4 phases, generated via `build_xp_curve()`:
  - Level 1–20: `+3 XP` per level (8 → 65)
  - Level 21–50: `+5 XP` per level (70 → 215)
  - Level 51–80: `+12 XP` per level (227 → 575)
  - Level 81–100: `+35 XP` per level (610 → 1275)
  - Editing `curve_base_xp` / `curve_phases` regenerates the curve; the stored `xp_curve` array is used at runtime with a `5 + level * 3` fallback.
- **Ranks (persona titles)**: 11 rank tiers shown in the HUD and level-up banner, colored per rank (ROOKIE → ADVENTURER → VETERAN → KNIGHT → WARRIOR → CHAMPION → HERO → LEGEND → MYTHIC → DIVINE → GODLIKE).
- **Per-level bonuses** (configurable in `level_config.tres`):
  - Max health `+2`, heal `+3` on level up
  - Attack damage `+1`
  - Move speed `+5`, sprint speed `+8`
- **Scaling milestone bonuses**: every 10 levels the milestone reward grows with `milestone_bonus_growth` (`+0.5` per tier) — e.g. ATK/HP/SPD at level 20 are `1.5×`, at level 100 `5.5×` the base bonus.
- **Max level**: Leveling stops at `max_level` (100); further XP is ignored.
- **Start settings**: `starting_level` / `starting_xp` in `level_config.tres` let you set the player's starting progression.
- **Parchment (XP scrolls)**: `parchment_xp` (default 15) is the XP granted by an XP Scroll pickup; `parchment_xp_multiplier` decides whether it benefits from the player's XP multiplier; `tome_levels` (default 1) is the number of levels a Level Tome grants instantly.
- **Prestige (beyond 100)**: XP earned past max level fills a prestige bar (`prestige_xp_threshold`, 1000). Each full bar grants a Prestige point with permanent `+HP/+ATK/+SPD` bonuses (configurable in `level_config.tres`), a `★` suffix on the HUD rank/level label and a PRESTIGE banner effect. Prestige bonuses also benefit from the armor/gear XP multiplier.
- **UI**: Current level & XP shown in the health bar overlay with level-up feedback.
- **XP gems**: Orc Brutes (35%) and Skeletons (20%) drop blue XP crystals worth 5 XP.
- **Difficulty scaling**: Each campaign level past the first scales enemy HP (`+35%/level`), damage (`+20%/level`) and XP reward (`+25%/level`).
- **Armor v2**: 5 armors across tiers — each grants flat + percentage damage reduction, a speed multiplier and a cyan halo, plus (new) an XP multiplier, dash cooldown multiplier and move speed multiplier. Legendary drops: Mystic Aegis (Ember Canyon) and Stormlord Plate (Mystic Grove).
- **Gear up v2**: 8 permanent upgrades — ATK, HP, SPD, Dash cooldown, CRIT (2× damage chance), Lifesteal, XP boost and flat Armor reduction — dropped in levels 1–9 and shown on the HUD.
- **Gear up v3**: 14 permanent upgrades total — adds Thorns (reflect), Magnet (wider gem vacuum), Regen (HP/sec), Fury (attack speed), Knockback (knockback force) and CRIT DMG (crit multiplier) on top of the previous 8, dropped across levels 1–9.
- **XP Scrolls**: XP Scroll (grants `parchment_xp`, respects XP multiplier) and Level Tome (grants `tome_levels` instantly) pickups found in levels 1, 2, 3, 7 and 9.

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
│   │   ├── fire_imp.gd / fire_imp.tscn # Fast ember goblin, XP gem drops
│   │   ├── crystal_wisp.gd / crystal_wisp.tscn # Floating mystic crystal, XP gem drops
│   │   ├── boss_projectile.gd
│   │   └── boss_projectile.tscn
│   ├── config/
│   │   ├── level_config.gd
│   │   ├── level_config.tres
│   │   └── weapons/                 # Weapon resource + sword .tres files
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
│   │   ├── level_8_ember_canyon.tscn # Ember Canyon: fire imps, lava tint
│   │   ├── level_9_mystic_grove.tscn # Mystic Grove: crystal wisps, XP gems
│   │   ├── level_9_mystic_grove.tscn # Mystic Grove: crystal wisps, XP gems
│   │   ├── level_7_shadow_arena.tscn # Shadow Knight arena (final)
│   │   └── level_10_exp_grind.tscn   # EXP Grind Arena: respawning mobs + boss
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
│   │   ├── xp_gem.tscn            # Enemy drop, +5 XP
│   │   ├── weapon_pickup.gd
│   │   └── weapon_pickup.tscn     # Sword drop, equips Weapon resource
│   ├── Effects/
│   │   ├── floating_text.gd
│   │   └── floating_text.tscn     # "+XP" popup on kill
│   ├── autoload/
│   │   └── season_manager.gd      # Seasons: palettes, weather, cycle (Q)
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
| 2026-08-13 | Venom Cavern seviyesi — VenomKing boss-gate arenası (locked portal + gate açılış banner'ı), zehir temalı düşman yerleşimi (VenomSlime/Spider/VenomArcher/StoneBrute/Bat/Elite guard), Frost Sword & Mystic Aegis ödülleri, kampanya zincirine index 8 olarak eklendi (Mystic Grove → Venom Cavern → EXP Grind Arena → Shadow Keep) |
| 2026-08-12 | EXP Grind Arena — boss grind map refactor: `level.gd` grind mode (XP çarpanı + düşman/boss respawn + boss respawn banner), level_10_exp_grind.tscn yerleşimi (40+ düşman, Shadow Knight grind boss, XP pickup'ları), kampanya zincirine eklendi (index 8) |
| 2026-08-11 | XP/level refactor (XpProgression sınıfı), level setleme ayarları (starting_level/XP + parşömen XP/tome), XP Scroll & Level Tome pickup'ları, Gear up v3 (Thorns/Magnet/Regen/Fury/Knockback/CRIT DMG) + seviye yerleşimleri |
| 2026-08-10 | EXP prestige sistemi (100 sonrası ★ prestij + kalıcı bonuslar), Armor v2 (XP/dash/hız çarpanları + Mystic Aegis & Stormlord Plate), Gear up v2 (CRIT/Lifesteal/XP/Armor) + seviye yerleşimleri |
| 2026-08-09 | EXP rework v2: parametrized 4-phase XP curve to 100, 11 rank titles (persona) in HUD & level-up banner, scaling milestone bonuses every 10 levels |
| 2026-08-08 | Armor system (3 cyan armors + damage reduction + halo), gear up pickups (ATK/HP/SPD/Dash), Cyan Stormblade with SHOCK stun, EXP cap 100 + milestone bonuses, animated main menu with BGM |
| 2026-08-07 | Crystal Wisp enemy + Mystic Grove level (9-level campaign), XP gem / chest / potion placement |
| 2026-08-06 | Weapons (Iron/Fire/Frost/Royal swords + status effects), Ember Canyon level, Fire Imp enemy, season system (Q), HUD weapon/season labels |
| 2026-08-06 | Level-up effect (banner + particles + jingle + stat summary), XP gem magnet, +XP pickups, damage numbers, player level scaling, HUD XP text & smooth bar |
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

*Last updated: 2026-08-13*
