from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "weekly-planets"


THEMES = {
    "vitality": {
        "label": "活力",
        "colors": [(78, 216, 230), (255, 231, 91), (255, 130, 98), (247, 80, 170)],
        "accent": (255, 123, 94),
        "pattern": "ribbon",
    },
    "healing": {
        "label": "疗愈",
        "colors": [(255, 229, 194), (255, 178, 148), (246, 238, 214), (255, 213, 226)],
        "accent": (242, 154, 107),
        "pattern": "petal",
    },
    "stable": {
        "label": "稳定",
        "colors": [(137, 204, 233), (170, 156, 239), (240, 224, 244), (252, 189, 208)],
        "accent": (139, 184, 231),
        "pattern": "honeycomb",
    },
    "cycle-bloom": {
        "label": "周期绽放",
        "colors": [(255, 126, 187), (255, 183, 86), (127, 218, 237), (244, 181, 236)],
        "accent": (235, 98, 184),
        "pattern": "flower",
    },
    "protection": {
        "label": "保护",
        "colors": [(236, 232, 203), (162, 205, 148), (255, 216, 204), (235, 225, 244)],
        "accent": (225, 152, 124),
        "pattern": "soft-shell",
    },
}

SATELLITES = {
    "sleep": {"seed": 11, "accent": (118, 152, 229), "pattern": "honeycomb"},
    "cycle": {"seed": 17, "accent": (245, 137, 166), "pattern": "petal"},
    "stress": {"seed": 23, "accent": (218, 93, 159), "pattern": "ribbon"},
    "recovery": {"seed": 31, "accent": (94, 202, 164), "pattern": "soft-shell"},
    "activity": {"seed": 37, "accent": (255, 190, 74), "pattern": "flower"},
}


def rgba(color, alpha):
    return color + (alpha,)


def add_layer(base: Image.Image, layer: Image.Image):
    base.alpha_composite(layer)


def radial_blob(size: int, palette: list[tuple[int, int, int]], seed: int) -> Image.Image:
    random.seed(seed)
    img = Image.new("RGBA", (size, size), (248, 247, 244, 118))
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bd = ImageDraw.Draw(base)
    bd.ellipse(
        (size * 0.16, size * 0.16, size * 0.84, size * 0.84),
        fill=(255, 255, 255, 96),
    )
    img.alpha_composite(base.filter(ImageFilter.GaussianBlur(size * 0.025)))
    for i, color in enumerate(palette):
        layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        cx = int(size * random.uniform(0.32, 0.70))
        cy = int(size * random.uniform(0.28, 0.68))
        r = int(size * random.uniform(0.18, 0.32))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=rgba(color, 172 - i * 14))
        layer = layer.filter(ImageFilter.GaussianBlur(size * 0.055))
        add_layer(img, layer)
    return img


def planet_mask(size: int, radius: float = 0.36) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    cx = cy = size // 2
    r = int(size * radius)
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=230)
    mask = mask.filter(ImageFilter.GaussianBlur(size * 0.004))
    return mask


def draw_rotated_ellipse(draw: ImageDraw.ImageDraw, center, rx, ry, angle, outline, width=3, samples=220):
    pts = []
    a = math.radians(angle)
    ca, sa = math.cos(a), math.sin(a)
    cx, cy = center
    for i in range(samples + 1):
        t = i / samples * math.tau
        x = math.cos(t) * rx
        y = math.sin(t) * ry
        pts.append((cx + x * ca - y * sa, cy + x * sa + y * ca))
    draw.line(pts, fill=outline, width=width, joint="curve")


def draw_petal_pattern(layer: Image.Image, center, radius, color, seed):
    random.seed(seed)
    d = ImageDraw.Draw(layer, "RGBA")
    cx, cy = center
    for i in range(14):
        ang = i * math.tau / 14 + random.uniform(-0.08, 0.08)
        px = cx + math.cos(ang) * radius * random.uniform(0.08, 0.34)
        py = cy + math.sin(ang) * radius * random.uniform(0.08, 0.34)
        w = radius * random.uniform(0.20, 0.36)
        h = radius * random.uniform(0.08, 0.16)
        petal = Image.new("RGBA", layer.size, (0, 0, 0, 0))
        pd = ImageDraw.Draw(petal)
        pd.ellipse((px - w, py - h, px + w, py + h), fill=rgba(color, random.randint(116, 182)))
        petal = petal.rotate(math.degrees(ang), center=(px, py), resample=Image.Resampling.BICUBIC)
        layer.alpha_composite(petal)
    layer.alpha_composite(layer.filter(ImageFilter.GaussianBlur(1)))


