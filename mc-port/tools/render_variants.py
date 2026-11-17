# -*- coding: utf-8 -*-
"""把 p1_xm / p3_xm / d_xm 三组分别摆开渲染，确认是不是「同一把枪的多个变体」。

输出 out/variants.png：从左到右 = p1_xm / p3_xm / d_xm，带贴图，侧视。
"""
import json
import os
import socket

OBJ_SRC = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\mesh\awm_legend_t.obj"
TEX = r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj\assets\ssjj\textures\gun\uv\awm_legend_t.png"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"
ORDER = ["p1_xm", "p3_xm", "d_xm"]
S = 0.3744


def parse(path):
    groups, cur = [], None
    for ln in open(path, encoding="utf-8"):
        if ln.startswith("o "):
            cur = {"name": ln[2:].strip(), "v": [], "vt": [], "f": []}
            groups.append(cur)
        elif cur is None:
            continue
        elif ln.startswith("v "):
            cur["v"].append([float(x) for x in ln.split()[1:4]])
        elif ln.startswith("vt "):
            cur["vt"].append([float(x) for x in ln.split()[1:3]])
        elif ln.startswith("f "):
            cur["f"].append([[int(t.split("/")[0]), int(t.split("/")[1])] for t in ln.split()[1:4]])
    return groups


def main():
    groups = {g["name"]: g for g in parse(OBJ_SRC)}
    body_v = [v for n in ORDER if n in groups for v in groups[n]["v"]]
    mn = [min(v[i] for v in body_v) for i in range(3)]
    mx = [max(v[i] for v in body_v) for i in range(3)]
    cy = (mn[1] + mx[1]) / 2
    cz = (mn[2] + mx[2]) / 2

    obj = os.path.join(OUT, "variants.obj")
    vbase = 1
    with open(obj, "w", encoding="utf-8") as f:
        for idx, name in enumerate(ORDER):
            g = groups.get(name)
            if not g:
                continue
            f.write("o %s\n" % name)
            dx = idx * 5.2  # 三组沿长度轴排开（每把约 3.45 长）
            for v in g["v"]:
                # Blender: X=宽度(Unity z), Y=长度(Unity x), Z=高度(Unity y)
                f.write("v %.5f %.5f %.5f\n" % ((v[2] - cz) * S / 16,
                                                (v[0] - mn[0]) * S / 16 + dx,
                                                (v[1] - cy) * S / 16))
            for uv in g["vt"]:
                f.write("vt %.5f %.5f\n" % (uv[0], 1.0 - uv[1]))
            for tri in g["f"]:
                f.write("f %d/%d %d/%d %d/%d\n" % (
                    tri[0][0] + vbase - 1, tri[0][1] + vbase - 1,
                    tri[1][0] + vbase - 1, tri[1][1] + vbase - 1,
                    tri[2][0] + vbase - 1, tri[2][1] + vbase - 1))
            vbase += len(g["v"])
    print("obj", obj, "ORDER", ORDER)

    code = (
        "import bpy\nfrom mathutils import Vector\n"
        "for ob in list(bpy.data.objects):\n"
        "    bpy.data.objects.remove(ob, do_unlink=True)\n"
        "bpy.ops.wm.obj_import(filepath=" + json.dumps(obj) + ", forward_axis='Y', up_axis='Z')\n"
        "sc=bpy.context.scene\n"
        "sc.render.engine='BLENDER_WORKBENCH'\n"
        "sc.render.resolution_x=1400; sc.render.resolution_y=380\n"
        "try:\n"
        "    sc.display.shading.light='STUDIO'\n"
        "    sc.display.shading.color_type='TEXTURE'\n"
        "    sc.display.shading.show_cavity=True\n"
        "except Exception: pass\n"
        "img=bpy.data.images.load(" + json.dumps(TEX) + ", check_existing=True)\n"
        "mat=bpy.data.materials.new('M'); mat.use_nodes=True\n"
        "nt=mat.node_tree; b=nt.nodes.get('Principled BSDF')\n"
        "t=nt.nodes.new('ShaderNodeTexImage'); t.image=img\n"
        "nt.links.new(t.outputs['Color'], b.inputs['Base Color'])\n"
        "for o in [x for x in sc.objects if x.type=='MESH']:\n"
        "    o.data.materials.clear(); o.data.materials.append(mat)\n"
        "cd=bpy.data.cameras.new('C'); cam=bpy.data.objects.new('C',cd)\n"
        "sc.collection.objects.link(cam); sc.camera=cam\n"
        "cd.type='ORTHO'; cd.ortho_scale=17.0\n"
        "cam.location=(12.0, 5.2, 3.0)\n"
        "d=Vector((0,5.2,0.3))-cam.location\n"
        "cam.rotation_euler=d.to_track_quat('-Z','Y').to_euler()\n"
        "sc.render.filepath=" + json.dumps(os.path.join(OUT, "variants.png")) + "\n"
        "bpy.ops.render.render(write_still=True)\n"
        "result={'ok':1,'objects':len([x for x in sc.objects if x.type=='MESH'])}\n"
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
