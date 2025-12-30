# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Gaucholand** is a Godot 4.5 endless runner game built with GDScript. The game features a player character that runs automatically while jumping over obstacles in a side-scrolling environment.

## Running the Game

This is a Godot project. Open it in Godot Editor (version 4.5+) and press F5 to run. The main scene is automatically configured in `project.godot`.

## Project Architecture

### Scene Hierarchy

The game uses a nested scene structure:

- **Main Scene**: `scenes/nivel_pampa/nivel_pampa.tscn`
  - Instantiates the base level scene (`scenes/nivel/nivel.tscn`)
  - Adds the player character
  - Adds a Camera2D for following the action

- **Base Level**: `scenes/nivel/nivel.tscn`
  - Contains the scrolling ground (`Suelo`)
  - Contains the obstacle spawner system
  - May contain a static obstacle instance for reference

### Core Systems

**1. Infinite Scrolling Ground** (`scenes/suelo/`)
- Uses `TileMapLayer` that moves left at constant speed
- Implements looping by resetting position when moved too far left
- Speed synchronized with obstacles (default: 200 pixels/second)
- Loop width configurable via `@export var loop_width`

**2. Obstacle Spawning System** (`scenes/obstaculo/`)
- **Spawner** (`obstacle_spawner.gd`): Spawns obstacles at regular intervals
  - Calculates spawn position relative to camera viewport edge
  - Uses distance-based spawning (accumulates distance traveled)
  - Spawns obstacles off-screen to the right with configurable offset
  - Key exports: `spawn_distance`, `ground_y`, `speed`, `spawn_offset`

- **Obstacles** (`obstacle.gd`): Individual obstacle instances
  - Move left at synchronized speed with ground
  - Auto-delete when off-screen (x < -580)
  - Emit `jugador_muerto` signal on collision
  - Use Area2D with collision_mask = 2 (player layer)

**3. Player Character** (`scenes/jugador/`)
- CharacterBody2D with jump-only controls
- Automatically added to "player" group in `_ready()`
- Gravity and jump physics via `_physics_process()`
- Input action: "salto" (mapped to Space and Up Arrow)
- Death sequence: red tint, pause, reload scene after 1 second
- Must be in collision layer 2 ("Jugador") to interact with obstacles

### Physics Layers

Defined in `project.godot`:
- **Layer 1**: "Suelo" (Ground)
- **Layer 2**: "Jugador" (Player)

Obstacles use `collision_layer = 0` and `collision_mask = 2` to only detect player.

### Critical Implementation Details

**Obstacle Positioning**:
- Obstacles are positioned by the spawner at the Area2D root level
- Visual elements (Sprite2D, ColorRect) and CollisionShape2D must be centered at (0,0) relative to the Obstacle root node
- If visual elements have incorrect offsets, obstacles will spawn but appear in wrong locations
- The spawner sets `obstacle.position.x` and `obstacle.position.y` directly on the root node

**Speed Synchronization**:
- Ground, obstacles, and spawner MUST use the same speed value (200.0 default)
- Changing speed in one place requires updating all three components
- Speed is exported separately in each script for independent tweaking if needed

**Camera-Based Spawning**:
- Spawner uses `get_viewport().get_camera_2d()` to find camera position
- Spawn X = camera center X + (viewport width / 2) + spawn_offset
- This ensures obstacles always spawn just outside the visible area

## File Naming Conventions

- Scripts: lowercase with underscores (e.g., `obstacle_spawner.gd`)
- Scenes: lowercase with underscores (e.g., `obstacle_spawner.tscn`)
- Scene folders: named after the component (jugador, obstaculo, suelo, nivel)
