# -*- coding: utf-8 -*-
"""Dump materials of ct_knight1$2: shader name + m_TexEnvs bindings (REF/NULL)."""
import UnityPy, glob, os

BASE = r"D:\逆向\SSJJ双塔惊魂\资源全集\player"
src = glob.glob(os.path.join(BASE, "ct_knight1$2_*"))[0]
env = UnityPy.load(src)
print("=== %s ===" % os.path.basename(src))

# build pathID -> object map for shader name resolution
pid2obj = {}
for obj in env.objects:
    pid2obj[obj.path_id] = obj

def shader_name(pptr):
    if pptr is None: return "?"
    try:
        pid = getattr(pptr, "m_PathID", 0)
        if pid == 0: return "?"
        o = pid2obj.get(pid)
        if o is None: return "pid=%d(ext)" % pid
        d = o.read()
        return getattr(d, "m_Name", "?") or getattr(d, "m_ParsedForm", None) and d.m_ParsedForm.m_Name or "?"
    except Exception as e:
        return "err:%s" % e

mats = []
for obj in env.objects:
    if obj.type.name == "Material":
        try:
            mats.append(obj.read())
        except Exception as e:
            print("read fail", e)

print("materials:", len(mats))
for m in mats:
    name = getattr(m, "m_Name", "?")
    sp = getattr(m, "m_SavedProperties", None)
    texs = []
    if sp is not None:
        te = getattr(sp, "m_TexEnvs", None) or []
        for e in te:
            tname = getattr(e, "name", "?")
            tex = getattr(e, "texture", None)
            has = tex is not None and getattr(tex, "m_PathID", 0) != 0
            texs.append("%s=%s" % (tname, "REF" if has else "NULL"))
    # shader name via m_Shader pptr -> Shader object in same bundle (usually external)
    sh = getattr(m, "m_Shader", None)
    shp = "?"
    if sh is not None:
        pid = getattr(sh, "m_PathID", 0)
        shp = "pid=%d" % pid
    print("  %-30s shader[%s] tex: %s" % (name, shp, ", ".join(texs) if texs else "(none)"))

# main bundle textures
src2 = glob.glob(os.path.join(BASE, "ct_knight1_183c*"))[0]
env2 = UnityPy.load(src2)
tn = []
for obj in env2.objects:
    if obj.type.name == "Texture2D":
        try: tn.append(obj.read().m_Name)
        except Exception: pass
print("=== main bundle textures (%d) ===" % len(tn))
print(tn)
