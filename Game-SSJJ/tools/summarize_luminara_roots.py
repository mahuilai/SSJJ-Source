import bpy,collections
s=bpy.data.scenes['KB3D_SecretsOfTheLuminara-Native']
def root(o):
 while o.parent: o=o.parent
 return o
clusters=collections.defaultdict(list)
for o in s.objects:
 if o.type=='MESH': clusters[root(o).name].append(o)
print('ROOTS',len(clusters))
for n,oo in sorted(clusters.items(),key=lambda kv:(-len(kv[1]),kv[0])):
 xs=[];ys=[];zs=[]
 for o in oo:
  c=o.matrix_world.translation; xs.append(c.x);ys.append(c.y);zs.append(c.z)
 print('ROOT',n,'N',len(oo),'CENTER',tuple(round(sum(a)/len(a),1) for a in (xs,ys,zs)),'XY',tuple(round(a,1) for a in (min(xs),max(xs),min(ys),max(ys))),'CHILDREN',','.join(o.name for o in oo[:3]))
print('SAMPLES')
for o in [o for o in s.objects if o.type=='MESH' and ('BldgTemple_A_Ground' in o.name or 'BldgTemple_E_Ground' in o.name or 'BuildModuleBridgeStraight_A_Long' in o.name)]:
 print(o.name,'local',tuple(round(v,2) for v in o.location),'world',tuple(round(v,2) for v in o.matrix_world.translation),'parent',o.parent.name if o.parent else None)
