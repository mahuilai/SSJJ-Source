import json, os

base = r"D:\逆向\SSJJ双塔惊魂\资源全集"
idx = os.path.join(base, "INDEX.json")
with open(idx, "r", encoding="utf-8") as f:
    data = json.load(f)

players = data.get("players", [])
print("players entries:", len(players))
if players:
    print("sample entry:", json.dumps(players[0], ensure_ascii=False)[:300])
hits = []
for e in players:
    name = e.get("name", "") if isinstance(e, dict) else str(e)
    if "knight" in name.lower() or "terror" in name.lower():
        hits.append(e)
print("=== knight/terror hits ===")
for h in hits[:25]:
    print(json.dumps(h, ensure_ascii=False))
