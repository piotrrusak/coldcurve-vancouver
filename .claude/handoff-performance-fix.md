# Handoff: Level 7 Performance Fix

## Context

**Game:** Coldcurve Vancouver — Godot 4.6 top-down 2D  
**Branch:** `jbrs/levels`  
**Relevant prior handoff:** `.claude/handoff-map-creation.md` (map architecture, binary format, nav polygon workflow)

---

## The Problem

Level 7 runs poorly. Root cause: **160 enemies × 61 raycasts each = ~9,760 physics raycasts per frame** (every `_physics_process`).

### Why it's worse than level 6

Level 6 has ~100 enemies → ~6,100 raycasts/frame.  
Level 7 has 160 enemies → ~9,760 raycasts/frame. That's a 60% jump.  
Map size difference is negligible — enemy count is the bottleneck.

### What runs every frame per enemy

In `scripts/enemies/base_enemy.gd:56`, `_sight.update_cone()` is called unconditionally every `_physics_process`. This calls `SightService.update_cone()` in `scripts/enemies/base_enemy_services/sight_service.gd`:

```gdscript
# sight_service.gd:27-40
func update_cone():
    var half_fov := deg_to_rad(_enemy.fov / 2.0)
    var space := _enemy.get_world_2d().direct_space_state
    var points: Array[Vector2] = [Vector2.ZERO]
    for i in range(FOV_RAYS + 1):  # FOV_RAYS = 60 → 61 iterations
        ...
        var result := space.intersect_ray(query)  # physics raycast
        ...
    _sight_cone.polygon = PackedVector2Array(points)
```

`FOV_RAYS = 60` is declared at `sight_service.gd:3`. Each ray is a physics raycast against collision mask 1 (walls). The sight cone is purely cosmetic — it's the visible triangle on the enemy. It does **not** affect gameplay logic; `player_in_sight()` is a separate single raycast.

---

## The Fix (best perf/quality ratio)

**Throttle `update_cone()` to every 3rd physics frame.**

The sight cone polygon is cosmetic only. The player cannot perceive 60Hz vs 20Hz updates on a triangle drawn on an enemy. State transitions (SEARCH → ENGAGE) are unaffected — they depend on `player_in_sight()`, not the cone polygon.

### Implementation

In `scripts/enemies/base_enemy.gd`, change both call sites of `_sight.update_cone()`:

```gdscript
# base_enemy.gd:41-58 — current
func _physics_process(delta):
    if _state.player == null or not _state.player.visible:
        _state.enter_search()
        _sight.update_cone()        # ← throttle this
        move_and_slide()
        return

    match _state.state:
        ...

    _sight.update_cone()            # ← and this
    velocity *= GameSettings.enemy_speed_multiplier
    move_and_slide()
```

Replace both `_sight.update_cone()` calls with a frame-modulo guard:

```gdscript
if Engine.get_physics_frames() % 3 == 0:
    _sight.update_cone()
```

Each enemy already has a different spawn time so their frame offsets will naturally stagger. Alternatively, use `get_instance_id() % 3` as the modulo target so enemies are permanently staggered:

```gdscript
if Engine.get_physics_frames() % 3 == get_instance_id() % 3:
    _sight.update_cone()
```

This second form guarantees no two enemies update their cone on the same frame (approximately), distributing the load more evenly across frames.

### Expected result

~9,760 raycasts/frame → ~3,253 raycasts/frame. No visible gameplay change.

---

## Other Considered Fixes (lower ratio)

| Fix | Effort | Gameplay impact |
|---|---|---|
| Throttle cone rebuild (recommended) | 2 lines | None — purely cosmetic |
| Reduce `FOV_RAYS` from 60 to 30 | 1 line | Slight cone shape degradation at edges |
| Stagger `NavigationAgent2D` path updates | Moderate | Enemies feel slightly less reactive |

---

## Suggested Skills

- **verify** — after applying the fix, run the game on level 7 and confirm framerate improvement and no sight-cone regressions
- **code-review** — check the throttle logic for edge cases (e.g. enemy spawned mid-frame, modulo distribution)
