import bpy, json, os
from mathutils import Vector
scenes=[]
for s in bpy.data.scenes:
    objects=list(s.objects)
    meshes=[o for o in objects if o.type=='MESH']
    mins=[float('inf')]*3; maxs=[float('-inf')]*3
    for o in meshes:
        try:
            for c in o.bound_box:
                p=o.matrix_world @ Vector(c)
                for i in range(3): mins[i]=min(mins[i],p[i]); maxs[i]=max(maxs[i],p[i])
        except: pass
    scenes.append({'name':s.name,'objects':len(objects),'meshes':len(meshes),'cameras':sum(o.type=='CAMERA' for o in objects),'lights':sum(o.type=='LIGHT' for o in objects),'bbox_min':mins if meshes else None,'bbox_max':maxs if meshes else None,'sample':[o.name for o in objects[:70]]})
cols=[]
def walk(c,depth=0):
    children=[]
    for x in c.children:
        children.append({'name':x.name,'objects':len(x.objects),'children':len(x.children)})
    cols.append({'name':c.name,'depth':depth,'objects':len(c.objects),'children':children[:25]})
    for x in c.children: walk(x,depth+1)
for s in bpy.data.scenes:
    for c in s.collection.children: walk(c)
result={'file':bpy.data.filepath,'scenes':scenes,'collections':cols[:100],'meshes_datablocks':len(bpy.data.meshes),'materials':len(bpy.data.materials),'images':len(bpy.data.images),'images_sample':[{'name':i.name,'filepath':i.filepath,'packed':bool(i.packed_file)} for i in list(bpy.data.images)[:30] if i]}
print('LUMINARA_SUMMARY_JSON='+json.dumps(result,ensure_ascii=False))
