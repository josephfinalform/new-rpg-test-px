# AARPG

A top-down action RPG prototype built with Godot 4.4.

## Getting Started

1. Open the project in **Godot 4.4+**
2. Run the main scene: `aarpg/playground.tscn`
3. Controls: **WASD** to move

## Project Structure

```
aarpg/                  # Main game directory
  playground.tscn       # Main scene (entry point)
  Player/
    player.tscn         # Player scene
    Scripts/
      player.gd         # Player movement script
assets/                 # Game assets
  sprites/              # Textures and sprites
  audio/                # Sound effects
```

## Development

Built with Godot 4.4 using the Forward Plus renderer. Viewport resolution is 480x270, stretched to 1600x900.
