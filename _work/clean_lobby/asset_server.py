# -*- coding: utf-8 -*-
"""
Clean-Room Offline Lobby Asset & Profile Server (127.0.0.1:8080)
Serves:
- Stage3D ClientView.swf + 3D models/animations/textures (local cache + CDN auto-fill)
- Official UI SWFs, XMLs, unpacked FGUI PNGs, and item/role preview icons
- /__catalog (21,669 items), /__profile, /__save_profile, /__launch_battle
"""
import http.server
import socketserver
import os
import sys
import json
import urllib.parse
import urllib.request
import subprocess
import threading
import re

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HTTP_PORT = 8080
CLEAN_DIR = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby"
CATALOG_PATH = os.path.join(CLEAN_DIR, "catalog_21669.json")
FGUI_DIR = os.path.join(CLEAN_DIR, "fgui_unpacked")
PROFILE_PATH = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\user_profile.json"
ROLES_PATH = r"D:\逆向\SSJJ双塔惊魂\_work\all_roles.json"
CACHE_DIR = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cache"
CDN_PRISTINE = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\cdn_pristine"
PLAIN_DIR = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\plain"
SWF_DIR = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main\output\swf"
XML_DIR = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main\output\xml"
PREVIEW_DIR = r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\assets\previews"
SKIN_PREVIEW_DIR = r"D:\逆向\SSJJ双塔惊魂\_work\lobby_host\skinpreviews"
CDN_BASE = "http://cdn.4399ssjj.com/s3/"

LAUNCH_CONFIG = r"D:\SSJJ-4399\battle\3_64\launch_config.json"
START_OFFLINE = r"D:\SSJJ-4399\start_offline.py"

os.makedirs(CACHE_DIR, exist_ok=True)


