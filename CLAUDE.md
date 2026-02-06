# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**La Odisea del Gaucho** is a Godot 4.6 2D endless runner game where players control a Gaucho character through the Argentine Pampa, collecting mates and avoiding obstacles. After collecting 100 mates, the game transitions to a final card game challenge against "La Muerte" (Death) playing Truco, a traditional Argentine card game.

**Tech Stack:**
- Engine: Godot 4.6 (GL Compatibility mode)
- Language: GDScript
- Testing: GUT (Godot Unit Test) addon

## Running and Testing

**Run the game:**
```bash
# Open the project in Godot Editor and press F5, or:
godot --path . res://ui/menus/main_menu/menu_principal.tscn
```

**Run tests:**
```bash
# Using GUT addon in Godot Editor:
# Bottom panel -> GUT -> Run All
# Tests are located in tests/unit/
```

**Debug commands (only in debug builds):**
- F9: Win Truco game instantly
- F10: Lose Truco game instantly
- F11: Add 10 points to player in Truco

## Architecture

The project follows a **component-based architecture** with specialized manager singletons (Autoloads) that handle global concerns.

### Manager Layer (Autoloads)

All managers are autoloaded in `project.godot` and accessible globally:

- **GameManager** (`core/game_manager.gd`): Compatibility facade that delegates to specialized managers. Use this for backward compatibility only.
- **DifficultyManager** (`core/difficulty_manager.gd`): Manages game speed progression
- **ConfigManager** (`core/config_manager.gd`): Handles audio/video settings
- **SceneManager** (`core/scene_manager.gd`): Scene transitions and time effects
- **ScoreManager** (`systems/score/score_manager.gd`): Mate collection and scoring
- **LivesManager** (`systems/lives/lives_manager.gd`): Player lives and death state
- **SaveManager** (`core/save_manager.gd`): Save/load game state, including Truco scores between sessions
- **DebugMenu** (`systems/debug/debug_menu.tscn`): Debug overlay for testing

**IMPORTANT:** When working with game state, prefer using the specialized managers directly (e.g., `ScoreManager.agregar_mates()`) rather than going through `GameManager`. The GameManager is maintained for backward compatibility only.

### Game Flow

1. **Main Menu** (`ui/menus/main_menu/menu_principal.tscn`) → Entry point
2. **Intro Cinematic** (`scenes/cinematics/intro_cinematic/`) → Narrative setup
3. **Pampa Level** (`scenes/levels/nivel_pampa.tscn`) → Endless runner gameplay
4. **Rancho Transition** (`scenes/cinematics/rancho_transition/`) → 100 mates reached
5. **Truco Game** (`scenes/truco_game/truco.tscn`) → Card game vs La Muerte
6. **Victory/Defeat** (`scenes/cinematics/jugador_victoria/` or `muerte_victoria/`)

### Core Systems

**Dialogue System** (`systems/dialogue/`):
- `DialogueManager`: Displays dialogue with typewriter effect
- `DialogueLoader`: Loads text from CSV files in `data/dialogues/`
- Used extensively in cinematics

**Spawning System** (`systems/spawning/`):
- `obstacle_spawner.gd`: Spawns obstacles based on distance traveled
- `mate_spawner.gd`: Spawns collectible mates
- Both use distance-based triggers, not timers

**Truco Game System** (`scenes/truco_game/`):
- **TrucoController**: Main orchestrator of the card game flow
- **TrucoState**: Game state (cards, points, rounds)
- **TrucoRules**: Card comparison and winning logic
- **EnvidoSystem**: Handles "Envido" betting mechanic
- **TrucoBetting**: Manages "Truco" betting levels (Truco/Retruco/Vale Cuatro)
- **TrucoUI**: All UI rendering and user input
- **AIMuerte**: AI opponent with strategic decision making
- **Deck**: Card deck management

The Truco system is highly modular - each component has a single responsibility. TrucoController connects all systems together.

### Component Architecture (Player)

The player (`entities/player/`) uses a **component pattern**:
- `player.gd`: Minimal orchestrator script
- `PlayerController`: Movement physics and input
- `PlayerVisual`: Animation and rendering
- `PlayerDeath`: Damage, invincibility, death logic
- `PlayerCollision`: Collision detection with obstacles

