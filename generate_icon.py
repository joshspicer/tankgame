#!/usr/bin/env python3
"""Generate a 1024x1024 iOS app icon for Tank Battle game."""

from PIL import Image, ImageDraw
import math

# Canvas size
SIZE = 1024
CENTER = SIZE // 2

# Colors - carefully chosen for impact
BG_DARK = (25, 30, 35)      # Near black
BG_MEDIUM = (35, 42, 50)    # Subtle gradient tone
TANK_GREEN = (72, 199, 142) # Vibrant teal-green - eye-catching but not garish
TANK_DARK = (45, 130, 95)   # Darker shade for depth
MUZZLE_FLASH = (255, 220, 100)  # Bright yellow-orange
FLASH_OUTER = (255, 160, 60)    # Orange glow
PROJECTILE = (255, 235, 150)    # Bright projectile


def draw_tank_icon():
    """Draw a bold, iconic single-tank app icon."""
    img = Image.new('RGB', (SIZE, SIZE), BG_DARK)
    draw = ImageDraw.Draw(img)

    # Full vignette effect - gradient from center to corners
    # The diagonal from center to corner is SIZE * sqrt(2) / 2 ≈ 724
    max_radius = int(SIZE * 0.72)  # Reach the corners
    for i in range(max_radius, 0, -4):
        # Normalize to 0-1 range (1 at center, 0 at edge)
        alpha = i / max_radius
        r = int(BG_DARK[0] + (BG_MEDIUM[0] - BG_DARK[0]) * alpha)
        g = int(BG_DARK[1] + (BG_MEDIUM[1] - BG_DARK[1]) * alpha)
        b = int(BG_DARK[2] + (BG_MEDIUM[2] - BG_DARK[2]) * alpha)
        draw.ellipse([CENTER - i, CENTER - i, CENTER + i, CENTER + i], fill=(r, g, b))

    # Tank dimensions - BIG and bold, filling the frame
    # Top-down view pointing UP (toward top of icon)
    body_width = 340
    body_height = 420
    turret_size = 200
    barrel_width = 60
    barrel_length = 220

    # Position tank slightly lower so barrel+flash are centered
    tank_cy = CENTER + 60

    # === TANK BODY (treads) ===
    # Left tread
    tread_width = 70
    tread_inset = 20
    left_tread_x = CENTER - body_width // 2 + tread_inset
    draw.rounded_rectangle([
        left_tread_x - tread_width // 2, tank_cy - body_height // 2,
        left_tread_x + tread_width // 2, tank_cy + body_height // 2
    ], radius=20, fill=TANK_DARK)

    # Right tread
    right_tread_x = CENTER + body_width // 2 - tread_inset
    draw.rounded_rectangle([
        right_tread_x - tread_width // 2, tank_cy - body_height // 2,
        right_tread_x + tread_width // 2, tank_cy + body_height // 2
    ], radius=20, fill=TANK_DARK)

    # Main hull (between treads)
    hull_width = body_width - 2 * tread_inset - tread_width + 40
    draw.rounded_rectangle([
        CENTER - hull_width // 2, tank_cy - body_height // 2 + 30,
        CENTER + hull_width // 2, tank_cy + body_height // 2 - 30
    ], radius=25, fill=TANK_GREEN)

    # === TURRET ===
    # Circular turret on top
    draw.ellipse([
        CENTER - turret_size // 2, tank_cy - turret_size // 2,
        CENTER + turret_size // 2, tank_cy + turret_size // 2
    ], fill=TANK_GREEN)

    # Turret inner detail (darker ring)
    inner_turret = turret_size - 50
    draw.ellipse([
        CENTER - inner_turret // 2, tank_cy - inner_turret // 2,
        CENTER + inner_turret // 2, tank_cy + inner_turret // 2
    ], fill=TANK_DARK)

    # Turret center cap
    cap_size = 80
    draw.ellipse([
        CENTER - cap_size // 2, tank_cy - cap_size // 2,
        CENTER + cap_size // 2, tank_cy + cap_size // 2
    ], fill=TANK_GREEN)

    # === BARREL ===
    barrel_y_start = tank_cy - turret_size // 2 + 20
    barrel_y_end = barrel_y_start - barrel_length
    draw.rounded_rectangle([
        CENTER - barrel_width // 2, barrel_y_end,
        CENTER + barrel_width // 2, barrel_y_start
    ], radius=15, fill=TANK_GREEN)

    # Barrel tip (darker)
    tip_height = 40
    draw.rounded_rectangle([
        CENTER - barrel_width // 2 - 5, barrel_y_end,
        CENTER + barrel_width // 2 + 5, barrel_y_end + tip_height
    ], radius=10, fill=TANK_DARK)

    # === MUZZLE FLASH (action!) ===
    flash_cy = barrel_y_end - 50

    # Outer glow (larger, softer)
    for i in range(5, 0, -1):
        glow_size = 60 + i * 25
        alpha = 0.15 + (5 - i) * 0.1
        glow_color = (
            int(FLASH_OUTER[0] * alpha + BG_MEDIUM[0] * (1 - alpha)),
            int(FLASH_OUTER[1] * alpha + BG_MEDIUM[1] * (1 - alpha)),
            int(FLASH_OUTER[2] * alpha + BG_MEDIUM[2] * (1 - alpha))
        )
        draw.ellipse([
            CENTER - glow_size, flash_cy - glow_size // 2,
            CENTER + glow_size, flash_cy + glow_size // 2
        ], fill=glow_color)

    # Inner flash (bright core)
    draw.ellipse([
        CENTER - 50, flash_cy - 35,
        CENTER + 50, flash_cy + 35
    ], fill=MUZZLE_FLASH)

    # Bright center
    draw.ellipse([
        CENTER - 25, flash_cy - 20,
        CENTER + 25, flash_cy + 20
    ], fill=(255, 255, 220))

    # === PROJECTILE ===
    proj_y = flash_cy - 80
    proj_size = 28
    draw.ellipse([
        CENTER - proj_size // 2, proj_y - proj_size // 2,
        CENTER + proj_size // 2, proj_y + proj_size // 2
    ], fill=PROJECTILE)

    return img