def launch_unity_battle(map_key: str, mode_key: str, bag_idx: int):
    try:
        profile = json.load(open(PROFILE_PATH, "r", encoding="utf-8-sig"))
        roles = json.load(open(ROLES_PATH, "r", encoding="utf-8-sig"))
        bags = profile.get("bags", [])
        if 0 <= bag_idx < len(bags):
            profile["selectedBagIndex"] = bag_idx
            json.dump(profile, open(PROFILE_PATH, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
        else:
            bag_idx = int(profile.get("selectedBagIndex", 0))

        cfg = {}
        if os.path.isfile(LAUNCH_CONFIG):
            try:
                cfg = json.load(open(LAUNCH_CONFIG, "r", encoding="utf-8-sig"))
            except Exception:
                cfg = {}

        skins = profile.get("equippedSkins") or {}
        def get_skin(item):
            if not isinstance(item, dict):
                return ""
            for k in (str(item.get("storageId", "")), str(item.get("tid", "")), str(item.get("codeName", ""))):
                if k and k in skins:
                    v = skins[k]
                    return str(v.get("codeName") if isinstance(v, dict) else v)
            return ""

        battle_bags = []
        for b in bags[:5]:
            m = b.get("master") or {"codeName": "m4a1"}
            s = b.get("secondary") or {"codeName": "deagle"}
            c = b.get("closed") or {"codeName": "dagger"}
            t = b.get("bom1") or b.get("bom2") or b.get("bom3") or {"codeName": "grenade"}
            battle_bags.append({
                "primary": str(m.get("codeName", "m4a1")),
                "secondary": str(s.get("codeName", "deagle")),
                "melee": str(c.get("codeName", "dagger")),
                "throwable": str(t.get("codeName", "grenade")),
                "primary_skin": get_skin(m),
                "secondary_skin": get_skin(s),
                "melee_skin": get_skin(c),
                "throwable_skin": get_skin(t),
            })

        sel_bag = bags[bag_idx] if bag_idx < len(bags) else {}
        team = int(profile.get("team", 1))
        role_id = int(sel_bag.get("roleCTID" if team == 2 else "roleTID") or profile.get("defaultAvatar") or 150)
        career = str(profile.get("defaultCareer") or "pandora_ct")
        for r in roles:
            if int(r.get("id", -1)) == role_id and r.get("carrer"):
                career = str(r["carrer"])
                break

        cfg["map"] = map_key or "map12"
        cfg["mode"] = mode_key or "team_ai"
        cfg["career"] = career
        cfg["active_bag"] = bag_idx
        cfg["bags"] = battle_bags
        if battle_bags:
            cfg["weapon"] = battle_bags[bag_idx]["primary"]
            cfg["weapon_skin"] = battle_bags[bag_idx]["primary_skin"]
            cfg["weapon_skin_weapon"] = battle_bags[bag_idx]["primary"]

        os.makedirs(os.path.dirname(LAUNCH_CONFIG), exist_ok=True)
        with open(LAUNCH_CONFIG, "w", encoding="utf-8") as f:
            json.dump(cfg, f, indent=2, ensure_ascii=False)

        flags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
        subprocess.Popen([sys.executable, START_OFFLINE], cwd=os.path.dirname(START_OFFLINE), creationflags=flags)
        print(f"[BattleLaunch] Launched map={cfg['map']} mode={cfg['mode']} career={career} bag={bag_idx+1}", flush=True)
        return True, f"Launched {cfg['map']} ({career} / Bag {bag_idx+1})"
    except Exception as e:
        print(f"[BattleLaunch] Error: {e}", flush=True)
        return False, str(e)


class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


class CleanAssetHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def _send_bytes(self, data: bytes, ctype="application/octet-stream"):
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def _send_file(self, path: str, ctype="application/octet-stream"):
        data = open(path, "rb").read()
        self._send_bytes(data, ctype)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        p = urllib.parse.unquote(parsed.path).lstrip("/")
        q = urllib.parse.parse_qs(parsed.query)

        if p == "crossdomain.xml":
            xml = b'<?xml version="1.0"?><cross-domain-policy><allow-access-from domain="*" /></cross-domain-policy>'
            return self._send_bytes(xml, "text/xml")

        if p == "__log":
            msg = q.get("msg", [""])[0]
            print(f"[AS3 LOG] {msg}", flush=True)
            try:
                with open(r"D:\逆向\SSJJ双塔惊魂\as3_debug.log", "a", encoding="utf-8") as lf:
                    lf.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} {msg}\n")
            except Exception:
                pass
            return self._send_bytes(b'{"ok":true}', "application/json")

        if p == "__catalog":
            return self._send_file(CATALOG_PATH, "application/json; charset=utf-8")

        if p == "__i18n":
            return self._send_file(os.path.join(CLEAN_DIR, "i18n.txt"), "text/plain; charset=utf-8")

        if p == "__profile":
            return self._send_file(PROFILE_PATH, "application/json; charset=utf-8")

        if p == "__launch_battle":
            map_key = q.get("map", ["map12"])[0]
            mode_key = q.get("mode", ["team_ai"])[0]
            bag_idx = int(q.get("bag", ["0"])[0])
            ok, msg = launch_unity_battle(map_key, mode_key, bag_idx)
            resp = json.dumps({"ok": ok, "msg": msg}, ensure_ascii=False).encode("utf-8")
            return self._send_bytes(resp, "application/json; charset=utf-8")

        if p.startswith("__fgui/"):
            rel = p[len("__fgui/"):].replace("/", os.sep)
            fp = os.path.join(FGUI_DIR, rel)
            if os.path.isfile(fp):
                return self._send_file(fp, "image/png" if fp.endswith(".png") else "text/xml")
            return self.send_error(404)

        if p.startswith("__preview/"):
            # /__preview/weapon/<codeName> or /__preview/role/<career> or /__preview/skin/<id>
            parts = p.split("/")
            if len(parts) >= 3:
                ptype, key = parts[1], parts[2]
                cands = []
                if ptype == "weapon":
                    cands.append(os.path.join(PREVIEW_DIR, "weapons", f"{key.lower()}.png"))
                    cands.append(os.path.join(PREVIEW_DIR, "weapons", f"{key}.png"))
                elif ptype == "role":
                    cands.append(os.path.join(PREVIEW_DIR, "characters", f"{key.lower()}.png"))
                    cands.append(os.path.join(PREVIEW_DIR, "characters", f"{key}.png"))
                elif ptype == "skin":
                    cands.append(os.path.join(SKIN_PREVIEW_DIR, f"{key}.png"))
                elif ptype == "spray":
                    cands.append(os.path.join(PREVIEW_DIR, "sprays", f"{key}.png"))
                elif ptype == "medal":
                    cands.append(os.path.join(PREVIEW_DIR, "medals", f"medal_{key}.png"))
                elif ptype == "title":
                    cands.append(os.path.join(PREVIEW_DIR, "titles", f"title_{key}.png"))
                elif ptype == "map":
                    cands.append(os.path.join(PREVIEW_DIR, "maps", f"{key}.png"))
                for c in cands:
                    if os.path.isfile(c):
                        return self._send_file(c, "image/png")
            return self.send_error(404)

        if p.startswith("__swf/"):
            name = p[len("__swf/"):]
            prefix = name.split(".")[0].lower()
            # 1. exact match
            for d in (SWF_DIR, PLAIN_DIR, CACHE_DIR, CDN_PRISTINE):
                fp = os.path.join(d, name)
                if os.path.isfile(fp):
                    return self._send_file(fp, "application/x-shockwave-flash")
            # 2. prefix match in SWF_DIR
            if os.path.isdir(SWF_DIR):
                for fn in os.listdir(SWF_DIR):
                    if fn.lower().startswith(prefix + "_") and fn.endswith(".swf"):
                        return self._send_file(os.path.join(SWF_DIR, fn), "application/x-shockwave-flash")
            # 3. plain_dir match
            if os.path.isdir(PLAIN_DIR):
                for fn in os.listdir(PLAIN_DIR):
                    fl = fn.lower()
                    if (fl.startswith(f"resource_flas_{prefix}_") or fl.startswith(f"{prefix}_")) and fl.endswith(".swf"):
                        return self._send_file(os.path.join(PLAIN_DIR, fn), "application/x-shockwave-flash")
                for fn in os.listdir(PLAIN_DIR):
                    if prefix in fn.lower() and fn.endswith(".swf"):
                        return self._send_file(os.path.join(PLAIN_DIR, fn), "application/x-shockwave-flash")
            return self.send_error(404)

        if p.startswith("__xml/"):
            name = p[len("__xml/"):]
            prefix = name.split(".")[0].lower()
            for d in (XML_DIR, PLAIN_DIR, CACHE_DIR, CDN_PRISTINE):
                fp = os.path.join(d, name)
                if os.path.isfile(fp):
                    return self._send_file(fp, "text/xml; charset=utf-8")
            if os.path.isdir(XML_DIR):
                for fn in os.listdir(XML_DIR):
                    if fn.lower().startswith(prefix + "_") and fn.endswith(".xml"):
                        return self._send_file(os.path.join(XML_DIR, fn), "text/xml; charset=utf-8")
            if os.path.isdir(PLAIN_DIR):
                for fn in os.listdir(PLAIN_DIR):
                    fl = fn.lower()
                    if (fl.startswith(f"resource_view_{prefix}_") or fl.startswith(f"{prefix}_") or prefix in fl) and fl.endswith(".xml"):
                        return self._send_file(os.path.join(PLAIN_DIR, fn), "text/xml; charset=utf-8")
            return self.send_error(404)

        # Standard Stage3D ClientView.swf & resource paths
        base = os.path.basename(p)
        key = p.replace("/", "_")
        for d in (CACHE_DIR, CDN_PRISTINE, PLAIN_DIR, SWF_DIR, XML_DIR):
            for cand_name in (key, base):
                cand = os.path.join(d, cand_name)
                if os.path.isfile(cand):
                    print(f"[http] hit {p} -> {os.path.basename(cand)}", flush=True)
                    return self._send_file(cand)

        # Fallback: fetch from official 4399 SSJJ CDN and cache locally
        try:
            url = CDN_BASE + p
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=8) as r:
                data = r.read()
                ctype = r.headers.get("Content-Type", "application/octet-stream")
            cache_fp = os.path.join(CACHE_DIR, key)
            open(cache_fp, "wb").write(data)
            print(f"[http] CDN cached {p} ({len(data)} bytes)", flush=True)
            return self._send_bytes(data, ctype)
        except Exception as e:
            print(f"[http] MISS {p}: {e}", flush=True)
            return self.send_error(404)

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        p = parsed.path.lstrip("/")
        n = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(n) if n else b""

        if p == "__save_profile":
            try:
                obj = json.loads(body.decode("utf-8"))
                with open(PROFILE_PATH, "w", encoding="utf-8") as f:
                    json.dump(obj, f, indent=2, ensure_ascii=False)
                print(f"[profile] Saved user_profile.json (bag={obj.get('selectedBagIndex')}, role={obj.get('defaultAvatar')})", flush=True)
                return self._send_bytes(b'{"ok":true}', "application/json")
            except Exception as e:
                print(f"[profile] Save error: {e}", flush=True)
                return self._send_bytes(json.dumps({"ok": False, "err": str(e)}).encode("utf-8"), "application/json")

        return self._send_bytes(b"ok", "text/plain")


if __name__ == "__main__":
    print(f"[CleanAssetServer] Listening on http://127.0.0.1:{HTTP_PORT}/ ...", flush=True)
    srv = ThreadingHTTPServer(("127.0.0.1", HTTP_PORT), CleanAssetHandler)
    srv.serve_forever()
