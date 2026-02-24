#!/usr/bin/env python3
"""Generate Aleha app icon - run with: python3 generate_icon.py"""
import os, sys
try:
    from PIL import Image, ImageDraw
except ImportError:
    print("pip install Pillow first"); sys.exit(1)

size = 1024
img = Image.new('RGBA', (size, size), (0,0,0,0))
draw = ImageDraw.Draw(img)
bg = (34, 139, 76)
draw.rounded_rectangle([0, 0, size, size], radius=224, fill=bg)
cx, cy = 512, 480
moon_layer = Image.new('RGBA', (size, size), (0,0,0,0))
md = ImageDraw.Draw(moon_layer)
gold = (232, 180, 60, 255)
md.ellipse([cx-280, cy-280, cx+280, cy+280], fill=gold)
md.ellipse([cx-220+80, cy-220-20, cx+220+80, cy+220-20], fill=(0,0,0,0))
img = Image.alpha_composite(img, moon_layer)
draw = ImageDraw.Draw(img)
sx, sy = cx-60, cy+40
draw.ellipse([sx-84, sy-84, sx+84, sy+84], fill=(255,255,255,200))
draw.ellipse([sx-80, sy-80, sx+80, sy+80], fill=bg)
draw.ellipse([sx-30, sy-30, sx+30, sy+30], fill=gold)
draw.ellipse([cx-10, 250-10, cx+10, 250+10], fill=(255,255,255,220))
script_dir = os.path.dirname(os.path.abspath(__file__))
out = os.path.join(script_dir, 'Assets.xcassets', 'AppIcon.appiconset', 'icon_1024.png')
img.save(out, 'PNG')
print(f"Saved icon to {out}")
