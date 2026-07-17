# Contributing to AARPG

Thanks for considering a contribution!

## Quick Start

```bash
git clone https://github.com/your-username/new-rpg-test-px.git
cd new-rpg-test-px
git checkout -b feature/your-feature-name
```

Open the project in **Godot 4.4+** and start developing.

## Guidelines

### Code Style

| Convention | Example |
|---|---|
| Variables / Functions | `snake_case` |
| Classes | `PascalCase` |
| Signals | `snake_case` with past tense (e.g. `health_changed`) |

- Keep functions short and focused on a single responsibility
- Comment non-obvious logic; avoid obvious comments

### Project Structure

| Directory | Description |
|---|---|
| `aarpg/` | Main game scenes and scripts |
| `assets/` | Art, audio, and other resources |
| `Tile Maps/` | Tilemap scenes and configurations |

### Development Workflow

1. Scripts go in the appropriate `Scripts/` subdirectories
2. Test changes in the main scene (`aarpg/playground.tscn`)
3. Ensure zero errors in the Godot console before submitting

## Reporting Issues

### Bug Reports

Open an issue with:
- Steps to reproduce
- Expected vs. actual behavior
- Godot version and OS

### Feature Requests

Open an issue with the `enhancement` label describing the feature and its use case.

## Pull Requests

1. Keep your branch up to date with `main`
2. Update `README.md` if you change project structure or features
3. Submit a PR with a clear description of what changed and why

## Questions?

Open an issue — happy to help!
