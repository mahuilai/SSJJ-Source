"""Create an editable Blender presentation file and preview from the generated OBJ."""
from pathlib import Path
import bpy
from mathutils import Vector

root = Path(__file__).resolve().parents[2]
asset = root / "Game-SSJJ" / "Assets" / "Parkour"
obj = asset / "ParkourCourse.obj"
blend = asset / "NeonSkyrail.blend"
preview = asset / "NeonSkyrail_preview.png"

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = 1500
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False
scene.render.image_settings.color_mode = "RGBA"
scene.render.filepath = str(preview)
scene.world = bpy.data.worlds.new("Deep-space navy")
scene.world.use_nodes = True
background = scene.world.node_tree.nodes.get("Background")
sky_path = asset / "Textures" / "NeonSkyrail_Skybox.png"
if sky_path.exists():
    sky = bpy.data.images.load(str(sky_path), check_existing=True)
    sky.reload()
    environment = scene.world.node_tree.nodes.new("ShaderNodeTexEnvironment")
    environment.image = sky
    environment.projection = "EQUIRECTANGULAR"
    # Leave Vector unconnected so Blender uses the environment node's default
    # equirectangular direction mapping in the world shader.
    scene.world.node_tree.links.new(environment.outputs["Color"], background.inputs["Color"])
    background.inputs[1].default_value = 0.90
else:
    background.inputs[0].default_value = (0.006, 0.016, 0.045, 1)
    background.inputs[1].default_value = 0.45
scene.view_settings.view_transform = "AgX"

bpy.ops.wm.obj_import(filepath=str(obj), forward_axis="NEGATIVE_Z", up_axis="Y")
course_objects = [o for o in bpy.context.scene.objects if o.type == "MESH"]
for ob in course_objects:
    ob.name = "Skyrail_" + ob.name
    for mat in ob.data.materials:
        if not mat or not mat.use_nodes:
            continue
        bsdf = next((n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
        if not bsdf:
            continue
        for node in mat.node_tree.nodes:
            if node.type == "TEX_IMAGE" and node.image:
                node.image.reload()
        bsdf.inputs["Metallic"].default_value = 0.62
        bsdf.inputs["Roughness"].default_value = 0.28
        if mat.name in {"cyan", "lime", "amber", "violet", "hazard", "white"}:
            color = bsdf.inputs["Base Color"].default_value[:]
            bsdf.inputs["Emission Color"].default_value = color
            bsdf.inputs["Emission Strength"].default_value = 0.06 if mat.name != "white" else 0.02

# Small star points give the floating course a sense of scale without obscuring play geometry.
star_mat = bpy.data.materials.new("Star glints")
star_mat.diffuse_color = (0.32, 0.55, 0.85, 1)
star_mat.use_nodes = True
star_bsdf = star_mat.node_tree.nodes.get("Principled BSDF")
star_bsdf.inputs["Emission Color"].default_value = (0.20, 0.42, 0.85, 1)
star_bsdf.inputs["Emission Strength"].default_value = 1.8
for i in range(95):
    x = ((i * 127) % 6100) - 300
    y = -((i * 271) % 40000) - 350
    z = 250 + ((i * 89) % 5000)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=8 + (i % 4) * 2, location=(x, y, z))
    star = bpy.context.object
    star.name = f"Sky_Glint_{i:03d}"
    star.data.materials.append(star_mat)

def point_at(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()

camera_data = bpy.data.cameras.new("Skyrail hero camera")
camera = bpy.data.objects.new("Skyrail hero camera", camera_data)
scene.collection.objects.link(camera)
camera.location = (8500, -19000, 8500)
point_at(camera, (0, -19500, 1000))
camera_data.type = "ORTHO"
camera_data.ortho_scale = 45000
camera_data.clip_end = 60000
scene.camera = camera

def area_light(name, loc, target, energy, color, size):
    data = bpy.data.lights.new(name, type="AREA")
    data.energy = energy
    data.color = color
    data.shape = "DISK"
    data.size = size
    ob = bpy.data.objects.new(name, data)
    scene.collection.objects.link(ob)
    ob.location = loc
    point_at(ob, target)

area_light("Cool key", (1800, -18000, 6500), (0, -19500, 1000), 650000, (0.30, 0.68, 1.0), 2400)
area_light("Warm rim", (-1200, -30000, 4800), (0, -19500, 1000), 420000, (1.0, 0.30, 0.09), 1800)
area_light("Finish glow", (600, -38500, 4200), (0, -38970, 2140), 320000, (0.22, 1.0, 0.45), 1400)

scene.render.image_settings.color_mode = "RGBA"
scene.render.filepath = str(preview)
bpy.ops.wm.save_as_mainfile(filepath=str(blend))
bpy.ops.render.render(write_still=True)
print(f"Saved {blend} and {preview}; mesh objects={len(course_objects)}")
