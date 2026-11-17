# -*- coding: utf-8 -*-
"""Scan dbgcam PNGs: find frames with dark blobs (potential black bot models).
Also report overall brightness to locate the dark-model symptom."""
import os, sys, glob
try:
    from PIL import Image
except ImportError:
    print("PIL missing"); sys.exit(1)

D = r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ-logs\dbgcam"
files = sorted(glob.glob(os.path.join(D, "dbg_main_*.png")), key=lambda p: int(''.join(c for c in os.path.basename(p) if c.isdigit())))
if not files:
    print("no frames"); sys.exit(0)

print("frame  mean  center_mean  dark_px%  min_lum  note")
for f in files:
    im = Image.open(f).convert("L")
    w, h = im.size
    px = im.load()
    # full-image mean
    tot = 0; n = 0
    for y in range(0, h, 4):
        for x in range(0, w, 4):
            tot += px[x, y]; n += 1
    mean = tot / max(n, 1)
    # center region (middle 40% x, middle 60% y)
    cx0, cx1 = int(w*0.3), int(w*0.7)
    cy0, cy1 = int(h*0.2), int(h*0.8)
    ctot = 0; cn = 0; dark = 0; mn = 255
    for y in range(cy0, cy1, 2):
        for x in range(cx0, cx1, 2):
            v = px[x, y]; ctot += v; cn += 1
            if v < 30: dark += 1
            if v < mn: mn = v
    cmean = ctot / max(cn, 1)
    dp = 100.0 * dark / max(cn, 1)
    note = ""
    if dp > 1.0: note += "DARKBLOB "
    if mean < 40: note += "DARKFRAME"
    print("%s  %6.1f  %6.1f  %6.2f  %3d  %s" % (os.path.basename(f), mean, cmean, dp, mn, note))