def draw_honeycomb(layer: Image.Image, center, radius, color, seed):
    random.seed(seed)
    d = ImageDraw.Draw(layer, "RGBA")
    cx, cy = center
    step = max(22, int(radius * 0.16))
    for row, y in enumerate(range(int(cy - radius * 0.62), int(cy + radius * 0.62), step)):
        offset = step * 0.5 if row % 2 else 0
        for x in range(int(cx - radius * 0.72), int(cx + radius * 0.72), step):
            px = x + offset
            if (px - cx) ** 2 + (y - cy) ** 2 > (radius * 0.70) ** 2:
                continue
            pts = []
            rr = step * random.uniform(0.34, 0.48)
            for k in range(6):
                a = math.tau * k / 6 + math.pi / 6
                pts.append((px + math.cos(a) * rr, y + math.sin(a) * rr))
            d.line(pts + [pts[0]], fill=rgba(color, 118), width=max(2, int(radius * 0.017)))


def draw_flower(layer: Image.Image, center, radius, color, seed):
    random.seed(seed)
    d = ImageDraw.Draw(layer, "RGBA")
    cx, cy = center
    for cluster in range(3):
        ox = random.uniform(-0.28, 0.28) * radius
        oy = random.uniform(-0.28, 0.18) * radius
        for i in range(8):
            a = i * math.tau / 8
            px = cx + ox + math.cos(a) * radius * 0.12
            py = cy + oy + math.sin(a) * radius * 0.12
            d.ellipse(
                (px - radius * 0.10, py - radius * 0.045, px + radius * 0.10, py + radius * 0.045),
                fill=rgba(color, 156),
            )
        d.ellipse(
            (cx + ox - radius * 0.055, cy + oy - radius * 0.055, cx + ox + radius * 0.055, cy + oy + radius * 0.055),
            fill=(255, 222, 120, 160),
        )


def draw_internal_pattern(layer: Image.Image, pattern: str, center, radius, palette, accent, seed):
    if pattern in {"petal", "soft-shell"}:
        draw_petal_pattern(layer, center, radius, palette[1], seed)
    if pattern in {"honeycomb", "soft-shell"}:
        draw_honeycomb(layer, center, radius, accent, seed + 4)
    if pattern in {"flower", "petal"}:
        draw_flower(layer, center, radius, accent, seed + 8)
    if pattern == "ribbon":
        d = ImageDraw.Draw(layer, "RGBA")
        for i in range(9):
            a = -24 + i * 6
            draw_rotated_ellipse(
                d,
                center,
                radius * random.uniform(0.32, 0.66),
                radius * random.uniform(0.10, 0.20),
                a,
                rgba(random.choice(palette), 74),
                width=max(2, int(radius * 0.018)),
            )


def draw_orbits(layer: Image.Image, center, radius, accent, seed, scale=1.0):
    random.seed(seed)
    d = ImageDraw.Draw(layer, "RGBA")
    for i, angle in enumerate((-8, 2, 10)):
        width = max(3, int(radius * (0.028 - i * 0.004) * scale))
        color = rgba(accent, 170 - i * 26)
        draw_rotated_ellipse(
            d,
            center,
            radius * (1.42 + i * 0.11),
            radius * (0.25 + i * 0.025),
            angle,
            color,
            width=width,
        )
    for i in range(4):
        a = random.uniform(0, math.tau)
        rr = radius * random.uniform(1.22, 1.58)
        sx = center[0] + math.cos(a) * rr
        sy = center[1] + math.sin(a) * radius * 0.33
        r = radius * random.uniform(0.035, 0.070)
        d.ellipse((sx - r, sy - r, sx + r, sy + r), fill=rgba(accent, 130), outline=rgba((255, 255, 255), 130), width=max(1, int(radius * 0.008)))


def paste_rotated_ellipse(
    layer: Image.Image,
    center: tuple[float, float],
    rx: float,
    ry: float,
    angle: float,
    fill: tuple[int, int, int, int],
    blur: float = 0.0,
):
    shape = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(shape, "RGBA")
    cx, cy = center
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=fill)
    shape = shape.rotate(angle, center=center, resample=Image.Resampling.BICUBIC)
    if blur:
        shape = shape.filter(ImageFilter.GaussianBlur(blur))
    layer.alpha_composite(shape)


def draw_matte_shadow(layer: Image.Image, center, radius):
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow, "RGBA")
    cx, cy = center
    d.ellipse(
        (cx - radius * 1.02, cy + radius * 0.56, cx + radius * 1.04, cy + radius * 0.94),
        fill=(124, 115, 116, 30),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius * 0.12))
    layer.alpha_composite(shadow)


def draw_paper_grain(layer: Image.Image, seed: int, alpha: int):
    random.seed(seed)
    w, h = layer.size
    grain_size = 220
    grain = Image.new("RGBA", (grain_size, grain_size), (0, 0, 0, 0))
    px = grain.load()
    for y in range(grain_size):
        for x in range(grain_size):
            tone = random.randint(232, 255)
            px[x, y] = (tone, tone, tone, random.randint(0, alpha))
    grain = grain.resize((w, h), Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(0.8))
    layer.alpha_composite(grain)