This pattern separates concerns and keeps scripts under 300 lines.

## File Organization

The project groups files by functionality, not by type:

```
core/              - Global managers (singletons)
systems/           - Reusable systems (dialogue, spawning, debug)
scenes/            - Game scenes with their scripts
  ├─ cinematics/   - Narrative sequences
  ├─ levels/       - Playable levels (Pampa)
  ├─ truco_game/   - Card game implementation
  └─ chapter_transition/ - Between-chapter screens
entities/          - Game entities (player, obstacles, collectibles)
ui/                - UI components (menus, HUD, dialogue boxes)
  ├─ menus/        - Main menu, settings
  ├─ hud/          - In-game UI
  └─ components/   - Reusable UI elements
data/              - Data files (CSV dialogues)
assets/            - Art and audio resources
tests/unit/        - Unit tests using GUT
```

**Key Principle:** Everything related to a system lives together (scene + script + assets in same folder).

## Development Guidelines

**Follow BUENAS_PRACTICAS.md** (`docs/BUENAS_PRACTICAS.md`):
- One script = one responsibility
- Keep scripts under 300 lines
- Use signals for communication, avoid `get_parent().get_parent()`
- Data-driven design: Use Resources or JSON for data
- Prefer `_physics_process()` only when necessary
- No hardcoded input keys - use Input Map

**Naming Conventions:**
- Files/folders: `snake_case` (e.g., `game_manager.gd`)
- Classes: `PascalCase` (e.g., `TrucoController`)
- Variables/functions: `snake_case` (e.g., `velocidad_actual`)
- Constants: `UPPER_CASE` (e.g., `INCREMENTO_VELOCIDAD`)

**Input Map:**
- `salto`: Space, Up Arrow (jump)
- `agacharse`: S, Down Arrow (crouch)
- `skipear`: Escape, Space (skip dialogue)

**Physics Layers:**
- Layer 1: "Suelo" (Ground)
- Layer 2: "Jugador" (Player)

## Key Implementation Details

**Infinite Scrolling:**
The ground texture scrolls continuously and loops when it reaches the edge. Obstacles and mates spawn based on distance traveled (tracked in spawners), not based on time.

**Lives System:**
- Player has 3 lives (managed by `LivesManager`)
- UI displays as hearts in HUD
- 1.5s invincibility with blinking effect after damage
- Death cause is stored for game over screen

**Difficulty Progression:**
Speed increases every 10 mates collected. Managed by `DifficultyManager`.

**Truco Rules:**
- First to 15 points wins
- Best of 3 rounds per hand
- Envido can only be called in first round
- Points persist between Truco sessions (saved via SaveManager)
- AI uses strategic decision making based on card strength and envido values

## Common Development Tasks

**Adding a new obstacle:**
1. Create scene in `entities/obstacles/`
2. Must be Area2D with collision shape
3. Add to spawner pool in `obstacle_spawner.gd`
4. Test collision with player

**Adding dialogue:**
1. Create/edit CSV in `data/dialogues/`
2. Use DialogueLoader to load it
3. Connect to DialogueManager signals for progression

**Modifying Truco mechanics:**
- Card values: `truco_rules.gd`
- Betting logic: `truco_betting.gd` or `envido_system.gd`
- AI behavior: `scenes/truco_game/ai/ai_decision.gd`
- UI: `truco_ui.gd`

**Adding a new manager:**
1. Create script in `core/` or `systems/`
2. Add to Autoload in Project Settings (or `project.godot`)
3. Ensure it's a singleton (extends Node)

## Important Files to Read First

When working on specific areas, read these files first:

- **Game state/flow:** `core/game_manager.gd`, then the specialized managers
- **Player mechanics:** `entities/player/player.gd` and its components
- **Truco game:** `scenes/truco_game/truco_controller.gd` (orchestrator)
- **Spawning logic:** `systems/spawning/obstacle_spawner.gd`
- **Scene transitions:** `core/scene_manager.gd`
