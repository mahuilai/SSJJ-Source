"""Resolve AIR lobby resources against local mirrors and their byte contracts."""
from collections import defaultdict
import os
from pathlib import Path
import re
import xml.etree.ElementTree as ET


STAGE3D_MODULE = re.compile(
    r"(?:ClientView|RenderThread|LobbyModelView|LobbyWeaponView)(?:_[0-9a-f]{32})?\.swf",
    re.IGNORECASE,
)
FILENAME_HASH = re.compile(r"_([0-9a-f]{32})(?:\.[a-z0-9]+)?$", re.IGNORECASE)
ICON_PREFIXES = tuple(f"resource/swf/{name}/" for name in ("RoleAssets", "WeaponAssets", "SkinAssets"))


def read_manifest(path):
    rows = {}
    for entry in ET.parse(path).iter():
        url, size = entry.get("url"), entry.get("size")
        if url and size is not None:
            rows[url] = (entry.get("md5", "").lower(), int(size))
    return rows


class LobbyAssets:
    def __init__(self, root, file_md5):
        self.file_md5 = file_md5
        host = root / "_work" / "lobby_host"
        self.flat = [host / name for name in (
            "decrypted", "plain", "cache", "cache_prepared", "cdn_pristine", "cdn_fetch",
        )]
        self.mirrors = defaultdict(list)
        for tree in (root / "资源下载", root / "资源缓存", root / "资源全集", root / "offline-lobby-rebuild" / "dist"):
            for directory, _, names in os.walk(tree):
                for name in names:
                    self.mirrors[name.lower()].append(Path(directory) / name)

    @staticmethod
    def managed(url):
        return (STAGE3D_MODULE.fullmatch(url) or url.startswith(("resources/", *ICON_PREFIXES)))

    def candidates(self, url, *, match_digest=False):
        key = url.replace("/", "_")
        result = [directory / key for directory in self.flat]
        suffix = "/" + url.lower()
        name = url.rsplit("/", 1)[-1].lower()
        for path in self.mirrors.get(name, ()):
            if match_digest or path.as_posix().lower().endswith(suffix):
                result.append(path)
        for path in self.mirrors.get(key.lower(), ()):
            if path not in result:
                result.append(path)
        return result

    def lookup(self, url, declared=None):
        """Return the file, and a status usable by both the gateway and the audit."""
        digest, size = declared or ("", None)
        if declared is None and not url.startswith(ICON_PREFIXES):
            embedded = FILENAME_HASH.search(url)
            if embedded:
                digest = embedded[1].lower()
        candidates = self.candidates(url, match_digest=bool(digest))
        # Dynamic icons use the local cache and resource mirrors first.
        # Prepared icons are a last resort for this exact identifier.
        if url.startswith(ICON_PREFIXES):
            prepared = self.flat[3] / url.replace("/", "_")
            candidates.remove(prepared)
            candidates.append(prepared)

        saw_file = False
        for path in candidates:
            try:
                if not path.is_file():
                    continue
                saw_file = True
                length = path.stat().st_size
                if length == 0 and size != 0:
                    continue
                if size is not None and length != size:
                    continue
                if digest and self.file_md5(path) != digest:
                    continue
                if declared is None and url.lower().endswith(".swf"):
                    with path.open("rb") as stream:
                        if stream.read(3) not in (b"FWS", b"CWS", b"ZWS"):
                            continue
            except OSError:
                continue
            return path, "matched" if digest else "size_only" if size is not None else "exact_path"
        return None, "mismatch" if saw_file else "missing"
