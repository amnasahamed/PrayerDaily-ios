#!/usr/bin/env python3
"""Generate Aleha app icon - run: python3 generate_icon.py"""
from PIL import Image, ImageDraw, ImageFont
import math, os

size = 1024
img = Image.new('RGBA', (size, size), (0,0,0,0))
draw = ImageDraw.Draw(img)

for y in range(size):
    t = y / size
    r, g, b = int(18+t*12), int(88+t*50), int(48+t*25)
    draw.line([(0,y),(size,y)], fill=(r,g,b,255))

for rad in range(350, 0, -1):
    a = int(25 * (1 - rad/350))
    cx, cy = 512, 462
    draw.ellipse([cx-rad, cy-rad, cx+rad, cy+rad], fill=(255,210,100,a))

crescent_cx, crescent_cy, outer_r, inner_r = 512, 380, 200, 155
mask = Image.new('L', (size, size), 0)
md = ImageDraw.Draw(mask)
md.ellipse([crescent_cx-outer_r, crescent_cy-outer_r, crescent_cx+outer_r, crescent_cy+outer_r], fill=255)
md.ellipse([crescent_cx+65-inner_r, crescent_cy-25-inner_r, crescent_cx+65+inner_r, crescent_cy-25+inner_r], fill=0)
cl = Image.new('RGBA', (size, size), (0,0,0,0))
ImageDraw.Draw(cl).ellipse([crescent_cx-outer_r, crescent_cy-outer_r, crescent_cx+outer_r, crescent_cy+outer_r], fill=(235,165,55,255))
cl.putalpha(mask)
img = Image.alpha_composite(img, cl)
draw = ImageDraw.Draw(img)
draw.ellipse([590, 260, 650, 320], fill=(235,165,55,255))
draw.ellipse([467, 545, 557, 635], fill=(60,160,90,255))
draw.ellipse([488, 560, 528, 600], fill=(120,200,140,255))

try: font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 80)
except: font = ImageFont.load_default()
draw.text((512,710), "aleha", fill=(255,255,255,220), font=font, anchor="mt")
draw.line([(390,762),(634,762)], fill=(235,165,55,100), width=2)

out = os.path.join(os.path.dirname(__file__), "Assets.xcassets", "AppIcon.appiconset", "icon_1024.png")
os.makedirs(os.path.dirname(out), exist_ok=True)
img.save(out, 'PNG')
print(f"Saved to {out}")
