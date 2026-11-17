import re, collections

log = r"D:/SSJJ-4399/battle/3_64/log/offline.log"
seg_pat = re.compile(r"#(\d+)\((.*?)(?=#\d+\(|$)")
dv_pat = re.compile(r"dist=([0-9.]+) vis=(\d+)/(\d+)")
body_pat = re.compile(r"body=(.*?) vis=(\w+)")

seg_count = collections.Counter()      # 每 bot 出现段数（含被截断的）
stats = collections.defaultdict(lambda: collections.defaultdict(list))
transitions = collections.defaultdict(list)
last = {}
truncated = collections.Counter()

with open(log, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        for sm in seg_pat.finditer(line):
            bid = sm.group(1)
            seg = sm.group(2)
            seg_count[bid] += 1
            dm = dv_pat.search(seg)
            if not dm:
                truncated[bid] += 1
                continue
            dist = float(dm.group(1))
            vc, tot = int(dm.group(2)), int(dm.group(3))
            stats[bid][(vc, tot)].append(dist)
            cur = (vc, tot)
            if bid in last and last[bid] != cur:
                transitions[bid].append((last[bid], cur))
            last[bid] = cur

print("segment counts (appearances / truncated-without-dist-vis):")
for bid in sorted(seg_count):
    print("  #%s: appear=%d truncated=%d" % (bid, seg_count[bid], truncated[bid]))

print()
for bid in sorted(stats):
    n = sum(len(v) for v in stats[bid].values())
    print("=== #%s (complete samples=%d) ===" % (bid, n))
    for k in sorted(stats[bid]):
        ds = stats[bid][k]
        print("  vis=%d/%d  n=%3d  dist min=%.0f med=%.0f max=%.0f" % (
            k[0], k[1], len(ds), min(ds), sorted(ds)[len(ds)//2], max(ds)))
    drops = sum(1 for a, b in transitions[bid] if b[0] < a[0])
    print("  transitions=%d drops=%d" % (len(transitions[bid]), drops))
