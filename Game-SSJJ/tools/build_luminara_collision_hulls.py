#!/usr/bin/env python3
"""Export convex BSP collision planes from every visible mesh in LuminaraMap3102.blend."""
import bpy
import json
from mathutils import Vector
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROJECT = ROOT / 'Game-SSJJ'
ASSET = PROJECT / 'Assets' / 'Luminara'
BLEND = ASSET / 'Source' / 'LuminaraMap3102.blend'
LAYOUT_PATH = ASSET / 'luminara_map_layout.json'

bpy.ops.wm.open_mainfile(filepath=str(BLEND))
layout = json.loads(LAYOUT_PATH.read_text(encoding='utf-8'))
depsgraph = bpy.context.evaluated_depsgraph_get()

def to_raw(world_point):
    return Vector((-world_point.y * 100.0, -world_point.x * 100.0, world_point.z * 100.0))

def support_directions():
    directions = []
    for axis in range(3):
        for sign in (-1.0, 1.0):
            value = [0.0, 0.0, 0.0]
            value[axis] = sign
            directions.append(Vector(value))
    for zero_axis in range(3):
        axes = [axis for axis in range(3) if axis != zero_axis]
        for a in (-1.0, 1.0):
            for b in (-1.0, 1.0):
                value = [0.0, 0.0, 0.0]
                value[axes[0]] = a
                value[axes[1]] = b
                directions.append(Vector(value).normalized())
    for x in (-1.0, 1.0):
        for y in (-1.0, 1.0):
            for z in (-1.0, 1.0):
                directions.append(Vector((x, y, z)).normalized())
    return directions

DIRECTIONS = support_directions()

def hull_piece(points):
    if len(points) < 4:
        return None
    mins = [min(float(p[a]) for p in points) for a in range(3)]
    maxs = [max(float(p[a]) for p in points) for a in range(3)]
    return {
        'center': [round((mins[a] + maxs[a]) * 0.5, 3) for a in range(3)],
        'size': [round(maxs[a] - mins[a], 3) for a in range(3)],
        'planes': [
            [round(float(n.x), 8), round(float(n.y), 8), round(float(n.z), 8),
             round(float(max(n.dot(point) for point in points)), 3)]
            for n in DIRECTIONS
        ],
    }


def connected_collision_pieces(obj):
    evaluated = obj.evaluated_get(depsgraph)
    mesh = evaluated.to_mesh(preserve_all_data_layers=False, depsgraph=depsgraph)
    try:
        points = [to_raw(evaluated.matrix_world @ vertex.co) for vertex in mesh.vertices]
        if len(points) < 4:
            return []

        # The combined building meshes are highly disconnected: each doorway,
        # wall section, pillar, and architectural detail is a separate mesh
        # island. One convex hull around the whole object seals every opening.
        # Split only those building/entrance assets into their substantial
        # connected pieces; leave rubble, floors, stairs, and parkour slabs as
        # their existing whole-mesh proxies to keep collision counts bounded.
        split_architecture = '_Building' in obj.name or '_Entrance' in obj.name
        if not split_architecture:
            piece = hull_piece(points)
            return [piece] if piece else []

        parent = list(range(len(points)))
        rank = [1] * len(points)

        def find(index):
            while parent[index] != index:
                parent[index] = parent[parent[index]]
                index = parent[index]
            return index

        for edge in mesh.edges:
            a, b = int(edge.vertices[0]), int(edge.vertices[1])
            ra, rb = find(a), find(b)
            if ra == rb:
                continue
            if rank[ra] < rank[rb]:
                ra, rb = rb, ra
            parent[rb] = ra
            rank[ra] += rank[rb]

        # Ignore tiny masonry/detail islands so decorative polygons do not
        # turn the entire structure into a dense forest of tiny BSP brushes.
        face_counts = {}
        for polygon in mesh.polygons:
            if polygon.vertices:
                root = find(int(polygon.vertices[0]))
                face_counts[root] = face_counts.get(root, 0) + 1
        selected_roots = {root for root, count in face_counts.items() if count >= 60}
        component_points = {root: [] for root in selected_roots}
        for index, point in enumerate(points):
            root = find(index)
            if root in component_points:
                component_points[root].append(point)

        pieces = []
        for root in selected_roots:
            piece = hull_piece(component_points[root])
            if piece and all(value > 0.01 for value in piece['size']):
                pieces.append(piece)
        return pieces
    finally:
        evaluated.to_mesh_clear()

hulls = []
side_count = 0
fallback = []
for item in layout.get('collision_boxes', []):
    obj = bpy.data.objects.get(item['object'])
    pieces = connected_collision_pieces(obj) if obj is not None and obj.type == 'MESH' else []
    if not pieces:
        fallback.append(item['object'])
        center = [float(v) for v in item['center']]
        size = [float(v) for v in item['size']]
        half = [v * 0.5 for v in size]
        x, y, z = center
        hx, hy, hz = half
        points = [Vector((x + sx * hx, y + sy * hy, z + sz * hz))
                  for sx in (-1, 1) for sy in (-1, 1) for sz in (-1, 1)]
        pieces = [hull_piece(points)]
    side_count += sum(len(piece['planes']) for piece in pieces)
    hulls.append({'object': item['object'], 'pieces': pieces})

layout['collision_hulls'] = hulls
layout['collision_note'] = (
    'Every visible mesh has a Unity MeshCollider. Building and entrance meshes use one BSP convex brush per substantial connected mesh island, preserving doorways and architectural gaps; other objects use one evaluated-mesh convex proxy. '
    'Each BSP brush has axis-aligned broadphase bounds plus 26 support planes.'
)
LAYOUT_PATH.write_text(json.dumps(layout, indent=2, ensure_ascii=False), encoding='utf-8')

def vertical_hits(forward, lateral):
    hits = []
    for hull in hulls:
        for piece in hull['pieces']:
            low, high = -float('inf'), float('inf')
            outside = False
            for nx, ny, nz, dist in piece['planes']:
                base = nx * forward + ny * lateral
                if abs(nz) < 1e-8:
                    if base > dist + 0.05:
                        outside = True
                        break
                else:
                    z = (dist - base) / nz
                    if nz > 0.0:
                        high = min(high, z)
                    else:
                        low = max(low, z)
            if not outside and low <= high + 0.05:
                hits.append((high, hull['object']))
    return sorted(hits, reverse=True)

samples = [(-100, 0), (0, 0), (1600, -70), (2000, -70), (2200, -70),
           (2400, -70), (2600, -70), (2800, -70), (3000, -70)]
print(json.dumps({
    'objects': len(hulls), 'hull_planes': side_count,
    'bsp_pieces': sum(len(item['pieces']) for item in hulls),
    'split_architecture_pieces': sum(len(item['pieces']) for item in hulls if '_Building' in item['object'] or '_Entrance' in item['object']),
    'fallback_aabb_objects': fallback,
    'sample_tops': {f'{f},{l}': vertical_hits(f, l)[:4] for f, l in samples},
}, ensure_ascii=False))
