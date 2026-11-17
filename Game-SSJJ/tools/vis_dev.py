import re, collections

log = r"D:/SSJJ-4399/battle/3_64/log/offline.log"
seg_pat = re.compile(r"#(\d+)\((.*?)(?=#\d+\(|$)")
pos_pat = re.compile(r"pos=\(([\-\d.]+), ([\-\d.]+), ([\-\d.]+)\)")
bc_pat = re.compile(r"bc=\(([\-\d.]+), ([-\d.]+), ([-\d.]+)\)")
dv_pat = re.compile(r"vis=(\d+)/(\d+)")

# 每 bot：|bc - pos| 偏差随时间变化 + vis
last_pos = {}
rows = collections.defaultdict(list)

with open(log, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        for sm in seg_pat.finditer(line):
            bid, seg = sm.group(1), sm.group(2)
            pm = pos_pat.search(seg)
            bm = bc_pat.search(seg)
            dm = dv_pat.search(seg)
            if not pm:
                continue
            pos = (float(pm.group(1)), float(pm.group(2)), float(pm.group(3)))
            moved = False
            if bid in last_pos:
                lp = last_pos[bid]
                moved = (abs(pos[0]-lp[0]) > 1.0 or abs(pos[1]-lp[1]) > 1.0
                         or abs(pos[2]-lp[2]) > 1.0)
            last_pos[bid] = pos
            if not bm or not dm:
                continue
            bc = (float(bm.group(1)), float(bm.group(2)), float(bm.group(3)))
            dev = ((bc[0]-pos[0])**2 + (bc[1]-pos[1])**2 + (bc[2]-pos[2])**2) ** 0.5
            rows[bid].append((moved, dev, int(dm.group(1)), int(dm.group(2))))

for bid in sorted(rows):
    mv = [r for r in rows[bid] if r[0]]
    st = [r for r in rows[bid] if not r[0]]
    def stat(rs):
        if not rs:
            return "n=0"
        devs = sorted(r[1] for r in rs)
        return "n=%d dev med=%.0f max=%.0f | vis0=%d visLow=%d" % (
            len(rs), devs[len(devs)//2], devs[-1],
            sum(1 for r in rs if r[2] == 0),
            sum(1 for r in rs if r[2] < r[3]))
    print("#%s MOVE[%s]" % (bid, stat(mv)))
    print("#%s STILL[%s]" % (bid, stat(st)))
    # 偏差最大的 5 个样本
    top = sorted(rows[bid], key=lambda r: -r[1])[:5]
    print("   top dev:", ["moved=%d dev=%.0f vis=%d/%d" % t for t in top])
