import re, math, collections

log = r"D:/SSJJ-4399/battle/3_64/log/offline.log"
dbg_pat = re.compile(r"cam=\(([\-\d.]+), ([\-\d.]+), ([\-\d.]+)\) rot=\(([\-\d.]+), ([\-\d.]+), ([\-\d.]+)\)")
seg_pat = re.compile(r"#(\d+)\((.*?)(?=#\d+\(|$)")
dv_pat = re.compile(r"dist=([0-9.]+) vis=(\d+)/(\d+)")
body_pat = re.compile(r"body=(.*?) vis=(\w+)")
pos_pat = re.compile(r"pos=\(([\-\d.]+), ([\-\d.]+), ([\-\d.]+)\)")

# 对每个"近距+隐藏"样本，判断 bot 是否在相机前方半球（yaw 前向 120 度锥内算"应该看见"）
should_see_hidden = collections.Counter()
should_see_total = collections.Counter()

with open(log, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        dm = dbg_pat.search(line)
        if not dm:
            continue
        cx, cy, cz = float(dm.group(1)), float(dm.group(2)), float(dm.group(3))
        yaw = float(dm.group(5))
        yaw_r = math.radians(yaw)
        # Unity: forward = (sin(yaw), 0, cos(yaw)) for yaw-only rotation
        fx, fz = math.sin(yaw_r), math.cos(yaw_r)
        for sm in seg_pat.finditer(line):
            bid, seg = sm.group(1), sm.group(2)
            d2 = dv_pat.search(seg)
            pm = pos_pat.search(seg)
            if not d2 or not pm:
                continue
            dist = float(d2.group(1))
            vc = int(d2.group(2))
            bm = body_pat.search(seg)
            bodyvis = bm.group(2) if bm else "?"
            hidden = (vc == 0) or (bodyvis == "False")
            bx, by, bz = float(pm.group(1)), float(pm.group(2)), float(pm.group(3))
            dx, dz = bx - cx, bz - cz
            dlen = math.hypot(dx, dz) or 1.0
            dot = (dx / dlen) * fx + (dz / dlen) * fz
            in_front = dot > math.cos(math.radians(60))  # 前 120 度锥
            if dist < 1500 and in_front:
                should_see_total[bid] += 1
                if hidden:
                    should_see_hidden[bid] += 1

print("bot | 前锥120度+近距 隐藏/总数 (真bug=隐藏但应可见)")
for bid in sorted(should_see_total):
    print("#%s | %d/%d" % (bid, should_see_hidden[bid], should_see_total[bid]))
