# -*- coding: utf-8 -*-
"""SSJJ Master HTTP Resource Gateway (8080) - 100% Offline Zero-Latency Mode"""
import http.server, socketserver, urllib.parse, os, sys, time, threading, re, json, io, socket, zlib, struct, hashlib
try:
    from PIL import Image
except ImportError:
    Image = None

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HTTP_PORT = 8080
CACHE = os.path.join(ROOT_DIR, "_work", "lobby_host", "cache")
# Generated icon SWFs live here so the official cached assets are never overwritten.
PREPARED_DIR = os.path.join(ROOT_DIR, "_work", "lobby_host", "cache_prepared")
# [PATCH 2026-11-01] 官方原版字节（按 res_config 契约校验）
PRISTINE_DIR = os.path.join(ROOT_DIR, "_work", "lobby_host", "cdn_pristine")
# [PATCH 2026-11-01] 服务端解密产物（官方解密链复现，848/848 成功）。
# 仅在 SSJJ_SERVE_DECRYPTED=1 时使用：此时 res_config 会被改写成
# encode="false" compress="false" + 明文 md5/size，客户端无需自己解密。
DECRYPTED_DIR = os.path.join(ROOT_DIR, "_work", "lobby_host", "decrypted")
os.makedirs(PREPARED_DIR, exist_ok=True)
# Plain payloads: already decoded and inflated, served with encode=false /
# compress=false metadata so the client uses them verbatim.
PLAIN_DIR = os.path.join(ROOT_DIR, "_work", "lobby_host", "plain")
# Verbatim mirror of the official CDN asset set (current version).
OFFICIAL_DIR = os.path.join(ROOT_DIR, "资源下载", "大厅资源", "SSJJ-New")
LOCAL_HALL = os.path.join(ROOT_DIR, "_work", "lobby_host", "hall_config.xml")
# The preloader verifies each module against the 32-hex hash embedded in its
# request name (ModuleLoader.onHallByteComplete). The official original is
# Lobby_0312bff96052be1d98c814c970eb8bb4.swf. The patched build below has
# ApplicationMediator.addInnerLoadPanel rewritten to an immediate returnvoid;
# it is named after its own MD5 (5aaf5c11ab83fcd4b34fab025700418d) so the
# hash check passes on the first request instead of retrying five times.
LOCAL_LOBBY_ORIGINAL = os.path.join(ROOT_DIR, "_work", "lobby_air", "Lobby_offline_nofocusout.swf")
LOCAL_LOBBY_PATCHED = os.path.join(ROOT_DIR, "_work", "_probe3", "Lobby_29b1b7b7353f6501aafd6fc66cdc6964_diag_asm.swf")
# Official original only. The diag_asm build injects RemoteLogPost probes into
# LobbyLoader.bytesLoadComplete and must not be used for render validation.
LOCAL_LOBBY = os.environ.get('SSJJ_LOBBY_SWF') or LOCAL_LOBBY_ORIGINAL
# A/B 开关：SSJJ_LOBBY_SWF=<路径> 可强制指定要发的 Lobby 本体。
# 默认固定为官方未插桩 Lobby_0312bff9…swf；diag_asm 仅作为历史诊断产物保留，
# 不再参与默认分发。其文件名 hash 与自身字节一致，md5 首请求即通过。
LOCAL_RESC_LOCAL = os.path.join(ROOT_DIR, "_work", "lobby_host", "res_config_local.xml")
MAIN_VIEW_DEC = os.path.join(ROOT_DIR, "_work", "lobby_ui", "view_dec", "mainView.dec.xml")

UNITY_VERSION = "76376c1d1efcf9fdc47cba965130b916_20261022110940"
UNITY_MIRROR = r"D:\SSJJ\asset_mirror\Windows"
UNITY_CACHE = r"D:\SSJJ\cache"
UNITY_MANIFEST = os.path.join(UNITY_MIRROR, "AssetBundles_" + UNITY_VERSION + "2019.manifest")
RESOURCE_ROOT = os.path.join(ROOT_DIR, "资源全集")
LOG_FILE = os.path.join(ROOT_DIR, "Game-SSJJ-logs", "gateway.log")

WEAPON_PNG_DIR = os.path.join(ROOT_DIR, "lobby-launcher", "assets", "previews", "weapons")
WEAPON_PNG_FILES = {}
if os.path.isdir(WEAPON_PNG_DIR):
    for fn in os.listdir(WEAPON_PNG_DIR):
        if fn.lower().endswith('.png'):
            WEAPON_PNG_FILES[fn.lower()] = os.path.join(WEAPON_PNG_DIR, fn)

WEAPON_MAP = {}
try:
    _wmap_path = os.path.join(ROOT_DIR, "_work", "lobby_host", "shop_weapon_map.json")
    if os.path.isfile(_wmap_path):
        WEAPON_MAP = json.load(open(_wmap_path, encoding="utf-8"))
except Exception:
    pass

os.makedirs(CACHE, exist_ok=True)
os.makedirs(UNITY_MIRROR, exist_ok=True)
os.makedirs(UNITY_CACHE, exist_ok=True)
os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

# --- Authoritative resource contract -------------------------------------
# res_config_local.xml is the client's own manifest: every <name url=... md5=...
# size=...> row is what the preloader will verify a delivery against. Serving a
# byte stream that does not match it makes the client fail the check and retry
# five times before onLoadError, which leaves the resource queue unfinished and
# the "正在加载资源..." panel up forever. The dirs below therefore cannot be
# consulted on a first-match-wins basis; the declared hash decides.
RES_CONTRACT = {}
_MD5_CACHE = {}
# 实验开关：SSJJ_PREPARED_FOR=<key1,key2>
# 对这些资源改发 cache_prepared/ 版（DoABC 已剥离），并把契约里的 md5/size
# 同步改成该版的真实值，保证客户端的完整性校验能通过。
# key -> (old_md5, old_size, new_md5, new_size)
PREPARED_FORCE = {}