def draw_matte_orbits(layer: Image.Image, center, radius, accent, seed, satellite=False):
    random.seed(seed)
    d = ImageDraw.Draw(layer, "RGBA")
    orbit_angles = (-8, -3, 4, 9) if not satellite else (-7, 5)
    for i, angle in enumerate(orbit_angles):
        width = max(3, int(radius * (0.014 if not satellite else 0.020)))
        color = rgba(accent if i % 2 == 0 else (242, 139, 207), 96 - i * 10)
        draw_rotated_ellipse(
            d,
            center,
            radius * (1.58 + i * 0.08),
            radius * (0.26 + i * 0.018),
            angle,
            color,
            width=width,
            samples=260,
        )
    if not satellite:
        for _ in range(3):
            a = random.uniform(0, math.tau)
            sx = center[0] + math.cos(a) * radius * random.uniform(1.20, 1.58)
            sy = center[1] + math.sin(a) * radius * random.uniform(0.22, 0.34)
            rr = radius * random.uniform(0.026, 0.045)
            d.ellipse((sx - rr, sy - rr, sx + rr, sy + rr), fill=rgba(accent, 112))


def draw_flower_planet(layer: Image.Image, theme, center, radius, seed, satellite=False, sat_accent=None, sat_pattern=None):
    random.seed(seed)
    palette = list(theme["colors"])
    accent = sat_accent or theme["accent"]
    pattern = sat_pattern or theme["pattern"]
    cx, cy = center

    cloud = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(cloud, "RGBA")
    d.ellipse((cx - radius * 0.88, cy - radius * 0.80, cx + radius * 0.92, cy + radius * 0.84), fill=(255, 251, 247, 132))
    for i, color in enumerate(palette * 2):
        ox = random.uniform(-0.44, 0.42) * radius
        oy = random.uniform(-0.36, 0.36) * radius
        rx = radius * random.uniform(0.30, 0.58)
        ry = radius * random.uniform(0.22, 0.46)
        d.ellipse((cx + ox - rx, cy + oy - ry, cx + ox + rx, cy + oy + ry), fill=rgba(color, 108 + i * 5))
    cloud = cloud.filter(ImageFilter.GaussianBlur(radius * 0.025))
    layer.alpha_composite(cloud)

    petals = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    count = 28 if not satellite else 16
    for i in range(count):
        angle = -82 + i * (164 / max(1, count - 1)) + random.uniform(-8, 8)
        spread = math.radians(angle)
        px = cx + math.sin(spread) * radius * random.uniform(0.08, 0.42)
        py = cy - radius * random.uniform(0.04, 0.36) + abs(math.sin(spread)) * radius * 0.18
        petal_color = palette[i % len(palette)]
        paste_rotated_ellipse(
            petals,
            (px, py),
            radius * random.uniform(0.16, 0.27) * (0.72 if satellite else 1),
            radius * random.uniform(0.42, 0.66) * (0.72 if satellite else 1),
            math.degrees(spread) * 0.55 + random.uniform(-14, 14),
            rgba(petal_color, random.randint(128, 184)),
            blur=radius * 0.004,
        )
    petals = petals.filter(ImageFilter.GaussianBlur(radius * 0.004))
    layer.alpha_composite(petals)

    ribbons = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    rd = ImageDraw.Draw(ribbons, "RGBA")
    ribbon_count = 5 if not satellite else 3
    for i in range(ribbon_count):
        angle = -58 + i * (116 / max(1, ribbon_count - 1)) + random.uniform(-5, 5)
        color = palette[(i + 1) % len(palette)]
        draw_rotated_ellipse(
            rd,
            center,
            radius * random.uniform(0.22, 0.56),
            radius * random.uniform(0.62, 0.92),
            angle,
            rgba(color, 40 if not satellite else 34),
            width=max(4, int(radius * (0.026 if not satellite else 0.034))),
            samples=220,
        )
    layer.alpha_composite(ribbons.filter(ImageFilter.GaussianBlur(radius * 0.003)))

    if pattern in {"honeycomb", "soft-shell"}:
        detail = Image.new("RGBA", layer.size, (0, 0, 0, 0))
        draw_honeycomb(detail, center, radius * 0.90, accent, seed + 71)
        detail = detail.filter(ImageFilter.GaussianBlur(radius * 0.003))
        layer.alpha_composite(detail)
    if pattern in {"flower", "petal"}:
        detail = Image.new("RGBA", layer.size, (0, 0, 0, 0))
        draw_flower(detail, center, radius * 0.92, accent, seed + 101)
        detail = detail.filter(ImageFilter.GaussianBlur(radius * 0.006))
        layer.alpha_composite(detail)

    edge = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    ed = ImageDraw.Draw(edge, "RGBA")
    ed.arc(
        (cx - radius * 0.82, cy - radius * 0.74, cx + radius * 0.84, cy + radius * 0.88),
        start=202,
        end=340,
        fill=(255, 255, 255, 46),
        width=max(3, int(radius * 0.018)),
    )
    ed.arc(
        (cx - radius * 0.96, cy - radius * 0.88, cx + radius * 0.82, cy + radius * 0.78),
        start=128,
        end=236,
        fill=(177, 185, 193, 32),
        width=max(3, int(radius * 0.014)),
    )
    layer.alpha_composite(edge.filter(ImageFilter.GaussianBlur(radius * 0.004)))


