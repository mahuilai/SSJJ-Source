import sys, glob, os

BASE = r"D:\逆向\SSJJ双塔惊魂\资源全集\player"
# ct_knight1 主包（含 prefab + Animator）；$2 包是 mesh/shader 拆分
main = glob.glob(os.path.join(BASE, "ct_knight1_*"))
main = [m for m in main if "$" not in os.path.basename(m)]
print("main bundles:", main)

import UnityPy

for path in main[:1]:
    env = UnityPy.load(path)
    print("=== %s ===" % os.path.basename(path))
    for obj in env.objects:
        t = obj.type.name
        if t == "MonoBehaviour" or t == "GameObject" or t == "Animator":
            pass
    # 先找 Animator（MonoBehaviour 里 m_ApplyRootMotion）
    n_anim = 0
    for obj in env.objects:
        if obj.type.name != "MonoBehaviour":
            continue
        try:
            data = obj.read_typed()
        except Exception:
            continue
        cls = getattr(data, "m_GameObject", None)
        # Animator 序列化字段名：m_ApplyRootMotion / m_Controller / m_Avatar
        arm = getattr(data, "m_ApplyRootMotion", None)
        if arm is None:
            continue
        n_anim += 1
        print("Animator found: applyRootMotion=%s controller=%s avatar=%s enabled=%s" % (
            arm,
            getattr(data, "m_Controller", None),
            getattr(data, "m_Avatar", None),
            getattr(data, "m_Enabled", None)))
    print("total Animator components:", n_anim)

    # 渲染器清单 + layer
    n_rend = 0
    layers = {}
    for obj in env.objects:
        if obj.type.name not in ("SkinnedMeshRenderer", "MeshRenderer"):
            continue
        try:
            data = obj.read_typed()
        except Exception:
            continue
        n_rend += 1
        go = getattr(data, "m_GameObject", None)
        layers[go.m_Name if go else "?"] = None
    print("renderers:", n_rend)
    # GameObject layer 值
    gl = {}
    for obj in env.objects:
        if obj.type.name != "GameObject":
            continue
        try:
            data = obj.read_typed()
        except Exception:
            continue
        gl[data.m_Name] = data.m_Layer
    from collections import Counter
    print("GameObject layers:", Counter(gl.values()))
    knight = [k for k in gl if "knight" in k.lower() or "role" in k.lower() or "huan" in k.lower()]
    print("interesting GOs:", knight[:10])
    for k in knight[:10]:
        print("  ", k, "layer=", gl[k])
