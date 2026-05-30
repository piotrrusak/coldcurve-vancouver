# Handoff: Coldcurve Vancouver — Map Design & Creation

## Project Context

**Game:** Coldcurve Vancouver — top-down 2D game, Godot 4.6  
**Working directory:** `/home/jbrs/Documents/code/agh/game`  
**Main scene:** `scenes/main.tscn`  
**Canvas:** 1280×720 (displayed as 480×720 portrait via canvas stretch)

---

## What Was Done This Session

### Architecture Refactor (complete)

Maps are now **separate scene files** loaded dynamically per level. The old single embedded map in `main.tscn` was extracted.

**New files:**
- `scenes/map/level1_map.tscn` — original cross/maze layout
- `scenes/map/level2_map.tscn` — new asymmetric pillars layout (nav polygon baked by Godot editor)

**Modified files:**
- `scenes/main.tscn` — `Map` node is now an **empty Node2D container** (no embedded tilemap)
- `scripts/main.gd` — `_swap_map(level)` instantiates the correct map scene per level

**How map loading works in `main.gd`:**
```gdscript
const LEVEL_MAPS = [
    preload("res://scenes/map/level1_map.tscn"),
    preload("res://scenes/map/level2_map.tscn"),
]
var _current_map: Node = null

func _swap_map(level: int):
    if _current_map:
        _current_map.queue_free()
        _current_map = null
    _current_map = LEVEL_MAPS[level].instantiate()
    $Map.add_child(_current_map)
```

`_swap_map(current_level)` is called at the top of `start_level()`.

To add a **level 3**, add a new scene to `LEVEL_MAPS` and a new spawn list to `LEVEL_SPAWNS`.

---

## TileMap Binary Format — Complete Encoding Spec

### Key facts
- **Tile size:** 128×128 pixels
- **Map dimensions:** 17 columns × 13 rows = **221 tiles total**
- **Map pixel size:** 2176×1664 px
- **TileSet sources:** `source_id=0` → floor (no collision), `source_id=1` → wall (collision layer 1)
- **Tile atlas:** single tile at atlas coord (0,0) for both floor and wall

### Binary format: `tile_map_data` (TileMapLayer PackedByteArray)

```
[2 bytes: header, always 0x0000]
[For each tile (221 total), 12 bytes each:]
  int16 LE: x  (tile column, 0–16)
  int16 LE: y  (tile row, 0–12)
  int16 LE: source_id  (0=floor, 1=wall)
  int16 LE: atlas_x    (always 0)
  int16 LE: atlas_y    (always 0)
  int16 LE: alternative (always 0)

Total: 2 + 221×12 = 2654 bytes → base64-encoded in the .tscn file
```

### Python encoder (verified correct)

```python
import base64, struct

def encode_map(grid_rows: list[str]) -> str:
    """
    grid_rows: list of 13 strings, each 17 chars.
    '#' = wall (source_id=1), '.' = floor (source_id=0).
    Returns base64 string for tile_map_data PackedByteArray.
    """
    data = b'\x00\x00'  # 2-byte header
    for y, row in enumerate(grid_rows):
        for x, ch in enumerate(row):
            src = 1 if ch == '#' else 0
            data += struct.pack('<hhhhhh', x, y, src, 0, 0, 0)
    return base64.b64encode(data).decode()
```

Cell ordering in the output: row-major (all columns of row 0, then row 1, etc.). Godot accepts any ordering.

### How to use in a .tscn file

```
[node name="Tilemap" type="TileMapLayer" parent="." groups=["navigation"]]
use_parent_material = true
tile_map_data = PackedByteArray("<INSERT_BASE64_HERE>")
tile_set = SubResource("TileSet_001")
```

---

## Current Map Layouts

### Level 1 (original — cross/maze pattern)
```
#################   row 0
#...............#   row 1
#...............#   row 2
#...............#   row 3
#.....#.###.....#   row 4  ← interior walls
#.....#.........#   row 5
#.....#.#.#.....#   row 6
#.........#.....#   row 7
#.....###.#.....#   row 8
#...............#   row 9
#...............#   row 10
#...............#   row 11
#################   row 12
```

### Level 2 (new — asymmetric pillar design)
```
#################   row 0
#...............#   row 1
#.##.........##.#   row 2  ← corner pillars (cols 2-3, 13-14)
#...............#   row 3
#...#.......#...#   row 4  ← side obstacles (cols 4, 12)
#...#...........#   row 5  ← col 4 only (asymmetric)
#...............#   row 6
#.....#.........#   row 7  ← off-centre obstacle (col 6)
#...#.......#...#   row 8  ← side obstacles (cols 4, 12)
#...............#   row 9
#.##.........##.#   row 10 ← corner pillars (cols 2-3, 13-14)
#...............#   row 11
#################   row 12
```

---

## Map Design Rules

### Hard constraints
1. **Outer border** (row 0, row 12, col 0, col 16) must be **all wall** (`#`)
2. **Tile size is 128×128px** — well above the 16px minimum requirement
3. **All spawn positions must land on floor tiles** — verify before encoding
4. **Interior must be fully connected** — no isolated floor regions (enemies need to reach player)

### Level spawn positions (pixel coords, do not change count)

**Level 1** (7 enemies):
```
(550,400), (1050,350), (1550,400),
(450,850), (1650,850),
(550,1200), (1550,1200)
```

**Level 2** (12 enemies):
```
(550,400), (1050,350), (1550,400),
(450,850), (1650,850),
(550,1200), (1550,1200), (1050,1200),
(750,650), (1350,650),
(650,1000), (1450,1000)
```

