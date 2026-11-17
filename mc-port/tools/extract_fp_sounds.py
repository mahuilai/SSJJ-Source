# -*- coding: utf-8 -*-
"""Extract original AWM sound clips and encode them for Minecraft resources."""
import argparse
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

import UnityPy
from UnityPy.export import AudioClipConverter

ROOT = Path(r"D:\逆向\SSJJ双塔惊魂")
SOURCE = ROOT / "资源全集" / "sound" / "weapon" / "awm_legend_t_055dcf5f7532af5f5e1a9ad0a98ddd6c"
DEST = ROOT / "mc-port" / "fpmod" / "src" / "main" / "resources" / "assets" / "ssjjfp" / "sounds" / "fp"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ffmpeg", default=shutil.which("ffmpeg") or
                    r"C:\Users\Mahuilai\AppData\Roaming\Smoothie\bin\ffmpeg.exe")
    args = ap.parse_args()
    ffmpeg = Path(args.ffmpeg)
    if not ffmpeg.is_file():
        raise SystemExit("ffmpeg not found: " + str(ffmpeg))

    # UnityPy's bundled AudioClip converter targets an older pyfmodex API.
    AudioClipConverter.import_pyfmodex()
    AudioClipConverter.pyfmodex.system.CREATESOUNDEXINFO = \
        AudioClipConverter.pyfmodex.structures.CREATESOUNDEXINFO
    from pyfmodex import enums, sound
    old_get_length = sound.Sound.get_length

    def get_length_compat(instance, unit):
        return old_get_length(instance, enums.TIMEUNIT(unit) if isinstance(unit, int) else unit)

    sound.Sound.get_length = get_length_compat
    env = UnityPy.load(str(SOURCE))
    DEST.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="ssjj-awmsound-") as tmp:
        tmpdir = Path(tmp)
        count = 0
        for obj in env.objects:
            if obj.type.name != "AudioClip":
                continue
            clip = obj.read()
            samples = AudioClipConverter.extract_audioclip_samples(clip)
            for sample_name, wav_bytes in samples.items():
                stem = Path(sample_name).stem
                wav_path = tmpdir / (stem + ".wav")
                ogg_path = DEST / (stem + ".ogg")
                wav_path.write_bytes(wav_bytes)
                subprocess.run([
                    str(ffmpeg), "-hide_banner", "-loglevel", "error", "-y",
                    "-i", str(wav_path), "-vn", "-c:a", "libvorbis", "-q:a", "5",
                    str(ogg_path),
                ], check=True)
                count += 1
                print(clip.m_Name, "->", ogg_path.name, ogg_path.stat().st_size, "bytes")
    print("extracted", count, "original AWM clips")


if __name__ == "__main__":
    main()
