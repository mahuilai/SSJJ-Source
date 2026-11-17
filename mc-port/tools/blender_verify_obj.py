# -*- coding: utf-8 -*-
"""通过 Blender 官方 MCP 的 socket(localhost:9876) 实测导入导出的 OBJ。

协议：null-byte 分隔 JSON {"type":"execute","code":...,"strict_json":true}
code 里把结果赋给 result；本脚本导入后立刻删除新对象，不污染用户场景。
"""
import json
import socket

OBJ = r"D:\逆向\SSJJ双塔惊魂\mc-port\out\mesh\awm_legend_t.obj"

CODE = """
import bpy
before = set(o.name for o in bpy.data.objects)
p = %s
bpy.ops.wm.obj_import(filepath=p)
new = [o for o in bpy.data.objects if o.name not in before]
meshes = [o for o in new if o.type == 'MESH']
v = sum(len(o.data.vertices) for o in meshes)
f = sum(len(o.data.polygons) for o in meshes)
uv = sum(1 for o in meshes if o.data.uv_layers)
result = {
    'imported_objects': len(new),
    'mesh_objects': len(meshes),
    'vertices': v,
    'faces': f,
    'with_uv': uv,
    'sample': [o.name for o in new[:5]],
}
for o in new:
    bpy.data.objects.remove(o, do_unlink=True)
result['cleaned'] = True
""" % json.dumps(OBJ)


def main():
    req = {"type": "execute", "code": CODE, "strict_json": True}
    s = socket.socket()
    s.settimeout(30)
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
        text = buf.split(b"\x00")[0].decode("utf-8", "replace")
        print("RESPONSE", text[:700])
    except Exception as e:
        print("FAIL", type(e).__name__, str(e)[:150])
    finally:
        s.close()


if __name__ == "__main__":
    main()
