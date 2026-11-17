#!/usr/bin/env python3
"""Build the Neon Skyrail parkour course in map1_solid-compatible form."""
from __future__ import annotations

import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
UNITY = ROOT / "Game-SSJJ" / "Assets" / "Parkour"
SOLID = ROOT / "SSJJ-Server" / "Data" / "Maps" / "map3101_solid.json"

MATERIALS = {
    "deck_circuit": (0.96, 0.98, 1.0),
    "deck_grate": (0.96, 0.98, 1.0),
    "deck_hazard": (1.0, 0.97, 0.90),
    "deep_navy": (0.72, 0.78, 0.88),
    "steel": (0.88, 0.91, 0.95),
    "cyan": (0.92, 0.97, 1.0),
    "amber": (1.0, 0.94, 0.82),
    "lime": (0.87, 0.95, 0.82),
    "violet": (0.92, 0.88, 1.0),
    "white": (0.93, 0.97, 1.0),
    "hazard": (1.0, 0.94, 0.82),
}
TEXTURES = {
    "deck_circuit": "Skyrail_CircuitDeck.png",
    "deck_grate": "Skyrail_HexGrate.png",
    "deck_hazard": "Skyrail_HazardDeck.png",
    "deep_navy": "Map101_S_city_06.png",
    "steel": "Map101_S_city_01.png",
    "cyan": "Map101_S_city_02.png",
    "amber": "Map101_S_city_04.png",
    "lime": "Map101_S_city_12.png",
    "violet": "Map101_S_city_08.png",
    "white": "Map101_S_city_13.png",
    "hazard": "Map101_S_city_04.png",
}

# raw map coordinates are (forward, lateral, height); Unity export maps them
# to (-lateral, height, forward), exactly as BuildMap1.cs does.
# Stair sections keep the Map101 260-square footprints recorded in
# Game-SSJJ-Source/Assets/Decompiled/OfflineParkour.cs. The user requested
# lower 60-unit rises and a clear gap equal to one platform length.
# The visible/collision blocks are 80 units thick, with all visible models
# represented in the collision mesh and BSP.
# Flat sections deliberately hold height and vary their gaps and lateral line.
ROUTE: list[tuple[float, float, float, float, float, str, str]] = [
    (0, 0, 200, 1200, 1200, "deck_circuit", "start")
]

# 1) Flat sprint: mostly straight, broad landings at one height.
_flat_colors = ("deck_circuit", "deck_grate", "deck_circuit", "deck_hazard")
_flat_laterals = (0, -120, -180, -120, 0, 120, 180, 120, 0, -120, 0, 120)
for _i in range(12):
    ROUTE.append((1080 + _i * 640, _flat_laterals[_i], 220, 320, 420,
                  _flat_colors[_i % 4], "flat_dash"))

