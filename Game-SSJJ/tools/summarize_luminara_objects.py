import bpy,json,collections
s=bpy.data.scenes['KB3D_SecretsOfTheLuminara-Native']
mesh=[o for o in s.objects if o.type=='MESH']
c=collections.Counter('_'.join(o.name.split('_')[:4]) for o in mesh)
print('GROUPS='+json.dumps(c.most_common(),ensure_ascii=False))
for o in sorted(mesh,key=lambda o:o.dimensions.x*o.dimensions.y*o.dimensions.z,reverse=True)[:140]:
 print('BIG',o.name,'loc',tuple(round(x,1) for x in o.location),'dims',tuple(round(x,1) for x in o.dimensions))
