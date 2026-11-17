#!/usr/bin/env python3
"""Build map3102 BSP and server triangle collision from one Luminara layout."""
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROJECT = ROOT / 'Game-SSJJ'
ASSET = PROJECT / 'Assets' / 'Luminara'
LAYOUT = ASSET / 'luminara_map_layout.json'
OUTPUT = ASSET / 'MapData' / 'model.bsp.raw.bytes'
SERVER_SOLID = ROOT / 'SSJJ-Server' / 'Data' / 'Maps' / 'map3102_solid.json'
MAP_ID = 3102

spec = importlib.util.spec_from_file_location('ssjj_bsp', Path(__file__).with_name('build_parkour_bsp.py'))
bsp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bsp)

def server_box_mesh(box):
    center = [float(v) for v in box['center']]
    size = [float(v) for v in box['size']]
    half = [v * 0.5 for v in size]
    x, y, z = center
    hx, hy, hz = half
    verts = [
        [x-hx,y-hy,z-hz], [x+hx,y-hy,z-hz], [x+hx,y+hy,z-hz], [x-hx,y+hy,z-hz],
        [x-hx,y-hy,z+hz], [x+hx,y-hy,z+hz], [x+hx,y+hy,z+hz], [x-hx,y+hy,z+hz],
    ]
    # Twelve triangles, same 8-vertex box representation as map3101_solid.json.
    tris = [[0,2,1],[0,3,2],[4,5,6],[4,6,7],
            [0,1,5],[0,5,4],[1,2,6],[1,6,5],
            [2,3,7],[2,7,6],[3,0,4],[3,4,7]]
    return verts, tris

def main():
    layout = json.loads(LAYOUT.read_text(encoding='utf-8'))
    hull_map = {entry['object']: entry.get('pieces', []) for entry in layout.get('collision_hulls', [])}
    boxes = []
    hull_planes = []
    for item in layout['collision_boxes']:
        pieces = hull_map.get(item['object'], [])
        if not pieces:
            pieces = [{'center': item['center'], 'size': item['size'], 'planes': []}]
        for piece in pieces:
            center = tuple(float(v) for v in piece['center'])
            size = tuple(float(v) for v in piece['size'])
            planes = [(tuple(float(v) for v in plane[:3]), float(plane[3]))
                      for plane in piece.get('planes', [])]
            boxes.append((center, size, 0.0))
            hull_planes.append(planes)
    bsp.SPAWN = tuple(float(v) for v in layout['spawn'])
    data = bsp.make_bsp(boxes, hull_planes=hull_planes)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_bytes(data)
    verts, tris = [], []
    for item in layout['collision_boxes']:
        pieces = hull_map.get(item['object'], [])
        if not pieces:
            pieces = [{'center': item['center'], 'size': item['size']}]
        for piece in pieces:
            bv, bt = server_box_mesh(piece)
            base = len(verts)
            verts.extend(bv)
            tris.extend([[base + i for i in tri] for tri in bt])
    SERVER_SOLID.parent.mkdir(parents=True, exist_ok=True)
    SERVER_SOLID.write_text(json.dumps({'verts': verts, 'tris': tris}, separators=(',', ':')), encoding='utf-8')
    print(json.dumps({'map_id': MAP_ID, 'bsp': str(OUTPUT), 'bsp_bytes': len(data),
                      'bsp_brushes': len(boxes),
                      'bsp_sides': sum(6 + len(planes) for planes in hull_planes),
                      'convex_hull_meshes': sum(bool(planes) for planes in hull_planes),
                      'source_meshes': len(layout['collision_boxes']),
                      'split_architecture_brushes': sum(len(hull_map.get(item['object'], [])) for item in layout['collision_boxes']
                                                        if '_Building' in item['object'] or '_Entrance' in item['object']),
                      'spawn': layout['spawn'],
                      'server_solid': str(SERVER_SOLID), 'server_vertices': len(verts),
                      'server_triangles': len(tris)}, ensure_ascii=False))

if __name__ == '__main__':
    main()
