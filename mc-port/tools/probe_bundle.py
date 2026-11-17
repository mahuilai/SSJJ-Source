# -*- coding: utf-8 -*-
"""P1: dump awm_legend_t 主包 / $2 包的网格通道表、骨骼、材质、贴图清单。

产物:
  mc-port/out/bundle_probe.json   完整结构化数据（供 P2/P3 导出器直接消费）
  mc-port/notes/bundle_probe.md   人读摘要

Unity 2019 Mesh 说明（实测 UnityPy 1.25.4）:
  m_VertexData.m_VertexCount  顶点数
  m_VertexData.m_Channels     14 个 ChannelInfo: stream / offset / format / dimension
  m_VertexData.m_DataSize     !! UnityPy 暴露的是顶点字节流 bytes，不是整数 !!
  m_VertexData.m_Streams      若干 StreamInfo: channelMask / offset / stride
  m_IndexBuffer               uint16 索引字节流
  m_SubMeshes                 firstByte / indexCount / topology / firstVertex / vertexCount
通道语义: 0=Position(float3) 1=Normal(float3) 4=UV0(float2) 13=BoneIndex/Weight
"""
import collections
import io
import json
import os
import sys

import UnityPy

ROOT = r"D:\逆向\SSJJ双塔惊魂"
WEAPON = os.path.join(ROOT, "资源全集", "weapon")
OUT = os.path.join(ROOT, "mc-port", "out", "bundle_probe.json")
NOTE = os.path.join(ROOT, "mc-port", "notes", "bundle_probe.md")

CHANNEL_NAME = {
    0: "Position", 1: "Normal", 2: "Tangent", 3: "Color",
    4: "UV0", 5: "UV1", 6: "UV2", 7: "UV3",
    8: "BoneWeight", 9: "BoneIndex", 10: "UV4", 11: "UV5",
    12: "UV6", 13: "UV7/BoneExtra",
}


def g(obj, name, default=None):
    return getattr(obj, name, default)


def find_bundles():
    fs = [f for f in os.listdir(WEAPON) if f.startswith("awm_legend_t")]
    main = [f for f in fs if "$2_" not in f]
    sub = [f for f in fs if "$2_" in f]
    if not main or not sub:
        raise RuntimeError("bundle not found in " + WEAPON)
    return os.path.join(WEAPON, main[0]), os.path.join(WEAPON, sub[0])


def dump(path, label):
    env = UnityPy.load(path)
    stats = collections.Counter(o.type.name for o in env.objects)
    meshes, materials, textures, texts, smrs = [], [], [], [], []
    for o in env.objects:
        try:
            d = o.read()
        except Exception:
            continue
        t = o.type.name
        if t == "Mesh":
            vd = g(d, "m_VertexData")
            channels = []
            for i, c in enumerate(g(vd, "m_Channels", []) or []):
                channels.append({
                    "index": i,
                    "semantic": CHANNEL_NAME.get(i, "?"),
                    "stream": g(c, "stream"),
                    "offset": g(c, "offset"),
                    "format": g(c, "format"),
                    "dimension": g(c, "dimension"),
                })
            streams = []
            for i, s in enumerate(g(vd, "m_Streams", []) or []):
                streams.append({
                    "index": i,
                    "channelMask": g(s, "channelMask"),
                    "offset": g(s, "offset"),
                    "stride": g(s, "stride"),
                    "dividerOp": g(s, "dividerOp"),
                    "frequency": g(s, "frequency"),
                })
            raw = g(vd, "m_DataSize")
            data_len = len(raw) if isinstance(raw, (bytes, bytearray)) else 0
            idx = g(d, "m_IndexBuffer", b"") or b""
            subs = []
            for s in g(d, "m_SubMeshes", []) or []:
                subs.append({k: g(s, k) for k in
                             ("firstByte", "indexCount", "topology", "firstVertex", "vertexCount")})
            meshes.append({
                "name": g(d, "m_Name", ""),
                "path_id": o.path_id,
                "vertex_count": g(vd, "m_VertexCount"),
                "data_bytes": data_len,
                "channels": channels,
                "streams": streams,
                "index_bytes": len(idx),
                "index_count": len(idx) // 2,
                "submeshes": subs,
                "bindpose_count": len(g(d, "m_BindPose", []) or []),
                "bone_name_hashes": len(g(d, "m_BoneNameHashes", []) or []),
            })
        elif t == "Material":
            texenvs = []
            sp = g(d, "m_SavedProperties")
            if sp is not None:
                for e in g(sp, "m_TexEnvs", []) or []:
                    try:
                        texenvs.append([e[0], g(e[1], "m_Texture", None) and
                                        {"m_FileID": g(e[1].m_Texture, "m_FileID", None),
                                         "m_PathID": g(e[1].m_Texture, "m_PathID", None)}])
                    except Exception:
                        texenvs.append([str(e)[:60], None])
            sh = g(d, "m_Shader")
            materials.append({
                "name": g(d, "m_Name", ""),
                "path_id": o.path_id,
                "shader_path_id": g(sh, "m_PathID", None) if sh is not None else None,
                "shader_file_id": g(sh, "m_FileID", None) if sh is not None else None,
                "texenv_count": len(texenvs),
                "texenvs": texenvs,
            })
        elif t == "Texture2D":
            textures.append({
                "name": g(d, "m_Name", ""),
                "width": g(d, "m_Width"),
                "height": g(d, "m_Height"),
                "format": g(d, "m_TextureFormat"),
                "mip_count": g(d, "m_MipCount"),
            })
        elif t == "TextAsset":
            sc = g(d, "m_Script", b"") or b""
            texts.append({"name": g(d, "m_Name", ""),
                          "bytes": len(sc) if isinstance(sc, (bytes, bytearray)) else len(str(sc))})
        elif t == "SkinnedMeshRenderer":
            smrs.append({
                "path_id": o.path_id,
                "mesh_path_id": g(g(d, "m_Mesh", None), "m_PathID", None),
                "bones": len(g(d, "m_Bones", []) or []),
                "materials": len(g(d, "m_Materials", []) or []),
                "bone_name": g(g(d, "m_GameObject", None), "m_PathID", None),
            })
    return {
        "label": label,
        "file": os.path.basename(path),
        "size": os.path.getsize(path),
        "object_count": len(env.objects),
        "types": dict(stats),
        "meshes": meshes,
        "materials": materials,
        "textures": textures,
        "textassets": texts,
        "skinned_mesh_renderers": smrs,
    }