def build_res_contract():
    """Map resource path -> (md5, size) from the local res_config."""
    global RES_CONTRACT
    contract = {}
    try:
        with open(LOCAL_RESC_LOCAL, 'r', encoding='utf-8', errors='replace') as f:
            xml = f.read()
    except Exception as ex:
        print(f"[Gateway] res contract unavailable: {ex}", flush=True)
        return
    for m in re.finditer(r'<([A-Za-z0-9_]+)\s+url="([^"]+)"[^>]*?md5="([0-9a-fA-F]{32})"[^>]*?size="(\d+)"', xml):
        contract[m.group(2).replace('/', '_')] = (m.group(3).lower(), int(m.group(4)))
    RES_CONTRACT = contract
    print(f"[Gateway] res contract loaded: {len(contract)} entries", flush=True)

    forced = [x.strip() for x in os.environ.get("SSJJ_PREPARED_FOR", "").split(",") if x.strip()]
    if os.environ.get("SSJJ_KEEP_SENSITIVE_FILTER", "") != "1":
        for k in (
            "config_dirtyWords_22f10d057903220ec12df1f0455c6cde",
            "template_DirtySensitiveWord_972448c26d2b764aa6551486e3ae5377.bin",
        ):
            if k not in forced and os.path.isfile(os.path.join(PREPARED_DIR, k)):
                forced.append(k)
    for k in forced:
        p = os.path.join(PREPARED_DIR, k)
        if not os.path.isfile(p):
            print(f"[Gateway] PREPARED_FORCE skip (missing): {k}", flush=True)
            continue
        old = contract.get(k)
        new = (file_md5(p), os.path.getsize(p))
        if old is None:
            print(f"[Gateway] PREPARED_FORCE skip (no contract row): {k}", flush=True)
            continue
        RES_CONTRACT[k] = new
        PREPARED_FORCE[k] = (old[0], old[1], new[0], new[1])
        print(f"[Gateway] PREPARED_FORCE {k}: {old} -> {new}", flush=True)

def file_md5(path):
    try:
        st = os.stat(path)
        key = (path, st.st_mtime_ns, st.st_size)
        hit = _MD5_CACHE.get(key)
        if hit is not None:
            return hit
        h = hashlib.md5()
        with open(path, 'rb') as f:
            for chunk in iter(lambda: f.read(1 << 20), b''):
                h.update(chunk)
        digest = h.hexdigest()
        _MD5_CACHE[key] = digest
        return digest
    except Exception:
        return None

def pick_by_contract(key, candidates):
    """Return the first candidate whose bytes satisfy the declared md5/size.

    candidates is an ordered list of (label, path). When the manifest has no
    row for this key we fall back to the first existing file so unrelated
    assets keep their previous behaviour.
    """
    expect = RES_CONTRACT.get(key)
    if expect is None:
        # Not described by the manifest: caller falls through to the legacy
        # plain/ -> cache_prepared/ -> cache/ order unchanged.
        return None
    for label, path in candidates:
        if not (path and os.path.isfile(path)):
            continue
        want_md5, want_size = expect
        if os.path.getsize(path) != want_size:
            continue
        if file_md5(path) == want_md5:
            return path
    return None

def contract_conflicts(key, candidates):
    """Paths that exist for this key but were rejected by the manifest check."""
    expect = RES_CONTRACT.get(key)
    if expect is None:
        return []
    out = []
    for label, path in candidates:
        if path and os.path.isfile(path):
            out.append(f"{label}:{os.path.getsize(path)}")
    return out

# Build Master Asset Pool (13,558 assets)
ASSET_POOL = {}
HASH_POOL = {}
DISK_BUNDLE_BY_NAME = {}
PATCHED_MANIFEST_BYTES = None
WEAPON_3D_FALLBACK = None

def _index_bundle_tree(root_dir):
    if not os.path.isdir(root_dir):
        return
    for r, _, fs in os.walk(root_dir):
        for fn in fs:
            if fn.endswith('.bak') or '.bak' in fn:
                continue
            fp = os.path.join(r, fn)
            rel = os.path.relpath(fp, root_dir).replace('\\', '/')
            ASSET_POOL.setdefault(rel, fp)
            ASSET_POOL.setdefault(fn, fp)
            if '_' in fn:
                b_rel, md5_part = rel.rsplit('_', 1)
                if len(md5_part) == 32:
                    h_low = md5_part.lower()
                    HASH_POOL.setdefault(h_low, fp)
                    DISK_BUNDLE_BY_NAME.setdefault(b_rel.lower(), (h_low, fp, os.path.getsize(fp)))
                    ASSET_POOL.setdefault(b_rel, fp)

