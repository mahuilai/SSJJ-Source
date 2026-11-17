# -*- coding: utf-8 -*-
"""单独渲染指定组，用于判断哪个是「华丽矛形」正身。

用法：python render_one.py p1_xm p3_xm d_xm
输出 out/one_<name>.png
"""
import json
import os
import socket
import sys

OBJ_SRC = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\mesh\awm_legend_t.obj"
TEX = r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj\assets\ssjj\textures\gun\uv\awm_legend_t.png"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"
S = 0.3744


def parse(path):
    groups, cur, base_v, base_vt = [], None, 0, 0
    for ln in open(path, encoding="utf-8"):
        if ln.startswith("o "):
            cur = {"name": ln[2:].strip(), "v": [], "vt": [], "f": [],
                   "base_v": base_v, "base_vt": base_vt}
            groups.append(cur)
        elif cur is None:
            continue
        elif ln.startswith("v "):
            cur["v"].append([float(x) for x in ln.split()[1:4]])
            base_v += 1
        elif ln.startswith("vt "):
            cur["vt"].append([float(x) for x in ln.split()[1:3]])
            base_vt += 1
        elif ln.startswith("f "):
            cur["f"].append([[int(t.split("/")[0]), int(t.split("/")[1])] for t in ln.split()[1:4]])
    return {g["name"]: g for g in groups}


def main():
    want = sys.argv[1:] or ["p1_xm"]
    gs = parse(OBJ_SRC)
    picks = [gs[n] for n in want if n in gs]
    allv = [v for g in picks for v in g["v"]]
    mn = [min(v[i] for v in allv) for i in range(3)]
    mx = [max(v[i] for v in allv) for i in range(3)]
    cy, cz = (mn[1] + mx[1]) / 2, (mn[2] + mx[2]) / 2
    length = (mx[0] - mn[0]) * S / 16.0

    jobs = []
    for g in picks:
        obj = os.path.join(OUT, "one_%s.obj" % g["name"])
        vb = 1
        with open(obj, "w", encoding="utf-8") as f:
            f.write("o %s\n" % g["name"])
            for v in g["v"]:
                f.write("v %.5f %.5f %.5f\n" % ((v[2] - cz) * S / 16,
                                                (v[0] - mn[0]) * S / 16,
                                                (v[1] - cy) * S / 16))
            for uv in g["vt"]:
                f.write("vt %.5f %.5f\n" % (uv[0], 1.0 - uv[1]))
            bv, bt = g["base_v"], g["base_vt"]
            for tri in g["f"]:
                f.write("f %d/%d %d/%d %d/%d\n" % (
                    tri[0][0] - bv, tri[0][1] - bt,
                    tri[1][0] - bv, tri[1][1] - bt,
                    tri[2][0] - bv, tri[2][1] - bt))
            vb += len(g["v"])
        jobs.append((obj, os.path.join(OUT, "one_%s.png" % g["name"]), length, len(g["f"])))
    print("jobs", [(os.path.basename(j[0]), round(j[2], 2), j[3]) for j in jobs])

    code = (
        "import bpy\nfrom mathutils import Vector\n"
        "JOBS=" + json.dumps(jobs) + "\n"
        "res=[]\n"
        "for obj_path, png, length, nf in JOBS:\n"
        "    for ob in list(bpy.data.objects):\n"
        "        bpy.data.objects.remove(ob, do_unlink=True)\n"
        "    bpy.ops.wm.obj_import(filepath=obj_path, forward_axis='Y', up_axis='Z')\n"
        "    sc=bpy.context.scene\n"
        "    sc.render.engine='BLENDER_WORKBENCH'\n"
        "    sc.render.resolution_x=980; sc.render.resolution_y=420\n"
        "    try:\n"
        "        sc.display.shading.light='STUDIO'\n"
        "        sc.display.shading.color_type='TEXTURE'\n"
        "        sc.display.shading.show_cavity=True\n"
        "    except Exception: pass\n"
        "    img=bpy.data.images.load(" + json.dumps(TEX) + ", check_existing=True)\n"
        "    mat=bpy.data.materials.new('M'); mat.use_nodes=True\n"
        "    nt=mat.node_tree; b=nt.nodes.get('Principled BSDF')\n"
        "    t=nt.nodes.new('ShaderNodeTexImage'); t.image=img\n"
        "    nt.links.new(t.outputs['Color'], b.inputs['Base Color'])\n"
        "    for o in [x for x in sc.objects if x.type=='MESH']:\n"
        "        o.data.materials.clear(); o.data.materials.append(mat)\n"
        "    cd=bpy.data.cameras.new('C'); cam=bpy.data.objects.new('C',cd)\n"
        "    sc.collection.objects.link(cam); sc.camera=cam\n"
        "    cd.type='ORTHO'; cd.ortho_scale=length*1.15\n"
        "    cam.rotation_mode='XYZ'\n"
        "    ctr=Vector((0, length/2, 0.25))\n"
        "    cam.location=ctr+Vector((length*1.6, 0, 0))\n"
        "    cam.rotation_euler=(1.5707963, 0.0, 1.5707963)\n"
        "    sc.render.filepath=png\n"
        "    bpy.ops.render.render(write_still=True)\n"
        "    res.append({'png':png,'ortho':round(length*1.15,2)})\n"
        "result={'rendered':res}\n"
    )
    s = socket.socket()
    s.settimeout(150)
    try:
        s.connect(("127.0.0.1", 9876))
        s.sendall(json.dumps({"type": "execute", "code": code, "strict_json": True}).encode() + b"\x00")
        buf = b""
        while True:
            c = s.recv(65536)
            if not c:
                break
            buf += c
            if b"\x00" in buf:
                break
        print("RESP", buf.split(b"\x00")[0].decode("utf-8", "replace")[:300])
    except Exception as e:
        print("FAIL", type(e).__name__, str(e)[:120])
    finally:
        s.close()


if __name__ == "__main__":
    main()
