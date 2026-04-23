# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Coldcurve Vancouver** — a top-down 2D game built with Godot 4.6. The game viewport is 480×720 (portrait, scaled from a 1280×720 canvas). The main scene is `scenes/main.tscn`.

## Running the game

There is no CLI build system. Open the project in the Godot 4.6 editor and press **F5** (Run Project) or use:

```sh
godot --path /path/to/project
```

There are no automated tests or linters configured.

## Code architecture

Scripts live under `scripts/` and mirror the `scenes/` directory structure. Scenes are the source of truth for node composition; scripts attach to nodes via `script =` in `.tscn` files.

### Game loop (`scripts/main.gd` / `scenes/main.tscn`)

`Main` owns the game lifecycle: it spawns enemies on a timer along a `Path2D` perimeter, tracks the score, and wires `Player.hit` → `game_over()` and `HUD.start_game` → `new_game()`. Score increments via `enemy_hit` signal forwarded from each spawned enemy instance.

### Player (`scripts/player/player.gd`)

`CharacterBody2D` drawn procedurally (circle body + tapered cyan blade). Movement via WASD/arrow/HJKL. The blade `Area2D` (`$Weapon`) detects enemies; on contact it emits `enemy_hit` on the enemy and frees it. The player emits `hit` when killed (by an enemy area or projectile).

Collision groups: `"player"` (used by enemies and projectiles to detect the player).

### Enemy AI (`scripts/enemies/base_enemy.gd` + `base_enemy_services/`)

The enemy is a `CharacterBody2D` in group `"enemies"`. AI logic is split into child service nodes under a `Services` container node:

| Service | Role |
|---|---|
| `StateService` | Owns the `State` enum (`SEARCH / INVESTIGATE / ENGAGE`), shared mutable state (`facing_angle`, `strafe_dir`, `player` ref), and the `SightCone` color. |
| `SightService` | Raycasts to determine if the player is within FOV and range; also rebuilds the `SightCone` polygon each frame using 60 rays. |
| `SearchService` | Navigates via `NavigationAgent2D` using a ping-pong waypoint strategy between a configurable `pathfinding_goal` and random nav-mesh points; periodically pauses to scan. Transitions → ENGAGE when player is spotted. |
| `InvestigateService` | Navigates at 2× speed to the last known player position, scans on arrival, then falls back to SEARCH after `los_grace_period` seconds. |
| `EngageService` | Strafes perpendicular to the player via nav mesh; transitions → INVESTIGATE when LOS is lost. |

Each service resolves its siblings at `_ready()` via `get_parent().get_node(...)` (the `Services` node is the shared parent). **Never restructure the `Services` node hierarchy without updating all service `_ready()` calls.**

`base_enemy.gd` drives the state machine in `_physics_process`: it dispatches to the active service's `process(delta)` and calls `move_and_slide()` once per frame.

### Projectiles (`scripts/enemies/enemy_projectiles/projectile.gd`)

`RigidBody2D` fired by the enemy's `ShootTimer` during ENGAGE state. Frees itself on hitting the player or leaving the screen. Drawn procedurally (red triangle); marked TODO for sprite replacement.

### HUD (`scripts/Chud/hud.gd`)

`CanvasLayer` with a score label, game-over label, and start button. Emits `start_game` signal; receives `update_score(score)` and `show_game_over()` calls from `Main`. The folder is named `Chud` (not `HUD`).

## Collision layers

| Layer | Meaning |
|---|---|
| 1 | Walls/tilemap (blocks sight rays) |
| 2 | Player |
| 4 | Enemies |

`SightService` raycasts use mask `3` (layers 1+2) for player detection and mask `1` for the cone geometry.

## Input actions

Defined in `project.godot`: `move_left/right/up/down` (WASD, arrows, HJKL) and `start_game` (Enter, Space).
