import bpy, math
from mathutils import Vector
s=bpy.data.scenes['KB3D_SecretsOfTheLuminara-Native']
bpy.context.window.scene=s
# Calculate bounds of all mesh geometry, omitting hidden and tiny helper objects
objs=[o for o in s.objects if o.type=='MESH' and o.visible_get()]
pts=[]
for o in objs:
    for c in o.bound_box: pts.append(o.matrix_world @ Vector(c))
mn=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)))
mx=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)))
center=(mn+mx)/2
# Temporary oblique overview camera
camd=bpy.data.cameras.new('CodexOverviewCamera'); cam=bpy.data.objects.new('CodexOverviewCamera',camd); s.collection.objects.link(cam)
cam.location=center+Vector((400,-560,720)); target=center; cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler(); camd.type='ORTHO'; camd.ortho_scale=590; s.camera=cam
s.render.engine='BLENDER_WORKBENCH'; s.render.resolution_x=1500; s.render.resolution_y=950; s.render.resolution_percentage=100
s.render.image_settings.file_format='PNG'; s.render.filepath=r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\shots\luminara_overview.png'
s.display.shading.light='STUDIO'; s.display.shading.color_type='RANDOM'; s.display.shading.background_type='WORLD'; s.display.shading.show_shadows=True; s.display.shading.show_cavity=True# Report recognizable scene pieces and their world dimensions
items=[]
for o in objs:
 n=o.name.lower()
 if any(k in n for k in ('bridge','floor','stairs','steps','aqueduct','platform','doorway','colonnade','temple','ruin','archway','pillar','pilar')):
  d=o.dimensions
  items.append((o.name,tuple(round(v,2) for v in (o.location.x,o.location.y,o.location.z)),tuple(round(v,2) for v in (d.x,d.y,d.z)),[m.name if m else '' for m in o.data.materials[:2]]))
print('BOUNDS',tuple(mn),tuple(mx),'MESHES',len(objs),'CANDIDATES',len(items))
for x in items[:160]: print('CANDIDATE',x)



bpy.ops.render.render(write_still=True)