### Converting pixel spawn coords to tile coords
```python
tile_x = pixel_x // 128
tile_y = pixel_y // 128
```

### Checking spawn validity
```python
def check_spawns(grid_rows, spawns_px):
    for (px, py) in spawns_px:
        tx, ty = px // 128, py // 128
        ch = grid_rows[ty][tx]
        assert ch == '.', f"Spawn ({px},{py}) → tile ({tx},{ty}) is WALL"
```

---

## Navigation Polygon

### What it is
The `NavigationRegion2D` node contains a baked `NavigationPolygon` that enemies use for pathfinding (`NavigationAgent2D`). It must match the walkable areas of the tilemap.

### Level 1 nav polygon
Taken directly from the original `main.tscn` — complex triangulation baked in the editor. Correctly routes around the interior cross walls.

### Level 2 nav polygon
Baked by Godot editor — the editor updated `level2_map.tscn` with a properly triangulated polygon after the scene file was written.

### For new maps: how to get the nav polygon
1. Create the map scene with `NavigationRegion2D` set to:
   ```
   source_geometry_mode = 1
   source_geometry_group_name = &"navigation"
   agent_radius = 45.0
   ```
2. Open the scene in Godot editor
3. Select `NavigationRegion2D` → click **Bake NavigationPolygon**
4. Save the scene — Godot writes the baked polygon into the file

**Alternatively**, provide a simple rectangle as a placeholder nav polygon (enemies will use physics collision to avoid walls — suboptimal but functional):
```
[sub_resource type="NavigationPolygon" id="NavigationPolygon_001"]
vertices = PackedVector2Array(173, 173, 2003, 173, 2003, 1491, 173, 1491)
polygons = Array[PackedInt32Array]([PackedInt32Array(0, 1, 2), PackedInt32Array(0, 2, 3)])
outlines = Array[PackedVector2Array]([PackedVector2Array(173, 173, 2003, 173, 2003, 1491, 173, 1491)])
source_geometry_mode = 1
source_geometry_group_name = &"navigation"
agent_radius = 45.0
```
`(173, 173)` = inner boundary start (128px wall + 45px agent_radius), `(2003, 1491)` = inner boundary end.

---

## Full Scene Template for a New Level Map

```
[gd_scene format=4 uid="uid://UNIQUE_UID_HERE"]

[ext_resource type="Texture2D" uid="uid://p52j5k6q5uut" path="res://assets/tiles/floor.png" id="1_floor"]
[ext_resource type="Texture2D" uid="uid://mqvls2ppk2kh" path="res://assets/tiles/wall.png" id="2_wall"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_floor"]
texture = ExtResource("1_floor")
texture_region_size = Vector2i(128, 128)
0:0/0 = 0

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_wall"]
texture = ExtResource("2_wall")
texture_region_size = Vector2i(128, 128)
0:0/0 = 0
0:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-64, -64, 64, -64, 64, 64, -64, 64)

[sub_resource type="TileSet" id="TileSet_001"]
tile_size = Vector2i(128, 128)
physics_layer_0/collision_layer = 1
physics_layer_0/collision_mask = 0
sources/0 = SubResource("TileSetAtlasSource_floor")
sources/1 = SubResource("TileSetAtlasSource_wall")

[sub_resource type="NavigationPolygon" id="NavigationPolygon_001"]
vertices = PackedVector2Array(173, 173, 2003, 173, 2003, 1491, 173, 1491)
polygons = Array[PackedInt32Array]([PackedInt32Array(0, 1, 2), PackedInt32Array(0, 2, 3)])
outlines = Array[PackedVector2Array]([PackedVector2Array(173, 173, 2003, 173, 2003, 1491, 173, 1491)])
source_geometry_mode = 1
source_geometry_group_name = &"navigation"
agent_radius = 45.0

[node name="LevelMap" type="Node2D"]

[node name="Tilemap" type="TileMapLayer" parent="." groups=["navigation"]]
use_parent_material = true
tile_map_data = PackedByteArray("INSERT_BASE64_HERE")
tile_set = SubResource("TileSet_001")

[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]
navigation_polygon = SubResource("NavigationPolygon_001")
```

UIDs must be unique across the project. Existing scene UIDs:
- `uid://b15cqvql2mq1e` — main.tscn
- `uid://blevel1map001` — level1_map.tscn
- `uid://blevel2map001` — level2_map.tscn

---

## Steps to Add a New Level (e.g. Level 3)

1. **Design the map** — 17×13 grid of `#` and `.`; outer border all `#`; verify all spawn positions are `.`
2. **Encode** — run the Python `encode_map()` function → get base64 string
3. **Create** `scenes/map/level3_map.tscn` — use the scene template above, paste base64
4. **Wire up** in `scripts/main.gd`:
   - Add `preload("res://scenes/map/level3_map.tscn")` to `LEVEL_MAPS`
   - Add spawn positions to `LEVEL_SPAWNS`
5. **Bake nav polygon** — open `level3_map.tscn` in Godot editor, select `NavigationRegion2D`, click Bake

---

## Collision Layers Reference

| Layer | Meaning |
|---|---|
| 1 | Walls/tilemap (wall tiles use this) |
| 2 | Player |
| 4 | Enemies |

`SightService` raycasts use mask `3` (layers 1+2) for player detection, mask `1` for cone geometry.

---

## Suggested Skills

- **codebase-analyzer** — to trace how `NavigationAgent2D` in enemies interacts with the nav polygon, or how `SightService` raycasts relate to wall collision
- **verify** — after writing a new map, run the game and confirm the map renders correctly and enemies navigate on it
- **code-review** — to check `_swap_map` edge cases (e.g., `queue_free` timing)
