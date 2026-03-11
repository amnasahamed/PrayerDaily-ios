#!/usr/bin/env python3
"""Generate Muslim Pro app icon - run: python3 generate_icon.py"""
from PIL import Image, ImageDraw
import math, os, numpy as np

size = 1024
arr = np.zeros((size, size, 3), dtype=np.uint8)

# Background: dark forest green diagonal gradient (matches reference)
for y in range(size):
    for x in range(size):
        t = (x * 0.25 + y * 0.75) / size
        arr[y, x] = [int(2 + 3*(1-t)), int(90 - 38*t), int(52 - 22*t)]

img = Image.fromarray(arr, 'RGB')
draw = ImageDraw.Draw(img)

gold = (255, 248, 145)
bg_col = (4, 70, 42)
cx, cy = 512, 512
stroke = 56

# ── 8-pointed star (Rub el Hizb) ──────────────────────────────────────────
def star8(cx, cy, R, r, rot_deg=0):
    pts = []
    for i in range(16):
        angle = math.radians(rot_deg + i * 22.5)
        radius = R if i % 2 == 0 else r
        pts.append((cx + radius * math.sin(angle), cy - radius * math.cos(angle)))
    return pts

# Filled gold star
draw.polygon(star8(cx, cy, 378, 255, 0), fill=gold)
# Cutout to make it an outline
draw.polygon(star8(cx, cy, 320, 198, 0), fill=bg_col)

# ── Mosque arch (pointed ogee) in center ─────────────────────────────────
arch_cx, arch_cy = cx, cy - 22
aw2 = 118   # half-width
ah  = 286   # total height

def ogee_arch_pts(cx, cy, hw, h, s=0):
    """Returns polygon points for a pointed ogee arch."""
    hw2    = hw - s
    bot_y  = cy + h // 2 - s
    neck_y = cy + 12 - s
    arc_r  = hw2
    top_y  = cy - h // 2 + s

    pts = [(cx - hw2, bot_y), (cx - hw2, neck_y)]
    for deg in range(180, 0, -3):
        rad = math.radians(deg)
        x = cx + arc_r * math.cos(rad)
        y = neck_y + arc_r * math.sin(rad)
        if y >= top_y + arc_r:
            pts.append((x, y))
    pts.append((cx, top_y))
    for deg in range(180, 360, 3):
        rad = math.radians(deg)
        x = cx + arc_r * math.cos(rad)
        y = neck_y + arc_r * math.sin(rad)
        if y >= top_y + arc_r:
            pts.append((x, y))
    pts += [(cx + hw2, neck_y), (cx + hw2, bot_y)]
    return pts

draw.polygon(ogee_arch_pts(arch_cx, arch_cy, aw2 + stroke, ah, 0), fill=gold)
draw.polygon(ogee_arch_pts(arch_cx, arch_cy, aw2, ah, stroke), fill=bg_col)

# Pointed bottom tip below arch
tip_base_y = int(arch_cy + ah // 2 - stroke - 5)
s2 = stroke // 2
draw.polygon([
    (arch_cx - aw2 - s2, tip_base_y),
    (arch_cx + aw2 + s2, tip_base_y),
    (arch_cx + aw2 + s2, tip_base_y + stroke),
    (arch_cx,            tip_base_y + int(stroke * 2.3)),
    (arch_cx - aw2 - s2, tip_base_y + stroke),
], fill=gold)

# ── Save ─────────────────────────────────────────────────────────────────
out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   "Assets.xcassets", "AppIcon.appiconset", "AppIcon.png")
os.makedirs(os.path.dirname(out), exist_ok=True)
img.save(out, 'PNG')
print(f"Saved {size}x{size} icon to {out}")
