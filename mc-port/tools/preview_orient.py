# -*- coding: utf-8 -*-
"""用只含枪身（p1_xm / p3_xm / d_xm）的几何，对比三种 Y 处理在 Blender 里的正反。

产出：
  preview_A_raw.png   Unity 原始坐标（Y 向上）= 地面真值
  preview_B_pre.png   Y 预取负（旧方案）经 TML: y_final = -y_geo/16
  preview_C_nopre.png Y 不取负（当前方案）经 TML: y_final = -y_geo/16
"""
import json
import os
import socket

OBJ_SRC = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\mesh\awm_legend_t.obj"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"
BODY = {"p1_xm", "p3_xm", "d_xm"}
S = 0.3744          # 单位/cm
MUZZLE_Z = -35.225
CY = 7.68651


def parse_obj(path):
    groups, cur = [], None
    for ln in open(path, "r", encoding="utf-8"):
        if ln.startswith("o "):
            cur = {"name": ln[2:].strip(), "v": [], "f": []}
            groups.append(cur)
        elif cur is None:
            continue
        elif ln.startswith("v "):
            cur["v"].append([float(x) for x in ln.split()[1:4]])
        elif ln.startswith("f "):
            cur["f"].append([int(t.split("/")[0]) for t in ln.split()[1:4]])
    return groups


def write_obj(path, groups, xform):
    vb = 1
    with open(path, "w", encoding="utf-8") as f:
        for g in groups:
            if not g["v"] or not g["f"]:
                continue
            f.write("o %s\n" % g["name"])
            for v in g["v"]:
                x, y, z = xform(v)
                # Blender Z-up 右手系：MC(x,y,z) -> (x, -z, y)
                f.write("v %.5f %.5f %.5f\n" % (x, -z, y))
            for tri in g["f"]:
                f.write("f %d %d %d\n" % (tri[0] + vb - 1, tri[1] + vb - 1, tri[2] + vb - 1))
            vb += len(g["v"])


def main():
    groups = [g for g in parse_obj(OBJ_SRC) if g["name"] in BODY]
    body_v = [v for g in groups for v in g["v"]]
    mn = [min(v[i] for v in body_v) for i in range(3)]
    mx = [max(v[i] for v in body_v) for i in range(3)]
    cx, cy, cz = [(mn[i] + mx[i]) / 2 for i in range(3)]
    print("body groups", len(groups), "verts", len(body_v), "bbox", [round(x, 1) for x in mn], [round(x, 1) for x in mx])

    # A: 原始 Unity，仅缩放到模型单位（Y 向上）
    write_obj(os.path.join(OUT, "body_raw.obj"), groups,
              lambda v: ((v[2] - cz) * S, (v[1] - cy) * S, (v[0] - mn[0]) * S + MUZZLE_Z))
    # B: 预取负（旧）
    write_obj(os.path.join(OUT, "body_pre.obj"), groups,
              lambda v: ((v[2] - cz) * S, -(v[1] - cy) * S, (v[0] - mn[0]) * S + MUZZLE_Z))
    # C: 不取负（当前 geo）
    write_obj(os.path.join(OUT, "body_nopre.obj"), groups,
              lambda v: ((v[2] - cz) * S, (v[1] - cy) * S, (v[0] - mn[0]) * S + MUZZLE_Z))

    jobs = [
        (os.path.join(OUT, "body_raw.obj"), os.path.join(OUT, "preview_A_raw.png")),
        (os.path.join(OUT, "body_pre.obj"), os.path.join(OUT, "preview_B_pre.png")),
        (os.path.join(OUT, "body_nopre.obj"), os.path.join(OUT, "preview_C_nopre.png")),
    ]
    code = (
        "import bpy\n"
        "from mathutils import Vector\n"
        "JOBS = " + json.dumps(jobs) + "\n"
        "def clean():\n"
        "    for ob in list(bpy.data.objects):\n"
        "        bpy.data.objects.remove(ob, do_unlink=True)\n"
        "res = []\n"
        "for obj_path, png in JOBS:\n"
        "    clean()\n"
        "    bpy.ops.wm.obj_import(filepath=obj_path)\n"
        "    ms = [o for o in bpy.context.scene.objects if o.type == 'MESH']\n"
        "    sc = bpy.context.scene\n"
        "    sc.render.engine = 'BLENDER_WORKBENCH'\n"
        "    sc.render.resolution_x = 820\n"
        "    sc.render.resolution_y = 460\n"
        "    try:\n"
        "        sc.display.shading.light = 'STUDIO'\n"
        "        sc.display.shading.color_type = 'SINGLE'\n"
        "        sc.display.shading.single_color = (0.62, 0.60, 0.55)\n"
        "        sc.display.shading.show_cavity = True\n"
        "    except Exception:\n"
        "        pass\n"
        "    cd = bpy.data.cameras.new('C'); cam = bpy.data.objects.new('C', cd)\n"
        "    sc.collection.objects.link(cam); sc.camera = cam\n"
        "    cd.type = 'ORTHO'; cd.ortho_scale = 62.0\n"
        "    cam.location = (120.0, -7.6, 9.4)\n"
        "    cam.rotation_euler = (1.5707963, 0.0, 1.5707963)\n"
        "    sc.render.filepath = png\n"
        "    bpy.ops.render.render(write_still=True)\n"
        "    res.append({'png': png, 'objects': len(ms)})\n"
        "result = {'rendered': res}\n"
    )
    s = socket.socket()
    s.settimeout(150)
    try:
        s.connect(("127.0.0.1", 9876))
        s.sendall(json.dumps({"type": "execute", "code": code, "strict_json": True}).encode("utf-8") + b"\x00")
        buf = b""
        while True:
            c = s.recv(65536)
            if not c:
                break
            buf += c
            if b"\x00" in buf:
                break
        print("RESPONSE", buf.split(b"\x00")[0].decode("utf-8", "replace")[:500])
    except Exception as e:
        print("FAIL", type(e).__name__, str(e)[:150])
    finally:
        s.close()


if __name__ == "__main__":
    main()
