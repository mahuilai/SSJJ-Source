# -*- coding: utf-8 -*-
'''离线软件渲染：用真实 sjfp/anm 数据复现 FpRender 的蒙皮 + 相机投影，输出 PNG 对照表。
用途：在不启动 Minecraft 的前提下，肉眼确认 bindPose 取法 / 轴向映射 / 尺度是否正确。
只读工程文件，只往 mc-port/preview 写图片。
'''
import json, math, os, struct, zlib

ROOT = 'D:/逆向/SSJJ双塔惊魂/mc-port'
FP = ROOT + '/fpmod/src/main/resources/assets/ssjjfp/fp/awm.sjfp.json'
ANM = ROOT + '/fpmod/src/main/resources/assets/ssjjfp/fp/awm.anm.json'
OUT = ROOT + '/preview'


def ident():
    return [1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0]


def mul(a, b):
    c = [0.0] * 16
    for col in range(4):
        for row in range(4):
            c[col * 4 + row] = sum(a[k * 4 + row] * b[col * 4 + k] for k in range(4))
    return c


def qmat(q):
    x, y, z, w = q
    return [1 - 2 * (y * y + z * z), 2 * (x * y + w * z), 2 * (x * z - w * y), 0.0,
            2 * (x * y - w * z), 1 - 2 * (x * x + z * z), 2 * (y * z + w * x), 0.0,
            2 * (x * z + w * y), 2 * (y * z - w * x), 1 - 2 * (x * x + y * y), 0.0,
            0.0, 0.0, 0.0, 1.0]


def lm(p, q, s):
    m = qmat(q)
    for col in range(3):
        for row in range(3):
            m[col * 4 + row] *= s[col]
    m[12], m[13], m[14] = p[0], p[1], p[2]
    return m


def inv(m):
    A = [[m[c * 4 + r] for c in range(4)] + [1.0 if c == r else 0.0 for c in range(4)]
         for r in range(4)]
    for i in range(4):
        p = max(range(i, 4), key=lambda r: abs(A[r][i]))
        if abs(A[p][i]) < 1e-12:
            return None
        A[i], A[p] = A[p], A[i]
        d = A[i][i]
        A[i] = [v / d for v in A[i]]
        for r in range(4):
            if r != i and A[r][i] != 0.0:
                f = A[r][i]
                A[r] = [vr - f * vi for vr, vi in zip(A[r], A[i])]
    out = [0.0] * 16
    for r in range(4):
        for c in range(4):
            out[c * 4 + r] = A[r][4 + c]
    return out


def transpose(m):
    out = [0.0] * 16
    for r in range(4):
        for c in range(4):
            out[c * 4 + r] = m[r * 4 + c]
    return out


def xf(m, p):
    return [m[0] * p[0] + m[4] * p[1] + m[8] * p[2] + m[12],
            m[1] * p[0] + m[5] * p[1] + m[9] * p[2] + m[13],
            m[2] * p[0] + m[6] * p[1] + m[10] * p[2] + m[14]]


def slerp(a, b, f):
    ax, ay, az, aw = a[4:8]
    bx, by, bz, bw = b[4:8]
    dot = ax * bx + ay * by + az * bz + aw * bw
    if dot < 0:
        bx, by, bz, bw, dot = -bx, -by, -bz, -bw, -dot
    if dot > 0.9995:
        o = [ax + (bx - ax) * f, ay + (by - ay) * f, az + (bz - az) * f, aw + (bw - aw) * f]
    else:
        th0 = math.acos(max(-1.0, min(1.0, dot)))
        th = th0 * f
        s0 = math.sin(th0 - th) / math.sin(th0)
        s1 = math.sin(th) / math.sin(th0)
        o = [ax * s0 + bx * s1, ay * s0 + by * s1, az * s0 + bz * s1, aw * s0 + bw * s1]
    n = math.sqrt(sum(v * v for v in o)) or 1.0
    return [v / n for v in o]


def sample(clip, bone, t):
    ks = clip['bones'].get(bone) if clip else None
    if not ks:
        return None
    if clip['loop'] and clip['length'] > 1e-4:
        t = t % clip['length']
    elif t > ks[-1][0]:
        t = ks[-1][0]
    if t <= ks[0][0]:
        return list(ks[0][1:4]), list(ks[0][4:8])
    i = 0
    while i + 1 < len(ks) and ks[i + 1][0] <= t:
        i += 1
    if i + 1 >= len(ks):
        return list(ks[-1][1:4]), list(ks[-1][4:8])
    a, b = ks[i], ks[i + 1]
    span = max(1e-5, b[0] - a[0])
    f = min(1.0, max(0.0, (t - a[0]) / span))
    pos = [a[1 + k] + (b[1 + k] - a[1 + k]) * f for k in range(3)]
    return pos, slerp(a, b, f)