# 2) Map101-footprint staircase climb with lower rises and longer jump gaps.
for _i in range(16):
    _color = ("deck_grate", "deck_circuit", "deck_grate", "deck_hazard")[_i // 4]
    ROUTE.append((8670 + _i * 520, -80 + (160 if _i % 2 == 0 else 0),
                  280 + _i * 60, 260, 260, _color, "stair_a"))

# 3) Flat zigzag: constant elevation, lateral lane changes, and medium gaps.
_zig_laterals = (0, 120, 180, 120, 0, -120, -180, -120, 0, 120, 0, -120)
_zig_colors = ("deck_grate", "deck_circuit", "deck_hazard", "deck_grate")
for _i in range(12):
    ROUTE.append((17110 + _i * 680, _zig_laterals[_i], 1180, 340, 420,
                  _zig_colors[_i % 4], "flat_zigzag"))

# 4) A second Map101-scale climb with a different color cadence.
for _i in range(16):
    _color = ("deck_circuit", "deck_grate", "deck_circuit", "deck_hazard")[_i // 4]
    ROUTE.append((25150 + _i * 520, 80 - (160 if _i % 2 == 0 else 0),
                  1240 + _i * 60, 260, 260, _color, "stair_b"))

# 5) Flat finish sprint with alternating widths and gentle lane shifts.
_sprint_laterals = (-150, -100, 0, 100, 150, 80, 0, 0)
_sprint_widths = (520, 460, 420, 500, 440, 480, 520, 480)
for _i in range(8):
    _color = "deck_hazard" if _i in (3, 7) else ("deck_circuit" if _i % 2 == 0 else "deck_grate")
    ROUTE.append((33560 + _i * 640, _sprint_laterals[_i], 2140,
                  320, _sprint_widths[_i], _color, "flat_finish"))

ROUTE.append((38970, 0, 2140, 900, 900, "deck_circuit", "finish"))

visual_meshes: dict[str, list[tuple[list[tuple[float, float, float]], list[tuple[int, int, int]]]]] = {
    name: [] for name in MATERIALS
}
solid_verts: list[list[float]] = []
solid_tris: list[list[int]] = []
collision_boxes: list[dict[str, object]] = []


_BOX_FACES = [(0, 2, 1), (0, 3, 2), (4, 5, 6), (4, 6, 7),
              (0, 1, 5), (0, 5, 4), (1, 2, 6), (1, 6, 5),
              (2, 3, 7), (2, 7, 6), (3, 0, 4), (3, 4, 7)]


def add_collision_box(center, size, yaw: float = 0.0):
    """Mirror one visible cuboid into both the OBJ collision mesh and BSP data."""
    cx, cy, cz = center
    sx, sy, sz = (v / 2 for v in size)
    c, s = math.cos(yaw), math.sin(yaw)
    raw = []
    for x, y, z in [(-sx, -sy, -sz), (sx, -sy, -sz), (sx, sy, -sz), (-sx, sy, -sz),
                    (-sx, -sy, sz), (sx, -sy, sz), (sx, sy, sz), (-sx, sy, sz)]:
        raw.append((cx + x * c - y * s, cy + x * s + y * c, cz + z))
    base = len(solid_verts)
    solid_verts.extend([[round(a, 3), round(b, 3), round(d, 3)] for a, b, d in raw])
    solid_tris.extend([[base + i, base + j, base + k] for i, j, k in _BOX_FACES])
    collision_boxes.append({"center": [round(v, 3) for v in center],
                            "size": [round(v, 3) for v in size],
                            "yaw": round(yaw, 6)})


def box(center, size, material: str, yaw: float = 0.0):
    """Add a visible cuboid and always give it a six-sided collision shell."""
    cx, cy, cz = center
    sx, sy, sz = (v / 2 for v in size)
    c, s = math.cos(yaw), math.sin(yaw)
    raw = []
    for x, y, z in [(-sx, -sy, -sz), (sx, -sy, -sz), (sx, sy, -sz), (-sx, sy, -sz),
                    (-sx, -sy, sz), (sx, -sy, sz), (sx, sy, sz), (-sx, sy, sz)]:
        raw.append((cx + x * c - y * s, cy + x * s + y * c, cz + z))
    visual_meshes[material].append((raw, _BOX_FACES))
    add_collision_box(center, size, yaw)


def torus(center, major=180, minor=18, material="cyan", around_x=True, segments=28, sides=8):
    """Add a decorative ring and segmented box colliders around its visible tube."""
    cx, cy, cz = center
    verts = []
    faces = []
    for i in range(segments):
        theta = 2 * math.pi * i / segments
        for j in range(sides):
            phi = 2 * math.pi * j / sides
            r = major + minor * math.cos(phi)
            if around_x:
                verts.append((cx + minor * math.sin(phi), cy + r * math.cos(theta), cz + r * math.sin(theta)))
            else:
                verts.append((cx + r * math.cos(theta), cy + minor * math.sin(phi), cz + r * math.sin(theta)))
    for i in range(segments):
        for j in range(sides):
            a = i * sides + j
            b = ((i + 1) % segments) * sides + j
            c = ((i + 1) % segments) * sides + (j + 1) % sides
            d = i * sides + (j + 1) % sides
            faces.extend([(a, b, c), (a, c, d)])
    visual_meshes[material].append((verts, faces))
    segment_size = 2.0 * major * math.sin(math.pi / segments) + minor * 0.8
    for i in range(segments):
        theta = 2.0 * math.pi * i / segments
        if around_x:
            ring_center = (cx, cy + major * math.cos(theta), cz + major * math.sin(theta))
            ring_size = (minor * 2.4, segment_size, segment_size)
        else:
            ring_center = (cx + major * math.cos(theta), cy + major * math.sin(theta), cz)
            ring_size = (segment_size, segment_size, minor * 2.4)
        add_collision_box(ring_center, ring_size)


def build():
    for i, (x, y, z, length, width, mat, kind) in enumerate(ROUTE):
        thickness = 80
        box((x, y, z - thickness / 2), (length, width, thickness), mat)
        if kind in ("start", "finish"):
            # Architectural plinths keep the two endpoints on original Map101 metal.
            box((x, y, z - thickness - 10), (length * 0.86, width * 0.86, 20),
                "deep_navy")
        # Front-edge strips and marker bars make the flat runs easier to read.
        stripe_width = 0.88 if kind.startswith("stair") else 0.70
        box((x + length * 0.34, y, z + 3), (16, width * stripe_width, 6), "white")
        if kind == "flat_dash" and i - 1 in (3, 8):
            # Low jump bars add two active obstacles to the otherwise flat sprint.
            box((x + length * 0.12, y, z + 68), (18, width * 0.90, 20), "hazard")
        if kind.startswith("flat") and i % 3 == 0:
            box((x + length * 0.08, y, z + 5), (12, width * 0.60, 4), "hazard")

        # Rails frame the rising sections. Flat sections alternate rail density
        # so the course changes silhouette between the different movement styles.
        add_rails = kind.startswith("stair") or (kind in ("flat_dash", "flat_finish") and i % 2 == 0)
        if add_rails:
            for side in (-1, 1):
                box((x, y + side * (width * 0.5 - 12), z + 38), (length * 0.78, 12, 16),
                    "amber" if i % 4 == 0 else "steel")

        is_checkpoint = i == 0 or kind != ROUTE[i - 1][6] or i == len(ROUTE) - 1
        if is_checkpoint:
            ringmat = "lime" if kind in ("flat_finish", "finish") else "cyan"
            torus((x - length * 0.24, y, z + 190), major=150 if kind != "finish" else 230,
                  minor=20, material=ringmat)
            if kind not in ("start", "finish"):
                for side in (-1, 1):
                    box((x - length * 0.24, y + side * (width * 0.5 + 45), z + 95),
                        (44, 44, 190), "violet")

    # Finish dais and beacon.
    fx, fy, fz, _, _, _, _ = ROUTE[-1]
    box((fx + 180, fy, fz + 60), (150, 150, 120), "amber")
    box((fx + 180, fy, fz + 350), (36, 36, 460), "lime")
    for k in range(4):
        torus((fx + 180, fy, fz + 180 + k * 70), major=80 + k * 15,
              minor=9, material="lime", segments=20, sides=6)

    UNITY.mkdir(parents=True, exist_ok=True)
    SOLID.parent.mkdir(parents=True, exist_ok=True)
    SOLID.write_text(json.dumps({"verts": solid_verts, "tris": solid_tris}, separators=(",", ":")), encoding="utf-8")
    (UNITY / "parkour_layout.json").write_text(json.dumps({
        "name": "Neon Skyrail",
        "coordinate_system": "map1 raw BSP: x forward, y lateral, z up; Unity=(-y,z,x)",
        "spawn": [0, 0, 250],
        "finish": [38970, 0, 2140],
        "platforms": [
            {"forward": x, "lateral": y, "height": z, "length": length, "width": width,
             "material": mat, "style": kind}
            for x, y, z, length, width, mat, kind in ROUTE
        ],
        "collision_boxes": collision_boxes,
        "sections": [
            {"style": "flat_dash", "platforms": 12},
            {"style": "stair_a", "platforms": 16},
            {"style": "flat_zigzag", "platforms": 12},
            {"style": "stair_b", "platforms": 16},
            {"style": "flat_finish", "platforms": 8},
        ],
        "step_dimensions": {"stair_spacing_forward": 520, "stair_rise": 60,
                             "stair_lateral_alternation": 160, "stair_lateral_drift_per_step": 0,
                             "stair_platform_square": 260,
                             "stair_platform_thickness": 80, "map101_reference_thickness": 24,
                             "stair_steps": 32,
                             "flat_platforms": 32, "total_platforms_including_start_finish": len(ROUTE)},
        "clear_gap_rule": "one platform length between successive platforms",
        "solid_file": "../../../../SSJJ-Server/Data/Maps/map3101_solid.json",
    }, indent=2), encoding="utf-8")

    # OBJ uses Unity axes (right, up, forward), so Unity imports it directly.
    obj_path = UNITY / "ParkourCourse.obj"
    mtl_path = UNITY / "ParkourCourse.mtl"
    with mtl_path.open("w", encoding="utf-8", newline="\n") as mtl:
        for name, color in MATERIALS.items():
            mtl.write(f"newmtl {name}\nKa 0.04 0.04 0.04\nKd {color[0]:.4f} {color[1]:.4f} {color[2]:.4f}\nKs 0.15 0.15 0.15\nNs 30\n\n")
            mtl.write(f"map_Kd Textures/{TEXTURES[name]}\n\n")
    with obj_path.open("w", encoding="utf-8", newline="\n") as obj:
        obj.write("# Neon Skyrail parkour course; generated from build_parkour_course.py\nmtllib ParkourCourse.mtl\n")
        offset = 1
        uv_offset = 1
        for material, meshes in visual_meshes.items():
            obj.write(f"o {material}\nusemtl {material}\n")
            for verts, faces in meshes:
                for x, y, z in verts:
                    obj.write(f"v {-y:.3f} {z:.3f} {x:.3f}\n")
                for a, b, c in faces:
                    p0, p1, p2 = verts[a], verts[b], verts[c]
                    ux, uy, uz = p1[0] - p0[0], p1[1] - p0[1], p1[2] - p0[2]
                    vx, vy, vz = p2[0] - p0[0], p2[1] - p0[1], p2[2] - p0[2]
                    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
                    axis = max(range(3), key=lambda axis: abs((nx, ny, nz)[axis]))
                    for p in (p0, p1, p2):
                        if axis == 2: uv = (p[0] / 256.0, p[1] / 256.0)
                        elif axis == 0: uv = (p[1] / 256.0, p[2] / 256.0)
                        else: uv = (p[0] / 256.0, p[2] / 256.0)
                        obj.write(f"vt {uv[0]:.5f} {uv[1]:.5f}\n")
                    v0, v1, v2 = offset + a, offset + b, offset + c
                    t0, t1, t2 = uv_offset, uv_offset + 1, uv_offset + 2
                    # SsjjToUnity=(-lateral, up, forward) is a reflection,
                    # so reverse winding for Unity's front-face convention.
                    obj.write(f"f {v0}/{t0} {v2}/{t2} {v1}/{t1}\n")
                    uv_offset += 3
                offset += len(verts)
    # Unity 2019's OBJ importer can collapse the MTL groups into one default
    # material. Emit one OBJ per visual material so the editor can assign
    # stable scene materials without relying on importer-specific MTL parsing.
    for material, meshes in visual_meshes.items():
        part_path = UNITY / f"ParkourCourse_{material}.obj"
        with part_path.open("w", encoding="utf-8", newline="\n") as obj:
            obj.write(f"# Neon Skyrail visual group: {material}\no {material}\n")
            offset = 1
            uv_offset = 1
            for verts, faces in meshes:
                for x, y, z in verts:
                    obj.write(f"v {-y:.3f} {z:.3f} {x:.3f}\n")
                for a, b, c in faces:
                    p0, p1, p2 = verts[a], verts[b], verts[c]
                    ux, uy, uz = p1[0] - p0[0], p1[1] - p0[1], p1[2] - p0[2]
                    vx, vy, vz = p2[0] - p0[0], p2[1] - p0[1], p2[2] - p0[2]
                    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
                    axis = max(range(3), key=lambda axis: abs((nx, ny, nz)[axis]))
                    for p in (p0, p1, p2):
                        if axis == 2: uv = (p[0] / 256.0, p[1] / 256.0)
                        elif axis == 0: uv = (p[1] / 256.0, p[2] / 256.0)
                        else: uv = (p[0] / 256.0, p[2] / 256.0)
                        obj.write(f"vt {uv[0]:.5f} {uv[1]:.5f}\n")
                    v0, v1, v2 = offset + a, offset + b, offset + c
                    t0, t1, t2 = uv_offset, uv_offset + 1, uv_offset + 2
                    obj.write(f"f {v0}/{t0} {v2}/{t2} {v1}/{t1}\n")
                    uv_offset += 3
                offset += len(verts)
    collision_path = UNITY / "ParkourCollision.obj"
    with collision_path.open("w", encoding="utf-8", newline="\n") as obj:
        obj.write("# Walkable collision geometry, map1_solid compatible\no ParkourCollision\n")
        for x, y, z in solid_verts:
            obj.write(f"v {-y:.3f} {z:.3f} {x:.3f}\n")
        for a, b, c in solid_tris:
            obj.write(f"f {a+1} {c+1} {b+1}\n")
    print(f"Built {len(ROUTE)} platforms, collision {len(solid_tris)} tris, visual OBJ {obj_path}")
    print(f"Collision JSON: {SOLID}")


if __name__ == "__main__":
    build()

