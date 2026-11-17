#!/usr/bin/env python3
"""Assemble a playable SSJJ map from the supplied KitBash3D Luminara scene."""
import bpy
import json
import math
import shutil
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
PROJECT = ROOT / 'Game-SSJJ'
SOURCE = Path(r'D:\3D资产\KitBash3D - Secrets Of The Luminara\blender\kb3d_secretsoftheluminara-native.blend')
SOURCE_TEXTURES = Path(r'D:\3D资产\KitBash3D - Secrets Of The Luminara\2K texture')
ASSET = PROJECT / 'Assets' / 'Luminara'
MODEL_DIR = ASSET / 'Models'
TEXTURE_DIR = ASSET / 'Textures'
MATERIAL_DIR = ASSET / 'Materials'
SOURCE_DIR = ASSET / 'Source'
LAYOUT_PATH = ASSET / 'luminara_map_layout.json'
TEXTURE_MAP_PATH = ASSET / 'material_texture_manifest.json'
FBX_PATH = MODEL_DIR / 'LuminaraCourse.fbx'
BLEND_PATH = SOURCE_DIR / 'LuminaraMap3102.blend'
PREVIEW_PATH = ROOT / 'Game-SSJJ' / 'shots' / 'luminara_map_overview.png'
MAP_ID = 3102

