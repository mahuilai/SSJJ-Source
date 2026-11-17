import re, collections

log = r"D:/SSJJ-4399/battle/3_64/log/offline.log"
seg_pat = re.compile(r"#(\d+)\((.*?)(?=#\d+\(|$)")
dv_pat = re.compile(r"dist=([0-9.]+) vis=(\d+)/(\d+)")
body_pat = re.compile(r"body=(.*?) vis=(\w+)")

near_hidden = collections.Counter()   # dist<1500 但主体不可见
near_total = collections.Counter()
far_hidden = collections.Counter()
far_total = collections.Counter()

with open(log, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        for sm in seg_pat.finditer(line):
            bid, seg = sm.group(1), sm.group(2)
            dm = dv_pat.search(seg)
            if not dm:
                continue
            dist = float(dm.group(1))
            vc = int(dm.group(2))
            bm = body_pat.search(seg)
            bodyvis = bm.group(2) if bm else "?"
            hidden = (vc == 0) or (bodyvis == "False")
            if dist < 1500:
                near_total[bid] += 1
                if hidden:
                    near_hidden[bid] += 1
            else:
                far_total[bid] += 1
                if hidden:
                    far_hidden[bid] += 1

print("bot | near(<15m) hidden/total | far(>=15m) hidden/total")
for bid in sorted(near_total):
    print("#%s | %d/%d | %d/%d" % (bid, near_hidden[bid], near_total[bid], far_hidden[bid], far_total[bid]))