d = json.load(open(FP, encoding='utf-8'))
bones = d['skeleton']['bones']
N = len(bones)
n2i = {b['name']: i for i, b in enumerate(bones)}
pidx = [n2i.get(b['parent'], -1) if b.get('parent') else -1 for b in bones]
anm = json.load(open(ANM, encoding='utf-8'))


def world_of(clip, t):
    world = [ident() for _ in range(N)]
    for i in range(N):
        b = bones[i]
        pos = list(b['local'])
        rot = list(b['rotation'])
        s = sample(clip, b['name'], t) if clip else None
        if s:
            pos, rot = s
        m = lm(pos, rot, b['scale'])
        world[i] = mul(world[pidx[i]], m) if pidx[i] >= 0 else m
    return world


def skin_matrices(mode, clip, t):
    w = world_of(clip, t)
    if mode == 'file':
        return [mul(w[i], [float(v) for v in bones[i]['bindPose']]) for i in range(N)]
    if mode == 'fileT':
        return [mul(w[i], transpose([float(v) for v in bones[i]['bindPose']])) for i in range(N)]
    if mode == 'restinv':
        rest = world_of(None, 0.0)
        out = []
        for i in range(N):
            r = inv(rest[i])
            out.append(mul(w[i], r) if r else ident())
        return out
    if mode == 'identity':
        return [ident() for _ in range(N)]
    raise ValueError(mode)


def deform(mesh, skin):
    pts = []
    if mesh.get('skinned'):
        for v, p in enumerate(mesh['pos']):
            x = y = z = 0.0
            for k in range(4):
                wt = mesh['boneW'][v][k]
                if wt == 0.0:
                    continue
                j = mesh['boneIdx'][v][k]
                if not (0 <= j < N):
                    continue
                t = xf(skin[j], p)
                x += wt * t[0]
                y += wt * t[1]
                z += wt * t[2]
            pts.append((x, y, z))
    else:
        j = n2i.get(mesh.get('rigidBone'), -1)
        for p in mesh['pos']:
            pts.append(tuple(xf(skin[j], p)) if j >= 0 else tuple(p))
    return pts


MAPS = [
    ('M1 gun-cur', ((0, 1), (2, 1), (1, 1))),
    ('M2 hand-cur', ((2, 1), (1, 1), (0, 1))),
    ('M3 y-fwd', ((2, 1), (0, 1), (1, -1))),
    ('M4 x-fwd', ((2, 1), (1, 1), (0, -1))),
]
SCALE = 0.002


def to_cam(pts, mp):
    out = []
    for p in pts:
        q = [mp[0][1] * p[mp[0][0]], mp[1][1] * p[mp[1][0]], mp[2][1] * p[mp[2][0]]]
        out.append((q[0] * SCALE, q[1] * SCALE, q[2] * SCALE))
    return out


def bbox3(pts):
    if not pts:
        return None
    return [(min(p[i] for p in pts), max(p[i] for p in pts)) for i in range(3)]


W, H = 240, 135
COLS, ROWS = 4, 4
FOV = 70.0
BIND_MODES = ['file', 'fileT', 'restinv', 'identity']
CLIP = anm['clips'].get('idle')
T = 0.0


