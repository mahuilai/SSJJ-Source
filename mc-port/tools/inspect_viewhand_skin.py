import UnityPy

path = r"D:\逆向\SSJJ双塔惊魂\资源全集\viewhand\man_7054af81a181fa550c92e563decf7cb1"
env = UnityPy.load(path)
gos = {}
transforms = {}
for obj in env.objects:
    if obj.type.name == "GameObject":
        gos[obj.path_id] = obj.read_typetree().get("m_Name")
    elif obj.type.name == "Transform":
        transforms[obj.path_id] = obj.read_typetree()
for obj in env.objects:
    if obj.type.name == "SkinnedMeshRenderer":
        smr = obj.read_typetree()
        bone_ids = [(x or {}).get("m_PathID") for x in (smr.get("m_Bones") or [])]
        print("renderer bones", len(bone_ids))
        for index, path_id in enumerate(bone_ids[:12]):
            transform = transforms.get(path_id, {})
            game_object = (transform.get("m_GameObject") or {}).get("m_PathID")
            print("renderer bone", index, gos.get(game_object), "pos", transform.get("m_LocalPosition"), "rot", transform.get("m_LocalRotation"))
        break
for obj in env.objects:
    if obj.type.name != "Mesh":
        continue
    mesh = obj.read()
    print("mesh", mesh.m_Name, "vertices", mesh.m_VertexData.m_VertexCount)
    print("channels", [(c.stream, c.offset, c.format, c.dimension) for c in (mesh.m_VertexData.m_Channels or [])])
    for attr in ("m_Skin", "m_BoneWeights", "m_BindPose", "m_VariableBoneCountWeights", "m_BonesAABB"):
        value = getattr(mesh, attr, None)
        print(attr, type(value).__name__, len(value) if hasattr(value, "__len__") else value)
        if attr in ("m_Skin", "m_BoneWeights") and value:
            for item in value[:3]:
                print("sample", vars(item), [name for name in dir(item) if not name.startswith("_")])
        if attr == "m_BindPose" and value:
            for index, matrix in enumerate(value[:4]):
                print("bindpose", index, type(matrix), repr(matrix), vars(matrix), [name for name in dir(matrix) if not name.startswith("_")])
    try:
        tree = obj.read_typetree()
        print("typetree keys", sorted(tree.keys()))
        for key in ("m_Skin", "m_BoneWeights", "m_BindPose"):
            value = tree.get(key)
            print("tree", key, type(value).__name__, len(value) if hasattr(value, "__len__") else value)
    except Exception as e:
        print("typetree failed", type(e).__name__, e)
    break
