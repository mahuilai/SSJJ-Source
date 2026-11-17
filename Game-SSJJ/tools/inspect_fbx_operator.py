import bpy
print('FBX_OP',hasattr(bpy.ops,'export_scene'),hasattr(bpy.ops.export_scene,'fbx'))
if hasattr(bpy.ops.export_scene,'fbx'): print('PROPS',[(p.identifier,p.type) for p in bpy.ops.export_scene.fbx.get_rna_type().properties])