if __name__ == '__main__':
    base_path = '/Users/josh/git/tankgame/tankgame Shared/Assets.xcassets/AppIcon.appiconset'

    # Generate the 1024x1024 base icon
    icon = draw_tank_icon()
    icon.save(f'{base_path}/Icon-1024.png')
    print('Generated Icon-1024.png')

    # All required sizes (actual pixel sizes)
    sizes = {
        # iPhone
        'Icon-20@2x.png': 40,
        'Icon-20@3x.png': 60,
        'Icon-29@2x.png': 58,
        'Icon-29@3x.png': 87,
        'Icon-40@2x.png': 80,
        'Icon-40@3x.png': 120,
        'Icon-60@2x.png': 120,
        'Icon-60@3x.png': 180,
        # iPad
        'Icon-20@2x~ipad.png': 40,
        'Icon-29@2x~ipad.png': 58,
        'Icon-40@2x~ipad.png': 80,
        'Icon-76@2x.png': 152,
        'Icon-83.5@2x.png': 167,
        # Mac
        'Icon-16.png': 16,
        'Icon-16@2x.png': 32,
        'Icon-32.png': 32,
        'Icon-32@2x.png': 64,
        'Icon-128.png': 128,
        'Icon-128@2x.png': 256,
        'Icon-256.png': 256,
        'Icon-256@2x.png': 512,
        'Icon-512.png': 512,
        'Icon-512@2x.png': 1024,
    }

    # Generate all sizes from the base 1024 icon
    for filename, size in sizes.items():
        resized = icon.resize((size, size), Image.LANCZOS)
        resized.save(f'{base_path}/{filename}')
        print(f'Generated {filename} ({size}x{size})')

    print(f'\nAll icons saved to: {base_path}')
