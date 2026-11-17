#!/usr/bin/env python3
"""Build the version-1 SSJJ/Q3 BSP collision map for Neon Skyrail.

The game expects a BSPClipMap even when its visible map is an additive Unity
scene. This file contains every visible cuboid and ring-segment collider,
no render surfaces, and CT/T spawn entities. Geometry stays in SSJJ raw axes
(forward, lateral, up); the separate Unity scene uses (-lateral, up, forward).
"""
from __future__ import annotations

import json
import math
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PARKOUR = ROOT / "Game-SSJJ" / "Assets" / "Parkour"
LAYOUT = PARKOUR / "parkour_layout.json"
OUTPUT = PARKOUR / "MapData" / "model.bsp.raw.bytes"
MAP_ID = 3101
SPAWN = (0.0, 0.0, 250.0)


def make_boxes(layout: dict) -> list[tuple[tuple[float, float, float], tuple[float, float, float], float]]:
    boxes = []
    for item in layout.get("collision_boxes", []):
        center = tuple(float(v) for v in item["center"])
        size = tuple(float(v) for v in item["size"])
        yaw = float(item.get("yaw", 0.0))
        boxes.append((center, size, yaw))
    if not boxes:
        raise ValueError("Layout has no collision_boxes; regenerate it with build_parkour_course.py")
    return boxes


def encode_entities() -> bytes:
    x, y, z = SPAWN
    text = (
        '{\n"classname" "worldspawn" "gridsize" "100 100 100" "ambient" "0"\n}\n'
        # Keep this non-zero: the offline spawner treats a zero yaw as missing
        # and falls back to 180 degrees, which points back toward the start pad.
        '{\n"classname" "info_player_start_CT" "origin" "%.3f %.3f %.3f" "yaw" "1"\n}\n'
        '{\n"classname" "info_player_start_T" "origin" "%.3f %.3f %.3f" "yaw" "1"\n}\n'
    ) % (x, y, z, x, y, z)
    return text.encode("latin-1") + b"\0"


def make_bsp(
    boxes: list[tuple[tuple[float, float, float], tuple[float, float, float], float]],
    hull_planes: list[list[tuple[tuple[float, float, float], float]]] | None = None,
) -> bytes:
    # BSP shader: surfaceFlags=0, contentFlags=CONTENTS_SOLID.
    shader = b"textures/common/solid\0".ljust(64, b"\0") + struct.pack("<ii", 0, 1)
    planes: list[tuple[float, float, float, float]] = []
    sides: list[tuple[int, int]] = []
    brushes: list[tuple[int, int, int]] = []
    mins = [math.inf, math.inf, math.inf]
    maxs = [-math.inf, -math.inf, -math.inf]

    for box_index, (center, size, yaw) in enumerate(boxes):
        half = [value / 2.0 for value in size]
        c, s = math.cos(yaw), math.sin(yaw)
        axes = [(c, s, 0.0), (-s, c, 0.0), (0.0, 0.0, 1.0)]
        extents = [sum(abs(axes[j][a]) * half[j] for j in range(3)) for a in range(3)]
        lo = [center[a] - extents[a] for a in range(3)]
        hi = [center[a] + extents[a] for a in range(3)]
        for axis in range(3):
            mins[axis] = min(mins[axis], lo[axis])
            maxs[axis] = max(maxs[axis], hi[axis])
        first_side = len(sides)
        for axis, normal in enumerate(axes):
            negative = tuple(-v for v in normal)
            negative_dist = sum(negative[a] * center[a] for a in range(3)) + half[axis]
            planes.append((negative[0], negative[1], negative[2], negative_dist))
            sides.append((len(planes) - 1, 0))
            positive_dist = sum(normal[a] * center[a] for a in range(3)) + half[axis]
            planes.append((normal[0], normal[1], normal[2], positive_dist))
            sides.append((len(planes) - 1, 0))
        # The client trace accepts any convex brush planes. Luminara meshes use
        # an AABB only as a broadphase bound (the first six paired axis planes);
        # their convex-hull support planes below provide the actual shape.
        if hull_planes is not None and box_index < len(hull_planes):
            for normal, dist in hull_planes[box_index]:
                planes.append((float(normal[0]), float(normal[1]), float(normal[2]), float(dist)))
                sides.append((len(planes) - 1, 0))
        brushes.append((first_side, 6, 0))
        if hull_planes is not None and box_index < len(hull_planes):
            brushes[-1] = (first_side, 6 + len(hull_planes[box_index]), 0)

    if not boxes:
        raise ValueError("No collision boxes were generated")

    # Bounds contain a safety margin for player hull traces around the course.
    leaf_bounds_min = [math.floor(mins[a] - 512.0) for a in range(3)]
    leaf_bounds_max = [math.ceil(maxs[a] + 512.0) for a in range(3)]
    model = struct.pack("<6f4i", *leaf_bounds_min, *leaf_bounds_max, 0, 0, 0, len(boxes))
    leaf = struct.pack(
        "<12i",
        0, 0,
        *leaf_bounds_min, *leaf_bounds_max,
        0, 0, 0, len(boxes),
    )
    split_plane = len(planes)
    planes.append((1.0, 0.0, 0.0, 0.0))
    node = struct.pack("<9i", split_plane, -1, -2,
                       *leaf_bounds_min, *leaf_bounds_max)

    lumps = [
        encode_entities(),
        shader,
        b"".join(struct.pack("<4f", *p) for p in planes),
        node,
        leaf + leaf,
        b"",  # leaf surfaces
        b"".join(struct.pack("<i", i) for i in range(len(boxes))),
        model,
        b"".join(struct.pack("<3i", *brush) for brush in brushes),
        b"".join(struct.pack("<2i", *side) for side in sides),
        b"",  # draw vertices
        b"",  # draw indices
        b"",  # effects
        b"",  # surfaces
        b"",  # lightmaps
        b"",  # lightgrid (Q3 version)
        b"",  # visibility
        struct.pack("<i", 0),  # Unity BSP vertex-block count
        # Unity light grid: size, max[3], min[3], dataCount. Zero-sized bounds
        # make the parser accept an empty grid without allocating cells.
        struct.pack("<7iI", 100, -1, -1, -1, 0, 0, 0, 0),
    ]

    header_size = 8 + len(lumps) * 8
    out = bytearray(struct.pack("<ii", 0x50534249, 1))
    offset = header_size
    for lump in lumps:
        out.extend(struct.pack("<ii", offset, len(lump)))
        offset += len(lump)
    for lump in lumps:
        out.extend(lump)
    return bytes(out)


def main() -> None:
    layout = json.loads(LAYOUT.read_text(encoding="utf-8"))
    boxes = make_boxes(layout)
    data = make_bsp(boxes)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_bytes(data)
    print(f"[parkour-bsp] map{MAP_ID}: brushes={len(boxes)} bytes={len(data)} -> {OUTPUT}")
    print("[parkour-bsp] spawn raw=", SPAWN, "world bounds=", len(boxes), "solid brushes")


if __name__ == "__main__":
    main()