def index_assets():
    global WEAPON_3D_FALLBACK, PATCHED_MANIFEST_BYTES
    battle_sa = r"D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows"
    _index_bundle_tree(battle_sa)
    _index_bundle_tree(RESOURCE_ROOT)

    if os.path.isdir(RESOURCE_ROOT):
        for cat in os.listdir(RESOURCE_ROOT):
            cp = os.path.join(RESOURCE_ROOT, cat)
            if os.path.isdir(cp):
                for fn in os.listdir(cp):
                    fp = os.path.join(cp, fn)
                    ASSET_POOL[f"{cat}/{fn}"] = fp
                    ASSET_POOL[fn] = fp
                    if '_' in fn:
                        md5_part = fn.split('_')[-1].lower()
                        if len(md5_part) == 32:
                            HASH_POOL[md5_part] = fp
                    base = fn.split('_')[0]
                    if f"{cat}/{base}" not in ASSET_POOL:
                        ASSET_POOL[f"{cat}/{base}"] = fp
                    if base not in ASSET_POOL:
                        ASSET_POOL[base] = fp
                    if 'weapon' in fn.lower() or 'dagger' in fn.lower():
                        if not WEAPON_3D_FALLBACK and os.path.getsize(fp) > 5000:
                            WEAPON_3D_FALLBACK = fp

    for cache_dir in (
        UNITY_CACHE,
        r"C:\Users\Mahuilai\AppData\LocalLow\Wooduan\生死狙击微端战斗\Preload",
        r"C:\Users\Mahuilai\AppData\LocalLow\Wooduan\创想兵团\Preload",
    ):
        if os.path.isdir(cache_dir):
            for fn in os.listdir(cache_dir):
                fp = os.path.join(cache_dir, fn)
                if os.path.isfile(fp):
                    if len(fn) == 32: HASH_POOL[fn.lower()] = fp
                    ASSET_POOL.setdefault(fn, fp)
                elif os.path.isdir(fp):
                    subdata = os.path.join(fp, "data")
                    if os.path.isfile(subdata) and len(fn) == 32:
                        HASH_POOL[fn.lower()] = subdata

    if os.path.isfile(UNITY_MANIFEST):
        try:
            m_txt = open(UNITY_MANIFEST, 'r', encoding='utf-8', errors='replace').read()
            patched_cnt = 0
            pat = re.compile(r'(<AssetBundle\b[^>]*?\bmd5=")([0-9a-fA-F]{32})("[^>]*?\bname=")([^"]+)("[^>]*?\bsize=")(\d+)(")')
            def _repl(m):
                nonlocal patched_cnt
                old_h = m.group(2).lower()
                bname = m.group(4)
                if old_h not in HASH_POOL and bname.lower() in DISK_BUNDLE_BY_NAME:
                    new_h, _, new_sz = DISK_BUNDLE_BY_NAME[bname.lower()]
                    patched_cnt += 1
                    return f"{m.group(1)}{new_h}{m.group(3)}{bname}{m.group(5)}{new_sz}{m.group(7)}"
                return m.group(0)
            m_txt = pat.sub(_repl, m_txt)
            PATCHED_MANIFEST_BYTES = m_txt.encode('utf-8')
            print(f"[Gateway] Patched {patched_cnt} manifest bundle hashes to match local disk bundles.", flush=True)
        except Exception as e:
            print(f"[Gateway] Manifest patch warn: {e}", flush=True)
    print(f"[Gateway] Master Asset Pool ready: {len(ASSET_POOL)} keys, {len(HASH_POOL)} hashes mapped! (100% OFFLINE)", flush=True)

index_assets()

# Dynamic Pure-Vector SWF Generator (Tag 35 + 2 + 26 + 1, 0% DoABC, 100% AIR Compatible)
TPL_WEAPON_SWF = os.path.join(CACHE, "resource_swf_WeaponAssets_weapon_001.swf")
TPL_BYTES = open(TPL_WEAPON_SWF, "rb").read() if os.path.isfile(TPL_WEAPON_SWF) else None
WEAPON_SWF_PREPARED_CACHE = {}

def _pack_swf_tag(tag_type, tag_data):
    if len(tag_data) < 0x3f:
        return struct.pack('<H', (tag_type << 6) | len(tag_data)) + tag_data
    return struct.pack('<H I', (tag_type << 6) | 0x3f, len(tag_data)) + tag_data

def _read_swf_tags(dec, pos):
    tags = []
    while pos + 2 <= len(dec):
        header = struct.unpack_from('<H', dec, pos)[0]
        pos += 2
        tag_type, tag_len = header >> 6, header & 0x3f
        if tag_len == 0x3f:
            if pos + 4 > len(dec):
                raise ValueError('truncated SWF long tag length')
            tag_len = struct.unpack_from('<I', dec, pos)[0]
            pos += 4
        if pos + tag_len > len(dec):
            raise ValueError('truncated SWF tag payload')
        tags.append((tag_type, dec[pos:pos + tag_len]))
        pos += tag_len
        if tag_type == 0:
            break
    return tags

def _primary_weapon_symbol_id(tags):
    defined = set()
    for tag_type, body in tags:
        if tag_type in (2, 6, 20, 21, 22, 32, 35, 36, 39, 83, 90) and len(body) >= 2:
            defined.add(struct.unpack_from('<H', body)[0])

    # The template's root shape is placed on frame 1 by PlaceObject2. Export
    # that character so LoaderInfo.applicationDomain.getDefinition resolves it.
    for tag_type, body in tags:
        if tag_type == 26 and len(body) >= 5 and (body[0] & 0x02):
            character_id = struct.unpack_from('<H', body, 3)[0]
            if character_id in defined:
                return character_id
        elif tag_type == 4 and len(body) >= 2:
            character_id = struct.unpack_from('<H', body)[0]
            if character_id in defined:
                return character_id
    return next(iter(defined), 1)

def _sprite_wrap(tags, symbol_id):
    """Bind the exported name to a one-frame Sprite wrapping the icon artwork."""
    used = set()
    for tag_type, body in tags:
        if tag_type in (2, 6, 20, 21, 22, 32, 35, 36, 39, 83, 90) and len(body) >= 2:
            used.add(struct.unpack_from('<H', body)[0])
    for tag_type, body in tags:
        if tag_type == 39 and len(body) >= 4 and struct.unpack_from('<H', body)[0] == symbol_id:
            return tags, symbol_id

    sprite_id = (max(used) + 1) if used else 1
    sprite_body = (
        struct.pack('<HH', sprite_id, 1)
        + _pack_swf_tag(26, bytes([0x02]) + struct.pack('<HH', 1, symbol_id))  # PlaceObject2(flags, depth, charId)
        + _pack_swf_tag(1, b'')
    )
    output = []
    inserted = False
    for tag_type, body in tags:
        if tag_type in (1, 0) and not inserted:
            output.append((39, sprite_body))
            inserted = True
        output.append((tag_type, body))
    if not inserted:
        output.append((39, sprite_body))
    return output, sprite_id