def draw_pom_satellite(layer: Image.Image, center, radius, palette, accent, seed):
    random.seed(seed)
    d = ImageDraw.Draw(layer, "RGBA")
    cx, cy = center
    for i in range(42):
        a = random.uniform(0, math.tau)
        dist = radius * random.uniform(0.05, 0.68)
        rr = radius * random.uniform(0.10, 0.19)
        color = random.choice(palette + [accent])
        px = cx + math.cos(a) * dist
        py = cy + math.sin(a) * dist
        d.ellipse((px - rr, py - rr, px + rr, py + rr), fill=rgba(color, random.randint(78, 132)))
    d.ellipse((cx - radius * 0.68, cy - radius * 0.68, cx + radius * 0.68, cy + radius * 0.68), outline=(255, 255, 255, 58), width=max(2, int(radius * 0.035)))


def make_planet(size: int, theme: dict, seed: int, satellite: bool = False, sat_accent=None, sat_pattern=None) -> Image.Image:
    scale = 2
    s = size * scale
    center = (s // 2, int(s * (0.52 if not satellite else 0.50)))
    radius = s * (0.34 if not satellite else 0.265)
    palette = list(theme["colors"])
    accent = sat_accent or theme["accent"]
    pattern = sat_pattern or theme["pattern"]

    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_matte_shadow(img, center, radius)

    back_orbits = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_matte_orbits(back_orbits, center, radius, accent, seed + 3, satellite=satellite)
    if not satellite:
        img.alpha_composite(back_orbits.filter(ImageFilter.GaussianBlur(radius * 0.004)))

    if satellite and pattern in {"flower", "petal", "honeycomb"}:
        body = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        draw_pom_satellite(body, center, radius, palette, accent, seed + 5)
        body = body.filter(ImageFilter.GaussianBlur(radius * 0.006))
        img.alpha_composite(body)
    else:
        body = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        draw_flower_planet(body, theme, center, radius, seed, satellite=satellite, sat_accent=sat_accent, sat_pattern=sat_pattern)
        img.alpha_composite(body)

    front_orbits = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw_matte_orbits(front_orbits, center, radius * (1.02 if not satellite else 0.86), accent, seed + 17, satellite=satellite)
    front_orbits = front_orbits.filter(ImageFilter.GaussianBlur(radius * 0.002))
    if not satellite:
        img.alpha_composite(front_orbits)

    draw_paper_grain(img, seed + 401, 9 if not satellite else 7)
    img = img.filter(ImageFilter.UnsharpMask(radius=0.8, percent=22, threshold=5))
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    return img


def make_board():
    tile = 360
    board = Image.new("RGB", (tile * 3, tile * 2), (248, 247, 243))
    for i, (theme_id, theme) in enumerate(THEMES.items()):
        p = OUT / theme_id / "main.webp"
        img = Image.open(p).convert("RGBA").resize((tile, tile), Image.Resampling.LANCZOS)
        x = (i % 3) * tile
        y = (i // 3) * tile
        board.paste(img, (x, y), img)
        d = ImageDraw.Draw(board)
        d.text((x + 20, y + 20), theme["label"], fill=(72, 82, 80))
    board.save(OUT / "preview-board.png")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for index, (theme_id, theme) in enumerate(THEMES.items()):
        target = OUT / theme_id
        target.mkdir(parents=True, exist_ok=True)
        main_img = make_planet(768, theme, 100 + index * 19)
        main_img.save(target / "main.webp", "WEBP", quality=92, method=4, lossless=False)
        for sat_id, sat in SATELLITES.items():
            sat_img = make_planet(
                320,
                theme,
                500 + index * 41 + sat["seed"],
                satellite=True,
                sat_accent=sat["accent"],
                sat_pattern=sat["pattern"],
            )
            sat_img.save(target / f"{sat_id}.webp", "WEBP", quality=92, method=4, lossless=False)
    make_board()
    print(f"Wrote weekly planet assets to {OUT}")


if __name__ == "__main__":
    main()
