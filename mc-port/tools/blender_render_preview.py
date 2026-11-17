# -*- coding: utf-8 -*-
"""通过 Blender 官方 MCP socket 渲染 geo 预览（侧视 + 3/4 视角），本地验证朝向/上下。

前提：Blender GUI 打开且 9876 在监听（mc-port/tools/start_blender.py 可拉起）。
OBJ 由 geo.json 生成，坐标已转 Blender Z-up：MC(x,y,z) -> Blender(x,z,y)。

注意：
- 不能用 bpy.ops.wm.read_factory_settings()，它会重置首选项，可能把 MCP 插件一起停掉，
  导致 socket 有连接但无响应（表现为"卡住"）。这里改成逐个删除对象。
- 用 BLENDER_WORKBENCH 渲染，不编译 shader，几秒出图；EEVEE 首次渲染会卡几十秒。
"""
import json
import socket
import sys

OBJ = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\preview_blender.obj"
PNG_SIDE = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\preview_side.png"
PNG_34 = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\preview_34.png"

CODE = r"""
import bpy
from mathutils import Vector

OBJ_PATH = __OBJ__
SIDE_PATH = __SIDE__
Q34_PATH = __Q34__

# 清场（不用 read_factory_settings，避免重置首选项把 MCP 插件停掉）
for ob in list(bpy.data.objects):
    bpy.data.objects.remove(ob, do_unlink=True)

bpy.ops.wm.obj_import(filepath=OBJ_PATH)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']

sc = bpy.context.scene
try:
    sc.render.engine = 'BLENDER_WORKBENCH'
except Exception:
    pass
sc.render.resolution_x = 760
sc.render.resolution_y = 500
sc.render.film_transparent = False
try:
    sc.display.shading.light = 'STUDIO'
    sc.display.shading.color_type = 'TEXTURE'
    sc.display.shading.show_cavity = True
except Exception:
    pass
try:
    sc.world = bpy.data.worlds.new('W')
except Exception:
    pass

cam_data = bpy.data.cameras.new('Cam')
cam = bpy.data.objects.new('Cam', cam_data)
sc.collection.objects.link(cam)
sc.camera = cam
cam_data.lens = 50

def look_at(obj, target):
    d = Vector(target) - obj.location
    obj.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()

xs = [v.co.x for o in meshes for v in o.data.vertices]
ys = [v.co.y for o in meshes for v in o.data.vertices]
zs = [v.co.z for o in meshes for v in o.data.vertices]
center = ((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2, (min(zs) + max(zs)) / 2)
size = max(max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs), 0.001)
result = {
    'objects': len(meshes),
    'verts': sum(len(o.data.vertices) for o in meshes),
    'center': [round(c, 2) for c in center],
    'size': round(size, 2),
    'x': [round(min(xs), 2), round(max(xs), 2)],
    'y': [round(min(ys), 2), round(max(ys), 2)],
    'z': [round(min(zs), 2), round(max(zs), 2)],
}

# 侧视：+X 方向看向枪身，枪口（-Z in MC -> -Y in Blender）应在画面一侧
cam.location = (center[0] + size * 1.6, center[1], center[2] + size * 0.2)
look_at(cam, center)
sc.render.filepath = SIDE_PATH
bpy.ops.render.render(write_still=True)

# 3/4 视角
cam.location = (center[0] + size * 1.2, center[1] - size * 1.2, center[2] + size * 0.75)
look_at(cam, center)
sc.render.filepath = Q34_PATH
bpy.ops.render.render(write_still=True)

result['rendered'] = True
"""


def main():
    code = (CODE.replace("__OBJ__", json.dumps(OBJ))
                .replace("__SIDE__", json.dumps(PNG_SIDE))
                .replace("__Q34__", json.dumps(PNG_34)))
    req = {"type": "execute", "code": code, "strict_json": True}
    s = socket.socket()
    s.settimeout(150)
    try:
        s.connect(("127.0.0.1", 9876))
        s.sendall(json.dumps(req).encode("utf-8") + b"\x00")
        buf = b""
        while True:
            c = s.recv(65536)
            if not c:
                break
            buf += c
            if b"\x00" in buf:
                break
        print("RESPONSE", buf.split(b"\x00")[0].decode("utf-8", "replace")[:800])
    except Exception as e:
        print("FAIL", type(e).__name__, str(e)[:150])
        return 1
    finally:
        s.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