def _ensure_weapon_export(tags, export_name):
    if not export_name:
        return tags, False

    symbol_id = _primary_weapon_symbol_id(tags)
    tags, symbol_id = _sprite_wrap(tags, symbol_id)
    changed = False
    output = []
    symbol_tag_written = False

    def build_symbol_class(body):
        nonlocal changed
        entries = []
        if len(body) < 2:
            raise ValueError('invalid SWF SymbolClass tag')
        count = struct.unpack_from('<H', body)[0]
        offset = 2
        for _ in range(count):
            if offset + 2 > len(body):
                raise ValueError('truncated SWF SymbolClass record')
            current_id = struct.unpack_from('<H', body, offset)[0]
            offset += 2
            end = body.find(b'\0', offset)
            if end < 0:
                raise ValueError('unterminated SWF SymbolClass name')
            current_name = body[offset:end].decode('utf-8', errors='replace')
            offset = end + 1
            if current_id == symbol_id or current_name == export_name:
                if current_id == symbol_id and current_name == export_name:
                    entries.append((current_id, current_name))
                    changed = changed or current_name != export_name
                else:
                    changed = True
                continue
            entries.append((current_id, current_name))
        if not any(current_id == symbol_id and current_name == export_name for current_id, current_name in entries):
            entries.append((symbol_id, export_name))
            changed = True
        encoded = bytearray(struct.pack('<H', len(entries)))
        for current_id, current_name in entries:
            encoded.extend(struct.pack('<H', current_id))
            encoded.extend(current_name.encode('utf-8') + b'\0')
        return bytes(encoded)

    for tag_type, body in tags:
        if tag_type == 69 and len(body) >= 4:
            attributes = struct.unpack_from('<I', body)[0]
            # SymbolClass names are AS3 class exports; keep the SWF marked as
            # ActionScript 3 while the generated icon contains no executable ABC.
            updated_attributes = attributes | 0x08
            if updated_attributes != attributes:
                body = struct.pack('<I', updated_attributes) + body[4:]
                changed = True
        if tag_type == 76 and not symbol_tag_written:
            body = build_symbol_class(body)
            output.append((tag_type, body))
            symbol_tag_written = True
            continue
        if tag_type in (1, 0) and not symbol_tag_written:
            output.append((76, build_symbol_class(b'\x00\x00')))
            symbol_tag_written = True
        output.append((tag_type, body))

    if not symbol_tag_written:
        output.append((76, build_symbol_class(b'\x00\x00')))
    return output, changed

def _encode_swf(dec, header_end, tags):
    body = bytearray(dec[:header_end])
    for tag_type, tag_data in tags:
        body.extend(_pack_swf_tag(tag_type, tag_data))
    # SWF body starts with the FWS signature; the compressed container keeps the
    # same 8-byte header but must declare the uncompressed length, so rewrite
    # bytes 0..7 in place instead of concatenating a second length field.
    body[0:3] = b'CWS'
    struct.pack_into('<I', body, 4, len(body))
    return bytes(body[:8]) + zlib.compress(bytes(body[8:]))