def main():
    main_p, sub_p = find_bundles()
    a = dump(main_p, "main")
    b = dump(sub_p, "$2")
    data = {"main": a, "mesh": b}
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)

    lines = ["# awm_legend_t bundle 探针（P1）", "",
             "产物: `mc-port/out/bundle_probe.json`（完整字段）", ""]
    for x in (a, b):
        lines += ["## %s  `%s`  %d B / %d objects" % (x["label"], x["file"], x["size"], x["object_count"]),
                  "", "类型统计: " + ", ".join("%s=%d" % kv for kv in sorted(x["types"].items(), key=lambda k: -k[1])[:12]), ""]
        if x["meshes"]:
            tv = sum(m["vertex_count"] or 0 for m in x["meshes"])
            ti = sum(m["index_count"] or 0 for m in x["meshes"])
            lines += ["**Mesh %d 个 / 顶点 %d / 索引 %d（三角 %d）**" % (len(x["meshes"]), tv, ti, ti // 3), "",
                      "| Mesh | 顶点 | 数据字节 | 索引 | 流 | 有效通道 | 骨骼 |", "|---|---|---|---|---|---|---|"]
            for m in x["meshes"]:
                active = ["%s@%d+%d" % (c["semantic"], c["stream"], c["offset"])
                          for c in m["channels"] if c["dimension"] and c["dimension"] > 0]
                lines.append("| %s | %s | %s | %s | %s | %s | %s |" %
                             (m["name"], m["vertex_count"], m["data_bytes"], m["index_count"],
                              len(m["streams"]), ", ".join(active), m["bindpose_count"]))
            lines.append("")
            m0 = x["meshes"][0]
            lines += ["StreamInfo 样例 `%s`: %s" % (m0["name"], json.dumps(m0["streams"], ensure_ascii=False)), ""]
        if x["textures"]:
            lines += ["**贴图 %d 张**；前 8: %s" % (len(x["textures"]),
                      ", ".join("%s(%sx%s fmt=%s)" % (t["name"], t["width"], t["height"], t["format"])
                                for t in x["textures"][:8])), ""]
        if x["materials"]:
            withtex = sum(1 for m in x["materials"] if m["texenv_count"])
            lines += ["**Material %d 个**，其中有贴图引用的 %d 个；前 10: %s" %
                      (len(x["materials"]), withtex,
                       ", ".join(m["name"] for m in x["materials"][:10])), ""]
        if x["textassets"]:
            lines += ["**TextAsset %d 个**: %s" % (len(x["textassets"]),
                      ", ".join("%s(%dB)" % (t["name"], t["bytes"]) for t in x["textassets"])), ""]
        if x["skinned_mesh_renderers"]:
            lines += ["**SkinnedMeshRenderer %d 个**，bones 总数 %d" %
                      (len(x["skinned_mesh_renderers"]),
                       sum(s["bones"] for s in x["skinned_mesh_renderers"])), ""]
    with open(NOTE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print("main objects=%d types=%s" % (a["object_count"], sorted(a["types"].items(), key=lambda k: -k[1])[:6]))
    print("$2   objects=%d types=%s" % (b["object_count"], sorted(b["types"].items(), key=lambda k: -k[1])[:6]))
    print("meshes=%d verts=%d indices=%d (tris=%d)" %
          (len(b["meshes"]), sum(m["vertex_count"] or 0 for m in b["meshes"]),
           sum(m["index_count"] or 0 for m in b["meshes"]),
           sum(m["index_count"] or 0 for m in b["meshes"]) // 3))
    print("textures=%d materials=%d textassets=%d smrs=%d" %
          (len(a["textures"]), len(b["materials"]), len(a["textassets"]),
           len(a["skinned_mesh_renderers"]) + len(b["skinned_mesh_renderers"])))
    print("written:", OUT, NOTE)


if __name__ == "__main__":
    main()
