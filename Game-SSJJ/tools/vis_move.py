import re, collections

log = r"D:/SSJJ-4399/battle/3_64/log/offline.log"
seg_pat = re.compile(r"#(\d+)\((.*?)(?=#\d+\(|$)")
dv_pat = re.compile(r"dist=([0-9.]+) vis=(\d+)/(\d+)")
pos_pat = re.compile(r"pos=\(([\-\d.]+), ([\-\d.]+), ([\-\d.]+)\)")
leg_pat = re.compile(r"leg=(\d+)")

# 每个 bot 连续样本间：位置是否变化(移动中) vs 可见数
move_vis = collections.defaultdict(lambda: collections.Counter())
still_vis = collections.defaultdict(lambda: collections.Counter())
last_pos = {}
leg_vis = collections.defaultdict(lambda: collections.Counter())

with open(log, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        for sm in seg_pat.finditer(line):
            bid, seg = sm.group(1), sm.group(2)
            dm = dv_pat.search(seg)
            pm = pos_pat.search(seg)
            if not dm or not pm:
                continue
            vc = int(dm.group(2))
            tot = int(dm.group(3))
            pos = (float(pm.group(1)), float(pm.group(2)), float(pm.group(3)))
            lm = leg_pat.search(seg)
            leg = lm.group(1) if lm else "?"
            leg_vis[bid][leg] += 1
            if bid in last_pos:
                lp = last_pos[bid]
                moved = (abs(pos[0]-lp[0]) > 1.0 or abs(pos[1]-lp[1]) > 1.0
                         or abs(pos[2]-lp[2]) > 1.0)
                if moved:
                    move_vis[bid][(vc, tot)] += 1
                else:
                    still_vis[bid][(vc, tot)] += 1
            last_pos[bid] = pos

print("bot | 移动中 vis分布 | 静止时 vis分布")
for bid in sorted(move_vis):
    mv = " ".join("v%d/%d:%d" % (k[0], k[1], n) for k, n in sorted(move_vis[bid].items()))
    sv = " ".join("v%d/%d:%d" % (k[0], k[1], n) for k, n in sorted(still_vis[bid].items()))
    print("#%s MOVE[%s] STILL[%s]" % (bid, mv, sv))

print()
print("leg field distribution per bot (leg=动画腿态?):")
for bid in sorted(leg_vis):
    print("#%s %s" % (bid, dict(leg_vis[bid])))