def _swf_parses(data):
    """True only if the whole SWF header, tag stream and declared length agree."""
    if not data or data[:3] not in (b'CWS', b'FWS'):
        return False
    try:
        if data[:3] == b'CWS':
            dec = b'FWS' + data[3:8] + zlib.decompress(data[8:])
        else:
            dec = data
        if struct.unpack_from('<I', dec, 4)[0] != len(dec):
            return False
        nbits = dec[8] >> 3
        _read_swf_tags(dec, (5 + nbits * 4 + 7) // 8 + 12)
        return True
    except Exception:
        return False

def make_weapon_swf(png_path, export_name=None):
    if not TPL_BYTES or Image is None: return None
    try:
        im = Image.open(png_path).convert('RGBA')
        canvas = Image.new('RGBA', (175, 55), (0, 0, 0, 0))
        im.thumbnail((175, 55), Image.Resampling.LANCZOS)
        x = (175 - im.width) // 2
        y = (55 - im.height) // 2
        canvas.paste(im, (x, y))
        
        rgb = canvas.convert('RGB')
        buf = io.BytesIO()
        rgb.save(buf, format='JPEG', quality=92)
        jpg_data = buf.getvalue()
        
        alpha_bytes = bytes([p[3] for p in canvas.getdata()])
        comp_alpha = zlib.compress(alpha_bytes)
        
        tag35_body = struct.pack('<H I', 1, len(jpg_data)) + jpg_data + comp_alpha
        if len(tag35_body) >= 0x3f:
            tag35 = struct.pack('<H I', (35 << 6) | 0x3f, len(tag35_body)) + tag35_body
        else:
            tag35 = struct.pack('<H', (35 << 6) | len(tag35_body)) + tag35_body
            
        dec = b'FWS' + TPL_BYTES[3:8] + zlib.decompress(TPL_BYTES[8:])
        pos = 8
        nbits = dec[pos] >> 3
        rect_bytes = (5 + nbits * 4 + 7) // 8
        pos += rect_bytes + 4
        
        tags = _read_swf_tags(dec, pos)
        tags = [(tag_type, tag35_body if tag_type == 35 else tag_data)
                for tag_type, tag_data in tags]
        # A timeline-only icon must not carry an AS3 SymbolClass: the class name
        # has no matching DoABC definition, so AIR fails to link it and renders
        # an empty cell. Keep the generated SWF display-only.
        return _encode_swf(dec, pos, tags)
    except Exception as e:
        return None

def prepare_weapon_swf(data, export_name=None):
    """Validate and pass through a native timeline weapon icon byte-for-byte.

    Genuine Tag 76 exports are preserved exactly; no Tag 76 is ever synthesized,
    because official WeaponAssets icons have no DoABC to back such a class.
    """
    try:
        if data[:3] == b'CWS':
            dec = b'FWS' + data[3:8] + zlib.decompress(data[8:])
        elif data[:3] == b'FWS':
            dec = data
        else:
            return None

        pos = 8
        nbits = dec[pos] >> 3
        pos += (5 + nbits * 4 + 7) // 8 + 4
        header_end = pos
        tags = _read_swf_tags(dec, pos)
        has_art = False
        has_placement = False
        has_frame = False
        for tag_type, tag_data in tags:
            if tag_type in (2, 6, 20, 21, 22, 32, 35, 36, 39, 83, 90):
                has_art = True
            if tag_type in (4, 26, 70, 94):
                has_placement = True
            if tag_type == 1:
                has_frame = True

        if not (has_art and has_placement and has_frame):
            return None
        # Official WeaponAssets icons are timeline-only SWFs: FileAttributes is
        # normally 0x10 (no AS3 flag), there is no DoABC, and the artwork is
        # placed on frame 1. Loader.content renders that timeline directly.
        # Adding SymbolClass here would create an AS3 export with no backing
        # class and AIR would reject the load, producing the black empty slot.
        # Return the native bytes unchanged so any genuine Tag 76 is preserved
        # exactly and no invalid Tag 76 is ever invented.
        return data
    except Exception:
        return None

def get_prepared_weapon_swf(path, export_name=None):
    try:
        stat = os.stat(path)
        key = (path, stat.st_mtime_ns, stat.st_size, export_name)
        if key in WEAPON_SWF_PREPARED_CACHE:
            return WEAPON_SWF_PREPARED_CACHE[key]
        for stale_key in list(WEAPON_SWF_PREPARED_CACHE):
            if stale_key[0] == path and stale_key[3] != export_name:
                del WEAPON_SWF_PREPARED_CACHE[stale_key]
        with open(path, 'rb') as f:
            prepared = prepare_weapon_swf(f.read(), export_name)
        WEAPON_SWF_PREPARED_CACHE[key] = prepared
        return prepared
    except Exception:
        return None

def resolve_weapon_swf_path(p):
    """Resolve a prebuilt WeaponAssets SWF for direct static-file serving."""
    key = p.replace('/', '_')
    # Native cached SWF first: it is the official timeline asset and needs no
    # rewriting. Generated copies are only a last-resort fallback.
    cache_file = os.path.join(CACHE, key)
    if os.path.isfile(cache_file) and os.path.getsize(cache_file) >= 200:
        return cache_file
    prepared_file = os.path.join(PREPARED_DIR, key)
    if os.path.isfile(prepared_file) and os.path.getsize(prepared_file) >= 200:
        return prepared_file
    return None

def log_req(msg):
    try:
        with open(LOG_FILE, 'a', encoding='utf-8') as f:
            f.write(f"{time.strftime('%H:%M:%S')} {msg}\n")
    except Exception:
        pass

def _ensure_avm2_timeline_swf(data):
    """Ensure a timeline-only icon SWF has FileAttributes.ActionScript3=1 and no
    orphaned SymbolClass without DoABC, so UIAssetsLoader.completeHandler can
    reparent loader.content via addChild(_content) without ArgumentError #2180.
    """
    try:
        if data[:3] == b'CWS':
            dec = b'FWS' + data[3:8] + zlib.decompress(data[8:])
        elif data[:3] == b'FWS':
            dec = data
        else:
            return data
        while len(dec) > 16 and dec[8:11] in (b'FWS', b'CWS'):
            if dec[8:11] == b'CWS':
                dec = b'FWS' + dec[11:16] + zlib.decompress(dec[16:])
            else:
                dec = dec[8:]
        pos = 8
        nbits = dec[pos] >> 3
        header_end = pos + (5 + nbits * 4 + 7) // 8 + 4
        tags = _read_swf_tags(dec, header_end)
        has_abc = any(t in (72, 82) for t, _ in tags)
        changed = False
        new_tags = []
        has_file_attr = False
        for t, body in tags:
            if t == 69 and len(body) >= 4:
                has_file_attr = True
                attr = struct.unpack_from('<I', body)[0]
                if not (attr & 0x08):
                    body = struct.pack('<I', attr | 0x08) + body[4:]
                    changed = True
                new_tags.append((t, body))
            elif t == 76 and not has_abc:
                changed = True
                continue
            else:
                new_tags.append((t, body))
        if not has_file_attr:
            new_tags.insert(0, (69, struct.pack('<I', 0x08)))
            changed = True
        if not changed:
            return data
        return _encode_swf(dec, header_end, new_tags)
    except Exception:
        return data

class GatewayHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def do_HEAD(self):
        self.do_GET()

    def _serve_bytes(self, data, ctype='application/octet-stream'):
        log_req(f"    -> 200 {len(data)}")
        self.send_response(200)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def send_error(self, code, message=None, explain=None):
        log_req(f"    -> {code} {message or ''}")
        return super().send_error(code, message, explain)

    def _serve(self, path, ctype=None):
        try:
            if ctype is None:
                if path.endswith('.swf'): ctype = 'application/x-shockwave-flash'
                elif path.endswith('.xml'): ctype = 'text/xml'
                elif path.endswith('.png'): ctype = 'image/png'
                elif path.endswith('.jpg') or path.endswith('.jpeg'): ctype = 'image/jpeg'
                elif path.endswith('.json'): ctype = 'application/json'
                else: ctype = 'application/octet-stream'
            with open(path, 'rb') as f:
                data = f.read()
            bn = os.path.basename(path)
            if path.endswith('.swf') and (bn.startswith('resource_swf_') or 'resource/swf/' in self.path):
                data = _ensure_avm2_timeline_swf(data)
            self._serve_bytes(data, ctype)
        except Exception as e:
            self.send_error(500, str(e))

    def do_GET(self):
        p = urllib.parse.urlparse(self.path).path.lstrip('/')
        log_req(f"GET {p}")

        # [PATCH 2026-11-01] Flash/AIR 沙箱策略文件。
        # AIR 的 URLLoader（RemoteLogPost.post -> log_error）访问 http 域名时，
        # 找不到 crossdomain.xml 会**同步抛 SecurityError**，异常从
        # RemoteLogPost.postMsg 的 catch 块传播出去，打断
        # LoadResQueue.filterUnLoadedQueueByResNames ->
        # REMOVE_RES_LOADING_PANEL 永不到达 -> 卡在开屏海报/黑屏。
        # AIR 会先请求所在目录下的 crossdomain.xml，这里对任意路径都返回同一份。
        if p == 'crossdomain.xml' or p.endswith('/crossdomain.xml'):
            body = (b'<?xml version="1.0"?>\n'
                    b'<!DOCTYPE cross-domain-policy SYSTEM '
                    b'"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">\n'
                    b'<cross-domain-policy>\n'
                    b'  <site-control permitted-cross-domain-policies="master-only"/>\n'
                    b'  <allow-access-from domain="*" secure="false"/>\n'
                    b'  <allow-http-request-headers-from domain="*" headers="*"/>\n'
                    b'</cross-domain-policy>\n')
            self.send_response(200)
            self.send_header('Content-Type', 'text/xml')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        # 实验：被强制走 prepared 版的资源优先直接发（契约已在 build_res_contract 里同步改过）
        _k0 = p.replace('/', '_')
        if _k0 in PREPARED_FORCE:
            return self._serve(os.path.join(PREPARED_DIR, _k0), 'application/x-shockwave-flash')

        if p == 'probe':
            q = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            msg = q.get('msg', [''])[0]
            if msg:
                try:
                    with open(os.path.join(ROOT_DIR, "Game-SSJJ-logs", "probe.log"), 'a', encoding='utf-8') as pf:
                        pf.write(f"{time.strftime('%H:%M:%S')} [PROBE] {msg}\n")
                except Exception:
                    pass
            self._serve_bytes(b'ok', 'text/plain')
            return

        if p.endswith('version.php'):
            self._serve_bytes(UNITY_VERSION.encode(), 'text/plain')
            return

        if 'AssetBundles_' in p and p.endswith('.manifest'):
            if PATCHED_MANIFEST_BYTES is not None:
                return self._serve_bytes(PATCHED_MANIFEST_BYTES, 'text/xml')
            if os.path.isfile(UNITY_MANIFEST):
                return self._serve(UNITY_MANIFEST, 'text/xml')

        if 'Windows/' in p:
            name = p.split('Windows/', 1)[1]
            if name in ASSET_POOL:
                return self._serve(ASSET_POOL[name], 'application/octet-stream')
            base_fn = os.path.basename(name)
            if base_fn in ASSET_POOL:
                return self._serve(ASSET_POOL[base_fn], 'application/octet-stream')

            target_md5 = None
            if '_' in name:
                cand = name.split('_')[-1].lower()
                if len(cand) == 32:
                    target_md5 = cand
            elif len(base_fn) == 32:
                target_md5 = base_fn.lower()

            if target_md5:
                if target_md5 in HASH_POOL:
                    return self._serve(HASH_POOL[target_md5], 'application/octet-stream')
                c_data = os.path.join(UNITY_CACHE, target_md5, "data")
                if os.path.isfile(c_data):
                    return self._serve(c_data, 'application/octet-stream')
                ll_data = os.path.join(r"C:\Users\Mahuilai\AppData\LocalLow\Wooduan\创想兵团\Preload", target_md5, "data")
                if os.path.isfile(ll_data):
                    return self._serve(ll_data, 'application/octet-stream')

            local = os.path.join(UNITY_MIRROR, name.replace('/', os.sep))
            if os.path.isfile(local):
                return self._serve(local, 'application/octet-stream')

            c_name = os.path.join(UNITY_CACHE, os.path.basename(name))
            if os.path.isfile(c_name):
                return self._serve(c_name, 'application/octet-stream')

            clean_name = name.split('$')[0].rstrip('/')
            base_key = os.path.basename(clean_name)
            if clean_name in ASSET_POOL:
                return self._serve(ASSET_POOL[clean_name], 'application/octet-stream')
            if base_key in ASSET_POOL:
                return self._serve(ASSET_POOL[base_key], 'application/octet-stream')

            return self.send_error(404)

        if p == 'config/hall_config.xml': return self._serve(LOCAL_HALL, 'text/xml')
        if p.startswith('Lobby_') and p.endswith('.swf'): return self._serve(LOCAL_LOBBY, 'application/x-shockwave-flash')

        # [R1 & R3 PATCH] Stage3D ClientView Engine & 3D Model SWFs
        if p.startswith('ClientView_') or p.startswith('RenderThread_') or p == 'ClientView.swf' or p == 'RenderThread.swf':
            cv_path = os.path.join(ROOT_DIR, "资源下载", "大厅资源", "SSJJ-main", "output", "swf", "ClientView_cb90b1c9823af027e0536313e50106e4.swf")
            if os.path.isfile(cv_path):
                return self._serve(cv_path, 'application/x-shockwave-flash')

        if p.startswith('LobbyModelView') or p.startswith('LobbyWeaponView'):
            empty_swf = os.path.join(ROOT_DIR, "_work", "flexsdk", "frameworks", "javascript", "FABridge", "samples", "EmptySwf.swf")
            if os.path.isfile(empty_swf):
                return self._serve(empty_swf, 'application/x-shockwave-flash')
            minimal_swf = bytes.fromhex("4657530e250000007800055f00000fa000000c010044110800000040000000")
            return self._serve_bytes(minimal_swf, 'application/x-shockwave-flash')
        if p == 'FLUI_ASSETS_dec.swf':
            return self._serve(os.path.join(ROOT_DIR, '_work', 'lobby_host', 'cache', 'FLUI_ASSETS_dec.swf'), 'application/x-shockwave-flash')
        if p == 'ComponentAssets_dec.swf':
            return self._serve(os.path.join(ROOT_DIR, '_work', 'lobby_host', 'cache_prepared', 'resource_flas_ComponentAssets_062df38ddb6b6e778a8e00d792df7bcf.swf'), 'application/x-shockwave-flash')
        if p == 'RightButtonAssets_dec.swf':
            return self._serve(os.path.join(ROOT_DIR, '_work', 'lobby_host', 'cache_prepared', 'resource_flas_RightButtonAssets_bf3fe9c74d592220229f27b11e534ed6.swf'), 'application/x-shockwave-flash')
        if p == 'HallModelAssets_dec.swf':
            return self._serve(os.path.join(ROOT_DIR, '_work', 'lobby_host', 'cache_prepared', 'resource_flas_HallModelAssets_051e678bb680fd0609ad61503d71d9da.swf'), 'application/x-shockwave-flash')
        if p == 'config/res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml':
            # 有强制 prepared 的资源时，必须同步改写它声明的 md5/size，
            # 否则客户端按旧值校验会失败、重试 5 次后 onLoadError。
            #
            # [PATCH 2026-11-01] 原实现用 `txt.replace(omd5, nmd5)` 全局替换，
            # 而同一个 md5 在官方 res_config 里同时出现在 url= 和 md5= 两个属性中，
            # 替换把 URL 也改成了 prepared 版的文件名 -> 客户端请求
            # <name>_<prepared_md5>.swf，网关按原 md5 拼 key -> 文件名对不上
            # -> 404 -> "loader, resource load error"。现在只改属性值，
            # URL 保持官方原样。
            if PREPARED_FORCE:
                try:
                    txt = open(LOCAL_RESC_LOCAL, encoding='utf-8', errors='replace').read()
                    for k, (omd5, osz, nmd5, nsz) in PREPARED_FORCE.items():
                        txt = re.sub(r'(\smd5=")' + re.escape(omd5) + r'(")',
                                     r'\g<1>' + nmd5 + r'\g<2>', txt)
                        txt = re.sub(r'(\ssize=")' + str(osz) + r'(")',
                                     r'\g<1>' + str(nsz) + r'\g<2>', txt)
                    return self._serve_bytes(txt.encode('utf-8'), 'text/xml')
                except Exception as ex:
                    log_req(f"    !! res_config patch failed: {ex}")
            return self._serve(LOCAL_RESC_LOCAL, 'text/xml')
        # [PATCH 2026-11-01] 契约分发前置。
        #
        # res_config 的 md5/size/compress/encode 描述的是 **CDN 上的字节**，
        # 客户端流程是：先按 md5 校验原始字节 -> 再按 encode/compress 决定是否
        # swfDecode + uncompress。所以网关必须下发**契约原样**的字节，让客户端
        # 走它自己的解密路径。
        #
        # 之前的 bug：NewMainView 特判分支在这里之前就 return 了 plain/ 下的
        # 11415 B 压缩态 XML，而 res_config 被 apply_plain_manifest() 标成
        # encode="false" compress="false" -> 客户端不解密 -> XML() 解析压缩字节
        # -> analysisLoadDataError resName:mainView,type:XML -> 资源队列卡死
        # -> 幕布不移除 -> 黑屏。
        #
        # cdn_pristine/ 与 plain/ 里的 848 条已按官方 res_config 契约
        # (md5+size) 逐条校验通过，全部命中，0 缺失。
        key = p.replace('/', '_')
        ordered = [
            ('decrypted', os.path.join(DECRYPTED_DIR, key)),
            ('plain', os.path.join(PLAIN_DIR, key)),
            ('cache', os.path.join(CACHE, key)),
            ('prepared', os.path.join(PREPARED_DIR, key)),
            ('pristine', os.path.join(PRISTINE_DIR, key)),
        ]
        chosen = pick_by_contract(key, ordered)
        if chosen:
            return self._serve(chosen)

        rejected = contract_conflicts(key, ordered)
        if rejected:
            log_req(f"    !! contract mismatch for {key} -> {', '.join(rejected)}")

        if 'NewMainView_4bd8246c78fc282a9d9a41d6cb18944e.xml' in p:
            plain_xml = os.path.join(PLAIN_DIR, "resource_view_NewMainView_4bd8246c78fc282a9d9a41d6cb18944e.xml")
            if os.path.isfile(plain_xml):
                return self._serve(plain_xml, "text/xml")
            orig_xml = os.path.join(CACHE, "resource_view_NewMainView_4bd8246c78fc282a9d9a41d6cb18944e.xml")
            if os.path.isfile(orig_xml):
                return self._serve(orig_xml, 'text/xml')

        if 'BagView_9846bc3c853d01d233aa0e531680746f.xml' in p:
            plain_xml = os.path.join(PLAIN_DIR, "resource_view_BagView_9846bc3c853d01d233aa0e531680746f.xml")
            if os.path.isfile(plain_xml):
                return self._serve(plain_xml, "text/xml")
            dec_xml = os.path.join(ROOT_DIR, "_work", "lobby_host", "decrypted", "resource_view_BagView_9846bc3c853d01d233aa0e531680746f.xml")
            if os.path.isfile(dec_xml):
                return self._serve(dec_xml, 'text/xml')

        # WeaponAssets are prebuilt and served from disk; the request handler
        # never rewrites, recompresses or synthesizes an SWF.
        if 'WeaponAssets' in p:
            static_swf = resolve_weapon_swf_path(p)
            if static_swf:
                return self._serve(static_swf, 'application/x-shockwave-flash')

        # SkinAssets handling
        if 'SkinAssets' in p:
            cache_file = os.path.join(CACHE, p.replace('/', '_'))
            if os.path.isfile(cache_file) and os.path.getsize(cache_file) >= 500:
                return self._serve(cache_file, 'application/x-shockwave-flash')
            skin_name = os.path.basename(p)
            for skin_dir in (
                os.path.join(ROOT_DIR, "资源下载", "大厅资源", "ssjj-lobby-src", "SSJJ-离线大厅", "mirror", "s10", "resource", "swf", "SkinAssets"),
                os.path.join(ROOT_DIR, "offline-lobby-rebuild", "dist", "resource", "swf", "SkinAssets"),
            ):
                candidate = os.path.join(skin_dir, skin_name)
                if os.path.isfile(candidate) and os.path.getsize(candidate) >= 500:
                    return self._serve(candidate, 'application/x-shockwave-flash')
            if skin_name in ASSET_POOL and os.path.getsize(ASSET_POOL[skin_name]) >= 500:
                return self._serve(ASSET_POOL[skin_name], 'application/x-shockwave-flash')
            tpl_skin = os.path.join(CACHE, "resource_swf_SkinAssets_skin_118_1.swf")
            if os.path.isfile(tpl_skin):
                return self._serve(tpl_skin, 'application/x-shockwave-flash')

        # TitleIcon handling
        if 'titleIcon' in p:
            cache_file = os.path.join(CACHE, p.replace('/', '_'))
            if os.path.isfile(cache_file) and os.path.getsize(cache_file) >= 500:
                return self._serve(cache_file, 'application/x-shockwave-flash')
            tpl_title = os.path.join(CACHE, "resource_swf_titleIcon_title_40001.swf")
            if os.path.isfile(tpl_title):
                return self._serve(tpl_title, 'application/x-shockwave-flash')

        # Fallbacks for assets the manifest does not describe.
        # 契约可能**故意**声明 size=0（如 config/i18n_next_*.txt，其 md5 就是空串的
        # d41d8cd98f00b204e9800998ecf8427e），此时空文件才是正确资源，不能当坏文件跳过；
        # 反过来，契约声明了非 0 大小时，空文件绝不该被发出。一律以契约声明为准。
        expect = RES_CONTRACT.get(key)
        allow_empty = bool(expect is not None and expect[1] == 0)
        for label, path in ordered:
            if not os.path.isfile(path):
                continue
            if os.path.getsize(path) == 0 and not allow_empty:
                continue
            return self._serve(path)

        prepared_asset = os.path.join(PREPARED_DIR, key)
        if p.startswith('resource/flas/') and os.path.isfile(prepared_asset):
            return self._serve(prepared_asset, 'application/x-shockwave-flash')

        # General Cache
        cache = os.path.join(CACHE, key)
        if os.path.isfile(cache): return self._serve(cache)

        # Asset Pool for general assets
        clean_p = p.split('$')[0]
        base_p = os.path.basename(clean_p)
        if clean_p in ASSET_POOL:
            return self._serve(ASSET_POOL[clean_p])
        if base_p in ASSET_POOL:
            return self._serve(ASSET_POOL[base_p])

        # Offline Fallbacks for StuffAssets / KillIcon / MedalAssets
        if 'StuffAssets' in p:
            for f in os.listdir(CACHE):
                if 'StuffAssets' in f and f.endswith('.swf') and os.path.getsize(os.path.join(CACHE, f)) >= 500:
                    return self._serve(os.path.join(CACHE, f), 'application/x-shockwave-flash')
        if 'KillIcon' in p:
            for f in os.listdir(CACHE):
                if 'KillIcon' in f and f.endswith('.swf') and os.path.getsize(os.path.join(CACHE, f)) >= 500:
                    return self._serve(os.path.join(CACHE, f), 'application/x-shockwave-flash')

        # 100% Zero-latency Offline: Never wait on external CDN
        self.send_error(404)

    def do_POST(self):
        p = urllib.parse.urlparse(self.path).path.lstrip('/')
        body = b''
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length > 0:
                body = self.rfile.read(content_length)
        except Exception:
            pass
        log_req(f"POST {p} len={len(body)}")
        if 'log_stat' in p and body:
            log_req(f"  [STAT] {body[:260].decode('utf-8', errors='replace')}")
        if 'log_error' in p or 'error' in p or 'log_event' in p:
            try:
                err_text = body.decode('utf-8', errors='replace')
                print(f"[CLIENT_ERROR] {err_text}", flush=True)
                with open(os.path.join(ROOT_DIR, "Game-SSJJ-logs", "client_error.log"), 'a', encoding='utf-8') as ef:
                    ef.write(f"{time.strftime('%H:%M:%S')} {err_text}\n")
                # Keep the focused AIR startup diagnostics in probe.log as well
                # as the full client_error.log. The client posts form-encoded
                # log/stack fields, so decode those before searching for errors.
                fields = urllib.parse.parse_qs(err_text, keep_blank_values=True)
                decoded = "\n".join(fields.get(key, [""])[0] for key in ("log", "stack", "message"))
                probe_items = []
                for match in re.findall(r"Error #(?:1009|3226|1007)\b[^\r\n|]*", decoded):
                    probe_items.append(match.strip())
                marker_pattern = r"(?:Error:\s*)?((?:BYTELOAD|STUFFINIT16|NEWREC|SUBREC|MVVIEW|PROBE|PROBELD)::[^\s|\r\n]+)"
                probe_items.extend(re.findall(marker_pattern, decoded))
                if probe_items:
                    probe_path = os.path.join(ROOT_DIR, "Game-SSJJ-logs", "probe.log")
                    stamp = time.strftime('%Y-%m-%d %H:%M:%S')
                    with open(probe_path, 'a', encoding='utf-8') as pf:
                        for item in dict.fromkeys(probe_items):
                            pf.write(f"{stamp} [CLIENT] {item}\n")
            except Exception: pass
            self._serve_bytes(b'ok', 'text/plain')
            return
        if p == 'shot':
            q = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            tick = q.get('tick', ['0'])[0]
            shot_file = os.path.join(ROOT_DIR, "Game-SSJJ-logs", "shots", f"stage_{tick}.png")
            try:
                os.makedirs(os.path.dirname(shot_file), exist_ok=True)
                with open(shot_file, 'wb') as sf:
                    sf.write(body)
                print(f"[SHOT] Saved stage shot {shot_file} ({len(body)} bytes)", flush=True)
            except Exception as se:
                print(f"[SHOT] Save err: {se}", flush=True)
            self._serve_bytes(b'ok', 'text/plain')
            return
        self._serve_bytes(b'ok', 'text/plain')

def run():
    build_res_contract()
    print(f"[Gateway] Starting Master HTTP Resource Gateway on 127.0.0.1:{HTTP_PORT}...", flush=True)
    server = socketserver.ThreadingTCPServer(('127.0.0.1', HTTP_PORT), GatewayHandler)
    server.daemon_threads = True
    print(f"[Gateway] Master HTTP Gateway listening on 8080! 13,558 assets ready for zero-latency load (100% OFFLINE).", flush=True)
    server.serve_forever()

if __name__ == '__main__':
    run()
