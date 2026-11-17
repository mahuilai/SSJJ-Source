# -*- coding: utf-8 -*-
"""截图健康度分析（M2 端到端验收用）

判断一张大厅截图是「真的画出了界面」还是「黑屏 / 空白 / 纯色」。
不追求像素级回归（那需要 SSIM 且对分辨率极敏感），只做可判定的下限检查：
  - 尺寸是否合理
  - 平均亮度（全黑会接近 0）
  - 亮度标准差（纯色/纯黑接近 0）
  - 颜色多样性（256 级量化后的独立颜色数）

用法:
    python tools/img_health.py <png> [--json]

退出码: 0 = 健康, 1 = 疑似黑屏/空白
"""
import json
import sys

try:
    from PIL import Image
except ImportError:
    print(json.dumps({'ok': False, 'error': 'Pillow not available'}))
    sys.exit(1)

# 阈值：宁可漏报也不误报，只拦「明显的黑屏/空白」
MIN_W, MIN_H = 200, 150
MIN_MEAN = 12.0        # 0-255 平均亮度
MIN_STDDEV = 8.0       # 亮度标准差
MIN_UNIQUE = 24        # 256 级量化后的独立颜色数


def analyze(path):
    im = Image.open(path)
    w, h = im.size
    g = im.convert('L')
    # 缩到 256x144 采样，够用且快
    g_small = g.resize((256, 144))
    px = list(g_small.getdata())
    n = len(px)
    mean = sum(px) / n
    var = sum((p - mean) ** 2 for p in px) / n
    stddev = var ** 0.5
    rgb = im.convert('RGB').resize((128, 72))
    uniq = len({p for p in rgb.getdata()})
    checks = {
        'size_ok': w >= MIN_W and h >= MIN_H,
        'mean_ok': mean >= MIN_MEAN,
        'stddev_ok': stddev >= MIN_STDDEV,
        'unique_ok': uniq >= MIN_UNIQUE,
    }
    return {
        'ok': all(checks.values()),
        'width': w, 'height': h,
        'mean': round(mean, 2),
        'stddev': round(stddev, 2),
        'unique_colors': uniq,
        'checks': checks,
    }


def main():
    if len(sys.argv) < 2:
        print(json.dumps({'ok': False, 'error': 'no path'}))
        return 1
    r = analyze(sys.argv[1])
    print(json.dumps(r, ensure_ascii=False))
    return 0 if r['ok'] else 1


if __name__ == '__main__':
    sys.exit(main())
