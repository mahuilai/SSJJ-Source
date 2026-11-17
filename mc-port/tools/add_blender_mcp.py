# -*- coding: utf-8 -*-
"""把 Blender 官方 Lab MCP Server 配置合并进 ~/.workbuddy/mcp.json，保留原有 server。

官方字段来源（不是第三方 ahujasid/blender-mcp）：
  https://projects.blender.org/lab/blender_mcp/wiki/Setup
  https://www.blender.org/lab/mcp-server/
  {"mcpServers": {"blender": {"command": "uv",
      "args": ["--directory", "<repo>/mcp", "run", "blender-mcp"]}}}

本机仓库：D:/mcport-tools/blender_mcp （git clone --depth 1）
add-on 已由用户装好并启用：
  C:/Users/Mahuilai/AppData/Roaming/Blender Foundation/Blender/5.4/extensions/user_default/mcp
socket: localhost:9876，addon 注册 1 秒后自动启动。

env 清空 PYTHONPATH/PYTHONHOME/VIRTUAL_ENV 是必须的：
WorkBuddy 注入的 PYTHONPATH 指向 D:/项目/File manger/Lib/site-packages，
会污染 uv 隔离环境，实测报 ModuleNotFoundError: No module named 'httpx._decoders'。

幂等：重复运行不会改坏其它 server。
"""
import json
import os
import shutil

P = r"C:/Users/Mahuilai/.workbuddy/mcp.json"
UV = r"C:/Users/Mahuilai/.local/bin/uv.exe"
MCP_DIR = r"D:/mcport-tools/blender_mcp/mcp"
ADDON_DIR = (r"C:/Users/Mahuilai/AppData/Roaming/Blender Foundation"
             r"\Blender\5.4\extensions\user_default\mcp")

with open(P, "r", encoding="utf-8") as fp:
    data = json.load(fp)

servers = data.setdefault("mcpServers", {})
before = dict(servers)

servers["blender"] = {
    "command": UV,
    "args": ["--directory", MCP_DIR, "run", "blender-mcp"],
    "env": {"PYTHONPATH": "", "PYTHONHOME": "", "VIRTUAL_ENV": ""},
}

shutil.copy2(P, P + ".bak-blender")
with open(P, "w", encoding="utf-8") as fp:
    json.dump(data, fp, ensure_ascii=False, indent=2)
    fp.write("\n")

with open(P, "r", encoding="utf-8") as fp:
    s = json.load(fp)["mcpServers"]
print("servers:", ", ".join(sorted(s)))
for k in ("dnspy-mcp", "ida-mcp"):
    print("  %-12s preserved=%s disabled=%s"
          % (k, s.get(k) == before.get(k), s.get(k, {}).get("disabled")))
print("  blender    :", json.dumps(s["blender"], ensure_ascii=False))
print("  uv exists  :", os.path.isfile(UV))
print("  pyproject  :", os.path.isfile(os.path.join(MCP_DIR, "pyproject.toml")))
print("  addon      :", os.path.isdir(ADDON_DIR))