class Panel:
    def __init__(self):
        self.px = bytearray()
        self.zb = [1e30] * (W * H)
        for y in range(H):
            for x in range(W):
                g = 26 + int(20 * (y / H))
                self.px += bytes((g // 2, g // 2, g))

    def put(self, x, y, r, g, b):
        i = (y * W + x) * 3
        self.px[i] = r
        self.px[i + 1] = g
        self.px[i + 2] = b

    def tri(self, p2, dep, a, b, c, col):
        pa, pb, pc = p2[a], p2[b], p2[c]
        da, db, dc = dep[a], dep[b], dep[c]
        if da <= 0.02 or db <= 0.02 or dc <= 0.02:
            if da <= 0.02 and db <= 0.02 and dc <= 0.02:
                return
        area = (pb[0] - pa[0]) * (pc[1] - pa[1]) - (pb[1] - pa[1]) * (pc[0] - pa[0])
        if abs(area) < 1e-9:
            return
        minx = max(0, int(min(pa[0], pb[0], pc[0])))
        maxx = min(W - 1, int(max(pa[0], pb[0], pc[0])) + 1)
        miny = max(0, int(min(pa[1], pb[1], pc[1])))
        maxy = min(H - 1, int(max(pa[1], pb[1], pc[1])) + 1)
        if minx > maxx or miny > maxy:
            return
        for yy in range(miny, maxy + 1):
            py = yy + 0.5
            row = yy * W
            for xx in range(minx, maxx + 1):
                px = xx + 0.5
                l0 = ((pb[0] - pa[0]) * (py - pa[1]) - (pb[1] - pa[1]) * (px - pa[0])) / area
                l1 = ((pc[0] - pb[0]) * (py - pb[1]) - (pc[1] - pb[1]) * (px - pb[0])) / area
                if l0 < 0 or l1 < 0 or l0 + l1 > 1:
                    continue
                w2 = 1.0 - l0 - l1
                z = w2 * da + l1 * db + l0 * dc
                if z > 0.02 and z < self.zb[row + xx]:
                    self.zb[row + xx] = z
                    self.put(xx, yy, col[0], col[1], col[2])


def render_panel(skin, mapping, cam_off):
    pan = Panel()
    f = 1.0 / math.tan(math.radians(FOV) * 0.5)
    asp = W / H
    L = (-0.35, 0.55, -0.75)
    for mesh, base_col in ((d['meshes'][0], (206, 172, 148)), (d['meshes'][1], (78, 78, 88))):
        pts = to_cam(deform(mesh, skin), mapping)
        pts = [(p[0] + cam_off[0], p[1] + cam_off[1], p[2] + cam_off[2]) for p in pts]
        idx = mesh['idx']
        p2, dep = [], []
        for p in pts:
            z = -p[2]
            dep.append(z)
            if z > 0.02:
                p2.append((((p[0] / z) * f / asp * 0.5 + 0.5) * W, (0.5 - (p[1] / z) * f * 0.5) * H))
            else:
                p2.append((-1e6, -1e6))
        for i in range(0, len(idx) - 2, 3):
            a, b, c = idx[i], idx[i + 1], idx[i + 2]
            ax, ay, az = pts[a]
            bx, by, bz = pts[b]
            cx, cy, cz = pts[c]
            ux, uy, uz = bx - ax, by - ay, bz - az
            vx, vy, vz = cx - ax, cy - ay, cz - az
            nx = uy * vz - uz * vy
            ny = uz * vx - ux * vz
            nz = ux * vy - uy * vx
            nl = math.sqrt(nx * nx + ny * ny + nz * nz)
            if nl < 1e-9:
                continue
            nx, ny, nz = nx / nl, ny / nl, nz / nl
            lam = abs(nx * L[0] + ny * L[1] + nz * L[2])
            k = 0.30 + 0.70 * lam
            col = (min(255, int(base_col[0] * k)), min(255, int(base_col[1] * k)), min(255, int(base_col[2] * k)))
            pan.tri(p2, dep, a, b, c, col)
    # 中心十字（相机正前方参考）
    for xx in range(W // 2 - 6, W // 2 + 7):
        pan.put(xx, H // 2, 90, 90, 60)
    for yy in range(H // 2 - 6, H // 2 + 7):
        pan.put(W // 2, yy, 90, 90, 60)
    return pan


def write_png(path, w, h, rgb):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        raw += rgb[y * w * 3:(y + 1) * w * 3]
    comp = zlib.compress(bytes(raw), 6)

    def chunk(t, dd):
        return struct.pack('>I', len(dd)) + t + dd + struct.pack('>I', zlib.crc32(t + dd) & 0xffffffff)

    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', comp)
    png += chunk(b'IEND', b'')
    open(path, 'wb').write(png)


os.makedirs(OUT, exist_ok=True)
sheet = bytearray(COLS * W * ROWS * H * 3)
SW = COLS * W
print('bind mode / mapping matrix (rows=%s, cols=%s)' % (BIND_MODES, [m[0] for m in MAPS]))
for r, mode in enumerate(BIND_MODES):
    skin = skin_matrices(mode, CLIP, T)
    for c, (mname, mp) in enumerate(MAPS):
        hand = to_cam(deform(d['meshes'][0], skin), mp)
        gun = to_cam(deform(d['meshes'][1], skin), mp)
        bb = bbox3(hand + gun)
        front = sum(1 for p in hand + gun if p[2] < 0)
        print('  [%s|%s] bbox x[%.2f,%.2f] y[%.2f,%.2f] z[%.2f,%.2f] front=%d/%d' % (
            mode, mname, bb[0][0], bb[0][1], bb[1][0], bb[1][1], bb[2][0], bb[2][1],
            front, len(hand) + len(gun)))
        off = (0.0, 0.0, 0.0)
        if front == 0:
            off = (0.0, 0.0, -max(abs(bb[2][1]), abs(bb[2][0])))
        pan = render_panel(skin, mp, off)
        for y in range(H):
            src = y * W * 3
            dst = ((r * H + y) * SW + c * W) * 3
            sheet[dst:dst + W * 3] = pan.px[src:src + W * 3]

out = OUT + '/bind_mapping_sheet.png'
write_png(out, SW, ROWS * H, sheet)
print('->', out)

for mode in BIND_MODES:
    skin = skin_matrices(mode, CLIP, T)
    hand = to_cam(deform(d['meshes'][0], skin), MAPS[0][1])
    bb = bbox3(hand)
    print('hand-only %-8s span cm=(%.1f,%.1f,%.1f)' % (
        mode, bb[0][1] - bb[0][0], bb[1][1] - bb[1][0], bb[2][1] - bb[2][0]))
