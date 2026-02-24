#!/usr/bin/env python3
"""Generate Aleha app icon - run: python3 generate_icon.py"""
from PIL import Image, ImageDraw, ImageFont
import math, os

size = 1024
img = Image.new('RGBA', (size, size), (0,0,0,0))

# --- Rounded rect gradient background ---
radius = 230
grad = Image.new('RGBA', (size, size), (0, 0, 0, 0))
gd = ImageDraw.Draw(grad)
for y in range(size):
    t = y / size
    r = int(13 + t * 20)
    g = int(61 + t * 45)
    b = int(35 + t * 20)
    gd.line([(0, y), (size, y)], fill=(r, g, b, 255))

bg_mask = Image.new('L', (size, size), 0)
bm = ImageDraw.Draw(bg_mask)
bm.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
grad.putalpha(bg_mask)
img = Image.alpha_composite(img, grad)

# --- Warm glow orb ---
glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
gd2 = ImageDraw.Draw(glow)
for rad in range(280, 0, -1):
    alpha = int(18 * (1 - rad / 280))
    cx2, cy2 = 530, 530
    gd2.ellipse([cx2-rad, cy2-rad, cx2+rad, cy2+rad], fill=(245, 170, 60, alpha))
glow.putalpha(bg_mask)
img = Image.alpha_composite(img, glow)

# --- Crescent (amber) ---
cx, cy = 490, 420
outer_r = 215
inner_r = 168
off_x, off_y = 78, -12

crescent_mask = Image.new('L', (size, size), 0)
cm = ImageDraw.Draw(crescent_mask)
cm.ellipse([cx-outer_r, cy-outer_r, cx+outer_r, cy+outer_r], fill=255)
cm.ellipse([cx+off_x-inner_r, cy+off_y-inner_r, cx+off_x+inner_r, cy+off_y+inner_r], fill=0)

crescent_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
ImageDraw.Draw(crescent_layer).ellipse([cx-outer_r, cy-outer_r, cx+outer_r, cy+outer_r], fill=(245, 175, 50, 255))
crescent_layer.putalpha(crescent_mask)
img = Image.alpha_composite(img, crescent_layer)

# --- Star dot ---
draw = ImageDraw.Draw(img)
draw.ellipse([683, 282, 730, 328], fill=(245, 175, 50, 255))

# --- Aleha inner logo circle (green crescent) ---
gc_x, gc_y = 448, 508
g_outer = 88
g_inner = 68
g_ox = 28

green_mask = Image.new('L', (size, size), 0)
gm = ImageDraw.Draw(green_mask)
gm.ellipse([gc_x-g_outer, gc_y-g_outer, gc_x+g_outer, gc_y+g_outer], fill=255)
gm.ellipse([gc_x+g_ox-g_inner, gc_y-8-g_inner, gc_x+g_ox+g_inner, gc_y-8+g_inner], fill=0)

green_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
ImageDraw.Draw(green_layer).ellipse([gc_x-g_outer, gc_y-g_outer, gc_x+g_outer, gc_y+g_outer], fill=(45, 181, 100, 255))
green_layer.putalpha(green_mask)
img = Image.alpha_composite(img, green_layer)

# --- Text ---
draw = ImageDraw.Draw(img)
try:
    font_bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 108)
    font_sub  = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 52)
except Exception:
    font_bold = ImageFont.load_default()
    font_sub  = font_bold

draw.text((512, 700), "aleha", fill=(255, 255, 255, 235), font=font_bold, anchor="mt")
draw.text((512, 828), "your spiritual companion", fill=(255, 255, 255, 100), font=font_sub, anchor="mt")

out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   "Assets.xcassets", "AppIcon.appiconset", "icon_1024.png")
os.makedirs(os.path.dirname(out), exist_ok=True)
img.save(out, 'PNG')
print(f"Saved to {out}")