for d in (MODEL_DIR, TEXTURE_DIR, MATERIAL_DIR, SOURCE_DIR, PREVIEW_PATH.parent):
    d.mkdir(parents=True, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene = bpy.data.scenes['KB3D_SecretsOfTheLuminara-Native']
bpy.context.window.scene = scene
bpy.context.view_layer.objects.active = None

def root_of(obj):
    while obj.parent is not None:
        obj = obj.parent
    return obj

def bounds(obj):
    pts = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    return tuple(min(p[i] for p in pts) for i in range(3)), tuple(max(p[i] for p in pts) for i in range(3))

def find_mesh(name):
    obj = bpy.data.objects.get(name)
    if obj is None or obj.type != 'MESH':
        raise RuntimeError('Required source mesh is missing: ' + name)
    return obj

# Read ground boundaries before moving the modular island sets.
letters = ('A', 'C', 'D', 'B', 'E')
grounds = {letter: find_mesh('KB3D_SOL_BldgTemple_' + letter + '_Ground') for letter in letters}
ground_bounds = {letter: bounds(obj) for letter, obj in grounds.items()}
roots = {letter: bpy.data.objects['KB3D_SOL_BldgTemple_' + letter + '_grp'] for letter in letters}
e_root = roots['E']
e_x, e_y = float(e_root.location.x), float(e_root.location.y)
e_center_height = float(e_root.location.z)

# Retain the five complete temple islands, the fantasy airship, and a finish portal.
keep_roots = set(roots.values())
for name in ('KB3D_SOL_VehicBlimpShip_A_grp', 'KB3D_SOL_PropPortal_A_grp'):
    obj = bpy.data.objects.get(name)
    if obj is not None:
        keep_roots.add(obj)
for obj in list(scene.objects):
    if root_of(obj) not in keep_roots:
        bpy.data.objects.remove(obj, do_unlink=True)

# Rotate the source asset garden so Temple E -> C -> A runs along SSJJ forward.
for letter, group in roots.items():
    old_x, old_y, old_z = float(group.location.x), float(group.location.y), float(group.location.z)
    group.location = (old_y - e_y, -(old_x - e_x), old_z - e_center_height)
    group.rotation_euler.z = float(group.rotation_euler.z) - math.pi / 2.0

# Place the ship overhead as a visible landmark, then move the finish portal to Temple A.
ship = bpy.data.objects.get('KB3D_SOL_VehicBlimpShip_A_grp')
if ship is not None:
    ship.location = (-34.0, -148.0, 37.0)
    ship.rotation_euler.z -= math.pi / 2.0
portal = bpy.data.objects.get('KB3D_SOL_PropPortal_A_grp')
finish_forward = float((ground_bounds['A'][0][0] + ground_bounds['A'][1][0]) * 0.5 - e_x)
if portal is not None:
    portal.location = (0.0, -finish_forward, 0.0)
    portal.rotation_euler.z -= math.pi / 2.0

bpy.context.view_layer.update()

# Relink only textures used by the retained models, using the supplied 2K set.
used_materials = set()
for obj in scene.objects:
    if obj.type == 'MESH' and not obj.hide_render:
        used_materials.update(m for m in obj.data.materials if m is not None)
texture_manifest = {}
used_images = set()
allowed_maps = {'basecolor', 'normal', 'roughness', 'metallic', 'ao', 'opacity', 'emissive', 'height'}
for material in sorted(used_materials, key=lambda m: m.name):
    entry = {}
    if material.use_nodes and material.node_tree:
        for node in material.node_tree.nodes:
            if node.type != 'TEX_IMAGE' or node.image is None:
                continue
            image = node.image
            filename = Path(bpy.path.abspath(image.filepath)).name or image.name
            stem = Path(filename).stem
            suffix = stem.rsplit('_', 1)[-1].lower() if '_' in stem else ''
            if suffix not in allowed_maps:
                continue
            source_path = SOURCE_TEXTURES / filename
            if not source_path.exists():
                continue
            target_path = TEXTURE_DIR / filename
            if not target_path.exists() or target_path.stat().st_size != source_path.stat().st_size:
                shutil.copy2(source_path, target_path)
            image.filepath = str(target_path)
            try:
                image.reload()
            except Exception:
                pass
            used_images.add(image)
            entry[suffix] = filename
    texture_manifest[material.name] = entry
TEXTURE_MAP_PATH.write_text(json.dumps(texture_manifest, indent=2, ensure_ascii=False), encoding='utf-8')

stone = bpy.data.materials.get('KB3D_SOL_AncientBigBoulderFloor') or bpy.data.materials.get('KB3D_SOL_BrickworkAncientA')
if stone is None:
    raise RuntimeError('Could not find a Luminara stone material for the parkour slabs')

def make_stone(name, center_x, center_y, top_z, width, length, thickness, inset=0.0):
    bx, by, bz = center_x, center_y, top_z - thickness
    iw = min(inset, width * 0.22)
    il = min(inset, length * 0.22)
    verts = [
        (bx-width/2, by-length/2, bz), (bx+width/2, by-length/2, bz),
        (bx+width/2, by+length/2, bz), (bx-width/2, by+length/2, bz),
        (bx-width/2+iw, by-length/2+il, top_z), (bx+width/2-iw, by-length/2+il, top_z),
        (bx+width/2-iw, by+length/2-il, top_z), (bx-width/2+iw, by+length/2-il, top_z),
    ]
    faces = [(0,3,2,1), (4,5,6,7), (0,1,5,4), (1,2,6,5), (2,3,7,6), (3,0,4,7)]
    mesh = bpy.data.meshes.new(name + '_Mesh')
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    uv_layer = mesh.uv_layers.new(name='LuminaraStoneUV')
    for poly in mesh.polygons:
        n = poly.normal
        for li in poly.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            if abs(n.z) >= max(abs(n.x), abs(n.y)):
                uv = (co.x / 4.0, co.y / 4.0)
            elif abs(n.x) >= abs(n.y):
                uv = (co.y / 4.0, co.z / 4.0)
            else:
                uv = (co.x / 4.0, co.z / 4.0)
            uv_layer.data[li].uv = uv
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    obj.data.materials.append(stone)
    obj['map3102_collision'] = 'BSP brush + Unity MeshCollider'
    return obj

# Join the three primary islands with a readable mix of flat and tapered stepping stones.
route = []
sections = []
for section_index, (start_letter, end_letter) in enumerate((('E', 'C'), ('C', 'A'))):
    start_min, start_max = ground_bounds[start_letter]
    end_min, end_max = ground_bounds[end_letter]
    start_x, end_x = float(start_max[0]), float(end_min[0])
    if end_x <= start_x:
        raise RuntimeError('Temple route order is not left-to-right: ' + start_letter + ' -> ' + end_letter)
    route_y = (float((start_min[1] + start_max[1]) * 0.5) + float((end_min[1] + end_max[1]) * 0.5)) * 0.5
    first_x, last_x = start_x - 1.5, end_x + 1.5
    distance = last_x - first_x
    count = max(2, int(math.ceil(distance / 8.0)) + 1)
    start_top = float(start_max[2]) + 0.25
    end_top = float(end_max[2]) + 0.25
    section_items = []
    for i in range(count):
        t = i / float(count - 1)
        source_x = first_x + distance * t
        map_x = route_y - e_y
        map_y = -(source_x - e_x)
        top = start_top + (end_top - start_top) * t + 0.35 * math.sin(math.pi * t)
        is_trapezoid = (i % 4 == 2) or (section_index == 1 and i % 5 == 4)
        width = 5.2 if i % 3 == 1 else 6.0
        length = 4.0
        kind = 'trapezoid' if is_trapezoid else 'flat'
        inset = 0.42 if is_trapezoid else 0.08
        name = 'Luminara_' + start_letter + '_to_' + end_letter + '_' + str(i + 1).zfill(2) + '_' + kind
        obj = make_stone(name, map_x, map_y, top, width, length, 0.85, inset)
        route.append({'object': name, 'section': start_letter + '_to_' + end_letter, 'style': kind,
                      'forward': round((source_x - e_x) * 100.0, 2),
                      'lateral': round(-(route_y - e_y) * 100.0, 2),
                      'height': round(top * 100.0, 2),
                      'length': round(length * 100.0, 2), 'width': round(width * 100.0, 2)})
        section_items.append(name)
    sections.append({'name': start_letter + '_to_' + end_letter, 'platform_count': count,
                     'styles': ['flat', 'trapezoid'], 'objects': section_items,
                     'approx_distance_m': round(distance, 2)})

# Put a small run-up slab at the edge of the start island; it overlaps the terrain intentionally.
start_ground_min, start_ground_max = ground_bounds['E']
spawn_x = e_x
spawn_y = e_y
start_landing = make_stone('Luminara_Start_Landing', 0.0, 1.0, float(start_ground_max[2]) + 0.25, 8.0, 8.0, 0.9, 0.10)
finish_ground_min, finish_ground_max = ground_bounds['A']
finish_y = -(float((finish_ground_min[0] + finish_ground_max[0]) * 0.5) - e_x)
finish_pad = make_stone('Luminara_Finish_Landing', 0.0, finish_y, float(finish_ground_max[2]) + 0.25, 10.0, 10.0, 0.9, 0.12)

bpy.context.view_layer.update()

# Export a texture-relinked, FBX-ready scene and derive the two collision formats from its meshes.
mesh_objects = [o for o in scene.objects if o.type == 'MESH' and not o.hide_render]
collision_boxes = []
for obj in mesh_objects:
    lo, hi = bounds(obj)
    size_bl = [max(float(hi[i] - lo[i]), 0.02) for i in range(3)]
    center_bl = [(float(hi[i]) + float(lo[i])) * 0.5 for i in range(3)]
    center_raw = [-center_bl[1] * 100.0, -center_bl[0] * 100.0, center_bl[2] * 100.0]
    size_raw = [size_bl[1] * 100.0, size_bl[0] * 100.0, size_bl[2] * 100.0]
    collision_boxes.append({'object': obj.name, 'center': [round(v, 3) for v in center_raw],
                            'size': [round(max(v, 2.0), 3) for v in size_raw], 'yaw': 0.0})

# Temple E's central rubble AABBs sit well above the walkable ground. Spawn on
# the west stair approach, close to the first parkour slab and clear of roofs.
spawn = [2800.0, -600.0, 300.0]
finish = [round(finish_forward * 100.0, 2), 0.0, round((float(finish_ground_max[2]) + 2.0) * 100.0, 2)]
layout = {
    'name': 'Luminara Sky Ruins', 'map_id': MAP_ID,
    'coordinate_system': 'SSJJ raw (forward,lateral,height) in cm; Blender source is mapped to Unity (-lateral,height,forward)',
    'source_asset': str(SOURCE), 'units': 'meters in Blender, centimeters in BSP/config',
    'spawn': spawn, 'finish': finish,
    'route': route, 'sections': sections,
    'collision_boxes': collision_boxes,
    'mesh_collider_count': len(mesh_objects),
    'collision_note': 'Run build_luminara_collision_hulls.py after this scene build; every visible mesh receives a Unity MeshCollider and a compact BSP convex proxy.'
}
LAYOUT_PATH.write_text(json.dumps(layout, indent=2, ensure_ascii=False), encoding='utf-8')

# Select visible meshes only, keeping FBX transforms in meters and converting Blender Z-up to Unity Y-up.
bpy.ops.object.select_all(action='DESELECT')
for obj in mesh_objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = mesh_objects[0]
bpy.ops.export_scene.fbx(filepath=str(FBX_PATH), use_selection=True, object_types={'MESH'},
                         global_scale=1.0, apply_unit_scale=True, use_space_transform=True,
                         bake_space_transform=False, use_mesh_modifiers=True, use_tspace=True,
                         path_mode='RELATIVE', embed_textures=False, axis_forward='-Z', axis_up='Y')

# Save a compact editable Blender deliverable with its camera and a clear overview rendering.
bpy.ops.object.select_all(action='DESELECT')
for obj in mesh_objects:
    obj.select_set(True)
# Add an overview camera and one warm key light for Blender preview; neither is included in the FBX.
cam_data = bpy.data.cameras.new('Luminara_OverviewCamera')
cam = bpy.data.objects.new('Luminara_OverviewCamera', cam_data)
scene.collection.objects.link(cam)
cam.location = (90.0, -160.0, 250.0)
target = Vector((0.0, -145.0, 3.0))
cam.rotation_euler = (target - cam.location).to_track_quat('-Z', 'Y').to_euler()
cam_data.type = 'ORTHO'; cam_data.ortho_scale = 430.0; scene.camera = cam
light_data = bpy.data.lights.new('Luminara_Warm_Sun', 'AREA')
light = bpy.data.objects.new('Luminara_Warm_Sun', light_data)
scene.collection.objects.link(light)
light.location = (15.0, -80.0, 180.0); light_data.energy = 120000; light_data.shape = 'DISK'; light_data.size = 95.0
scene.render.engine = 'BLENDER_WORKBENCH'
scene.render.resolution_x = 1400; scene.render.resolution_y = 900; scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'; scene.render.filepath = str(PREVIEW_PATH)
scene.display.shading.light = 'STUDIO'; scene.display.shading.color_type = 'MATERIAL'
scene.display.shading.background_type = 'WORLD'; scene.display.shading.show_shadows = True; scene.display.shading.show_cavity = True
scene.render.film_transparent = False
scene.world = scene.world or bpy.data.worlds.new('Luminara_OverviewWorld')
scene.world.color = (0.035, 0.055, 0.10)
# Leave the scene cleanly editable without all unrelated library objects and image datablocks.
try:
    while bpy.data.orphans_purge(do_recursive=True):
        pass
except Exception:
    pass
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH), compress=True)
bpy.ops.render.render(write_still=True)
print('LUMINARA_BUILD=' + json.dumps({'fbx': str(FBX_PATH), 'blend': str(BLEND_PATH),
      'layout': str(LAYOUT_PATH), 'preview': str(PREVIEW_PATH), 'meshes': len(mesh_objects),
      'bsp_brushes': len(collision_boxes), 'sections': sections, 'spawn': spawn, 'finish': finish,
      'textures': sum(len(v) for v in texture_manifest.values()), 'materials': len(used_materials)}, ensure_ascii=False))
