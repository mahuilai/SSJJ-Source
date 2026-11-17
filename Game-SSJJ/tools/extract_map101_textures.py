"""Extract the original Map101 city tile textures used by Neon Skyrail."""
from pathlib import Path
import UnityPy

root = Path(__file__).resolve().parents[2]
source = root / "资源全集" / "maps" / "map101000_352184256ef4e77febc94de560c60257"
target = root / "Game-SSJJ" / "Assets" / "Parkour" / "Textures"
wanted = {f"S_city_{i:02d}" for i in (1, 2, 4, 6, 8, 12, 13)}
target.mkdir(parents=True, exist_ok=True)
env = UnityPy.load(str(source))
saved = set()
for obj in env.objects:
    if obj.type.name != "Texture2D":
        continue
    texture = obj.read()
    if texture.m_Name not in wanted:
        continue
    path = target / f"Map101_{texture.m_Name}.png"
    texture.image.save(path)
    saved.add(texture.m_Name)
missing = wanted - saved
if missing:
    raise SystemExit(f"Map101 textures missing: {sorted(missing)}")
print(f"Extracted {len(saved)} original map101 textures to {target}")
