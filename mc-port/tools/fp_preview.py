# -*- coding: utf-8 -*-
"""第一人称模拟预览：相机放在模型原点、看向 -Z，检查枪在画面中的位置与大小。

输出 out/fp_preview.png
"""
import json
import os
import socket

import sys as _sys

GEO = _sys.argv[1] if len(_sys.argv) > 1 else r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj\assets\ssjj\geo_models\gun\awm_legend_t_geo.json"
TEX = r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj\assets\ssjj\textures\gun\uv\awm_legend_t.png"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"


def main():
    g = json.load(open(GEO, encoding="utf-8"))
    bones = [b for b in g["minecraft:geometry"][0]["bones"] if b.get("poly_mesh")]
    obj = os.path.join(OUT, "fp_model.obj")
    vb = 1
    with open(obj, "w", encoding="utf-8") as f:
        for b in bones:
            pm = b["poly_mesh"]
            f.write("o %s\n" % b["name"])
            for x, y, z in pm["positions"]:
                # TML 最终坐标：/16，且 Y 取反；转到 Blender (X, -Z, Y)
                f.write("v %.5f %.5f %.5f\n" % (x / 16.0, -z / 16.0, -y / 16.0))
            for u, v in pm["uvs"]:
                f.write("vt %.5f %.5f\n" % (u, 1.0 - v))
            for t in pm["polys"]:
                f.write("f %d/%d %d/%d %d/%d\n" % (
                    t[0][0] + vb, t[0][2] + vb,
                    t[1][0] + vb, t[1][2] + vb,
                    t[2][0] + vb, t[2][2] + vb))
            vb += len(pm["positions"])
    print("obj", obj, "bones", len(bones))

    code = (
        "import bpy\nfrom mathutils import Vector\n"
        "for ob in list(bpy.data.objects):\n"
        "    bpy.data.objects.remove(ob, do_unlink=True)\n"
        "bpy.ops.wm.obj_import(filepath=" + json.dumps(obj) + ", forward_axis='Y', up_axis='Z')\n"
        "sc=bpy.context.scene\n"
        "sc.render.engine='BLENDER_WORKBENCH'\n"
        "sc.render.resolution_x=960; sc.render.resolution_y=540\n"
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
        "cd.lens=24.0; cd.sensor_width=36\n"
        "cam.location=(0.0, 0.0, 0.0)\n"
        "cam.rotation_euler=(1.5707963, 0.0, 0.0)\n"
        "sc.render.filepath=" + json.dumps(os.path.join(OUT, "fp_preview.png")) + "\n"
        "bpy.ops.render.render(write_still=True)\n"
        "ms=[o for o in sc.objects if o.type=='MESH']\n"
        "xs=[(o.matrix_world @ v.co).x for o in ms for v in o.data.vertices]\n"
        "ys=[(o.matrix_world @ v.co).y for o in ms for v in o.data.vertices]\n"
        "zs=[(o.matrix_world @ v.co).z for o in ms for v in o.data.vertices]\n"
        "result={'x':[round(min(xs),2),round(max(xs),2)],'y':[round(min(ys),2),round(max(ys),2)],'z':[round(min(zs),2),round(max(zs),2)]}\n"
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
