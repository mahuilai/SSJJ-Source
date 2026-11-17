# -*- coding: utf-8 -*-
"""渲染当前 geo（body 三件）在「最终坐标 = geo/16」假设下的侧视与 3/4 视图。

用途：本地确认枪口朝向与镜/弹匣上下关系，替代盲试。
"""
import json
import os
import socket

GEO = r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj\assets\ssjj\geo_models\gun\awm_legend_t_geo.json"
OUT = r"D:\逆向\SSJJ双塔惊魂\mc-port\out"
BODY = {"p1_xm", "p3_xm", "d_xm"}


def main():
    g = json.load(open(GEO, encoding="utf-8"))
    bones = [b for b in g["minecraft:geometry"][0]["bones"]
             if b.get("poly_mesh") and b["name"] in BODY]
    obj = os.path.join(OUT, "body_final.obj")
    vb = 1
    with open(obj, "w", encoding="utf-8") as f:
        for b in bones:
            pm = b["poly_mesh"]
            f.write("o %s\n" % b["name"])
            for x, y, z in pm["positions"]:
                # final(MC) = (x/16, y/16, z/16)，假设无额外翻转；Blender=(X,-Z,Y)
                f.write("v %.5f %.5f %.5f\n" % (x / 16.0, -z / 16.0, y / 16.0))
            for u, v in pm["uvs"]:
                f.write("vt %.5f %.5f\n" % (u, 1.0 - v))
            for t in pm["polys"]:
                f.write("f %d/%d %d/%d %d/%d\n" % (
                    t[0][0] + vb, t[0][2] + vb,
                    t[1][0] + vb, t[1][2] + vb,
                    t[2][0] + vb, t[2][2] + vb))
            vb += len(pm["positions"])
    print("obj", obj, "bones", len(bones))

    jobs = [(obj, os.path.join(OUT, "final_side.png"), "ORTHO", 4.0),
            (obj, os.path.join(OUT, "final_34.png"), "PERSP", 0)]
    code = (
        "import bpy\nfrom mathutils import Vector\n"
        "JOBS = " + json.dumps(jobs) + "\n"
        "def clean():\n"
        "    for ob in list(bpy.data.objects):\n"
        "        bpy.data.objects.remove(ob, do_unlink=True)\n"
        "res=[]\n"
        "for obj_path, png, ctype, oscale in JOBS:\n"
        "    clean()\n"
        "    bpy.ops.wm.obj_import(filepath=obj_path, forward_axis='Y', up_axis='Z')\n"
        "    TEX = " + json.dumps(r"D:\逆向\SSJJ双塔惊魂\mc-port\pack\ssjj\assets\ssjj\textures\gun\uv\awm_legend_t.png") + "\n"
        "    try:\n"
        "        img = bpy.data.images.load(TEX, check_existing=True)\n"
        "        mat = bpy.data.materials.new('M'); mat.use_nodes = True\n"
        "        nt = mat.node_tree\n"
        "        bsdf = nt.nodes.get('Principled BSDF')\n"
        "        tex = nt.nodes.new('ShaderNodeTexImage'); tex.image = img\n"
        "        nt.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])\n"
        "        for o in [x for x in bpy.context.scene.objects if x.type == 'MESH']:\n"
        "            o.data.materials.clear(); o.data.materials.append(mat)\n"
        "    except Exception as e:\n"
        "        pass\n"
        "    sc=bpy.context.scene\n"
        "    sc.render.engine='BLENDER_WORKBENCH'\n"
        "    sc.render.resolution_x=900; sc.render.resolution_y=520\n"
        "    try:\n"
        "        sc.display.shading.light='STUDIO'\n"
        "        sc.display.shading.color_type='TEXTURE'\n"
        "        sc.display.shading.show_cavity=True\n"
        "    except Exception: pass\n"
        "    cd=bpy.data.cameras.new('C'); cam=bpy.data.objects.new('C',cd)\n"
        "    sc.collection.objects.link(cam); sc.camera=cam\n"
        "    cd.type=ctype\n"
        "    if ctype=='ORTHO': cd.ortho_scale=4.6\n"
        "    cd.lens=50\n"
        "    ms=[o for o in sc.objects if o.type=='MESH']\n"
        "    xs=[(o.matrix_world @ v.co).x for o in ms for v in o.data.vertices]\n"
        "    ys=[(o.matrix_world @ v.co).y for o in ms for v in o.data.vertices]\n"
        "    zs=[(o.matrix_world @ v.co).z for o in ms for v in o.data.vertices]\n"
        "    c=Vector(((min(xs)+max(xs))/2,(min(ys)+max(ys))/2,(min(zs)+max(zs))/2))\n"
        "    size=max(max(xs)-min(xs),max(ys)-min(ys),max(zs)-min(zs),0.001)\n"
        "    if ctype=='ORTHO': cam.location=(c.x+size*3, c.y, c.z)\n"
        "    else: cam.location=(c.x+size*1.2, c.y-size*1.2, c.z+size*0.7)\n"
        "    d=c-cam.location; cam.rotation_euler=d.to_track_quat('-Z','Y').to_euler()\n"
        "    sc.render.filepath=png\n"
        "    bpy.ops.render.render(write_still=True)\n"
        "    res.append({'png':png,'size':round(size,2),'y':[round(min(ys),2),round(max(ys),2)]})\n"
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
        print("RESP", buf.split(b"\x00")[0].decode("utf-8", "replace")[:400])
    except Exception as e:
        print("FAIL", type(e).__name__, str(e)[:120])
    finally:
        s.close()


if __name__ == "__main__":
    main()
