from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent
W, H = 1206, 2622

INK = (18, 24, 38, 255)
INK_2 = (94, 102, 119, 255)
INK_3 = (138, 147, 166, 255)
BLUE = (63, 140, 255, 255)
CYAN = (82, 199, 247, 255)
MINT = (112, 213, 160, 255)
YELLOW = (244, 200, 78, 255)
PINK = (244, 140, 168, 255)
ORANGE = (255, 154, 89, 255)
LAVENDER = (168, 167, 255, 255)
WHITE = (255, 255, 255, 255)

FONT_REGULAR = "/System/Library/Fonts/STHeiti Light.ttc"
FONT_BOLD = "/System/Library/Fonts/STHeiti Medium.ttc"
FONT_DIGIT = "/System/Library/Fonts/SFNS.ttf"


def font(size: int, bold: bool = False, digit: bool = False) -> ImageFont.FreeTypeFont:
    path = FONT_DIGIT if digit else (FONT_BOLD if bold else FONT_REGULAR)
    try:
        return ImageFont.truetype(path, size)
    except OSError:
        return ImageFont.load_default()


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def draw_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    size: int,
    fill=INK,
    bold: bool = False,
    digit: bool = False,
    anchor: str | None = None,
) -> None:
    draw.text(xy, text, font=font(size, bold=bold, digit=digit), fill=fill, anchor=anchor)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, max_width: int, fnt: ImageFont.FreeTypeFont) -> list[str]:
    lines: list[str] = []
    line = ""
    for char in text:
        candidate = line + char
        if text_size(draw, candidate, fnt)[0] <= max_width or not line:
            line = candidate
        else:
            lines.append(line.rstrip())
            line = char.lstrip()
    if line:
        lines.append(line.rstrip())
    return lines


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    max_width: int,
    size: int,
    fill=INK_2,
    bold: bool = False,
    line_gap: int = 10,
    max_lines: int | None = None,
) -> int:
    fnt = font(size, bold=bold)
    lines = wrap_text(draw, text, max_width, fnt)
    if max_lines is not None:
        lines = lines[:max_lines]
    x, y = xy
    line_h = int(size * 1.35)
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        y += line_h + line_gap
    return y


def rgba(color, alpha: int):
    return (color[0], color[1], color[2], alpha)


def add_blurred_ellipse(img: Image.Image, box: tuple[int, int, int, int], color, blur: int) -> None:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse(box, fill=color)
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    img.alpha_composite(layer)


def background(scene: str = "today") -> Image.Image:
    img = Image.new("RGBA", (W, H), (248, 251, 255, 255))
    add_blurred_ellipse(img, (-250, 900, 560, 1840), (185, 242, 227, 92), 110)
    add_blurred_ellipse(img, (640, 360, 1370, 1180), (255, 234, 212, 92), 140)
    add_blurred_ellipse(img, (700, 1700, 1420, 2630), (220, 204, 255, 82), 130)
    if scene == "cycle":
        add_blurred_ellipse(img, (-150, 260, 580, 960), (244, 200, 78, 58), 120)
        add_blurred_ellipse(img, (690, 960, 1390, 1780), (99, 213, 154, 56), 140)
    elif scene == "evening":
        add_blurred_ellipse(img, (-160, 120, 620, 900), (168, 167, 255, 64), 130)
        add_blurred_ellipse(img, (650, 900, 1320, 1720), (255, 154, 89, 62), 135)
    return img


def rounded_shadow(
    img: Image.Image,
    box: tuple[int, int, int, int],
    radius: int,
    fill=(255, 255, 255, 220),
    outline=(255, 255, 255, 210),
    shadow=(82, 129, 180, 34),
    blur: int = 24,
    y_offset: int = 14,
) -> ImageDraw.ImageDraw:
    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_layer)
    sx1, sy1, sx2, sy2 = box
    sd.rounded_rectangle((sx1, sy1 + y_offset, sx2, sy2 + y_offset), radius, fill=shadow)
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(blur))
    img.alpha_composite(shadow_layer)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(box, radius, fill=fill, outline=outline, width=2)
    d.rounded_rectangle((box[0] + 6, box[1] + 6, box[2] - 6, box[1] + 22), radius // 2, fill=(255, 255, 255, 44))
    return d


def status_bar(draw: ImageDraw.ImageDraw, time_text: str = "13:41") -> None:
    draw_text(draw, (158, 78), time_text, 48, bold=True)
    draw.rounded_rectangle((414, 42, 792, 153), 58, fill=(0, 0, 0, 255))
    for i in range(4):
        x = 866 + i * 18
        draw.rounded_rectangle((x, 106, x + 10, 116), 5, fill=(188, 190, 195, 255))
    draw.arc((946, 76, 1000, 120), 205, 335, fill=(0, 0, 0, 255), width=8)
    draw.arc((932, 58, 1014, 132), 205, 335, fill=(0, 0, 0, 255), width=9)
    draw.rounded_rectangle((1020, 79, 1093, 116), 13, outline=(0, 0, 0, 255), width=5)
    draw.rounded_rectangle((1028, 87, 1085, 108), 8, fill=(0, 0, 0, 255))
    draw.rounded_rectangle((1097, 91, 1103, 104), 3, fill=(0, 0, 0, 255))


def pixel_vitora(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: int = 5, alpha: int = 235) -> None:
    # Soft blob body.
    body = Image.new("RGBA", (scale * 30, scale * 28), (0, 0, 0, 0))
    bd = ImageDraw.Draw(body)
    bd.ellipse((scale * 3, scale * 1, scale * 27, scale * 25), fill=(255, 245, 238, alpha), outline=(255, 255, 255, 235), width=max(2, scale))
    bd.ellipse((scale * 6, scale * 6, scale * 20, scale * 20), fill=(255, 173, 118, 92))
    bd.ellipse((scale * 11, scale * 8, scale * 26, scale * 23), fill=(129, 219, 236, 72))
    bd.ellipse((scale * 12, scale * 2, scale * 25, scale * 15), fill=(255, 219, 130, 65))
    body = body.filter(ImageFilter.GaussianBlur(scale // 2))
    x = cx - body.width // 2
    y = cy - body.height // 2
    draw.bitmap((0, 0), Image.new("1", (1, 1)), fill=(0, 0, 0, 0))
    return body, x, y


def paste_pixel_vitora(img: Image.Image, cx: int, cy: int, scale: int = 5, alpha: int = 235) -> None:
    body, x, y = pixel_vitora(ImageDraw.Draw(img), cx, cy, scale, alpha)
    img.alpha_composite(body, (x, y))
    d = ImageDraw.Draw(img)
    unit = scale
    eye_y = cy - scale * 2
    for ex in (cx - scale * 4, cx + scale * 2):
        for row in range(3):
            d.rounded_rectangle((ex, eye_y + row * unit * 1.2, ex + unit * 1.2, eye_y + row * unit * 1.2 + unit), 1, fill=(255, 255, 255, 255))
    d.ellipse((cx - scale * 10, cy + scale * 11, cx + scale * 10, cy + scale * 15), fill=(82, 129, 180, 42))


def header_today(img: Image.Image, d: ImageDraw.ImageDraw, chip: str = "低数据模式") -> None:
    d.rounded_rectangle((78, 244, 132, 292), 10, fill=INK)
    for r in range(3):
        for c in range(4):
            d.rectangle((92 + c * 9, 257 + r * 9, 98 + c * 9, 263 + r * 9), fill=WHITE)
    draw_text(d, (182, 225), "5月5日 · 黄体期 Day 18", 47, bold=True)
    draw_text(d, (182, 282), "黄体期中段 · 今天适合留余量", 30, fill=(128, 133, 143, 255), bold=True)
    d.rounded_rectangle((934, 225, 1125, 306), 40, fill=(255, 255, 255, 150), outline=(255, 255, 255, 160), width=2)
    draw_text(d, (1029, 253), chip, 29, fill=BLUE, bold=True, anchor="ma")
    paste_pixel_vitora(img, 1080, 366, 5, 210)


def draw_button(d: ImageDraw.ImageDraw, box, label: str, selected: bool = False, icon_color=BLUE) -> None:
    fill = (255, 255, 255, 245) if not selected else (235, 247, 255, 255)
    outline = (255, 255, 255, 220) if not selected else rgba(BLUE, 150)
    d.rounded_rectangle(box, 45, fill=fill, outline=outline, width=2)
    if selected:
        d.ellipse((box[0] + 26, box[1] + 28, box[0] + 58, box[1] + 60), fill=rgba(icon_color, 210))
    draw_text(d, (box[0] + 78, box[1] + 25), label, 32, fill=INK if selected else INK_2, bold=True)


def draw_nav(img: Image.Image, selected: str = "today") -> None:
    d = ImageDraw.Draw(img)
    rounded_shadow(img, (48, 2220, 1158, 2488), 92, fill=(255, 255, 255, 150), outline=(255, 255, 255, 180), shadow=(118, 158, 190, 40), blur=36)
    d.rounded_rectangle((246, 2254, 960, 2425), 86, fill=(255, 255, 255, 130), outline=(255, 255, 255, 175), width=2)

    def tab_box(x1, active):
        if active:
            d.rounded_rectangle((x1, 2270, x1 + 205, 2406), 64, fill=(255, 255, 255, 232), outline=(255, 255, 255, 235), width=2)

    tab_box(280, selected == "today")
    tab_box(505, selected == "vitora")
    tab_box(737, selected == "cycle")
    # Simple home glyph.
    d.line((304, 2327, 336, 2296, 368, 2327), fill=INK if selected == "today" else (145, 145, 150, 255), width=8, joint="curve")
    d.rectangle((318, 2326, 354, 2367), outline=INK if selected == "today" else (145, 145, 150, 255), width=7)
    draw_text(d, (385, 2317), "今日", 33, fill=INK if selected == "today" else (130, 132, 142, 255), bold=True, anchor="ma")
    # Pixel Vitora tab face.
    paste_pixel_vitora(img, 552, 2338, 3, 220)
    draw_text(d, (630, 2317), "管家", 33, fill=INK if selected == "vitora" else (130, 132, 142, 255), bold=True, anchor="ma")
    # Cycle flower glyph.
    for ang in range(0, 360, 72):
        px = 785 + int(math.cos(math.radians(ang)) * 21)
        py = 2338 + int(math.sin(math.radians(ang)) * 21)
        d.ellipse((px - 15, py - 15, px + 15, py + 15), fill=(120, 120, 128, 130))
    d.ellipse((770, 2323, 800, 2353), fill=(120, 120, 128, 160))
    draw_text(d, (854, 2317), "周期", 33, fill=INK if selected == "cycle" else (130, 132, 142, 255), bold=True, anchor="ma")
    d.rounded_rectangle((996, 2280, 1128, 2414), 66, fill=(255, 255, 255, 205), outline=(255, 255, 255, 220), width=2)
    d.line((1062, 2320, 1062, 2374), fill=INK, width=9)
    d.line((1035, 2347, 1089, 2347), fill=INK, width=9)


def draw_cycle_arc(d: ImageDraw.ImageDraw, y: int) -> None:
    x0, x1 = 196, 1012
    pts = []
    for i in range(81):
        t = i / 80
        x = x0 + (x1 - x0) * t
        yy = y + math.sin(t * math.pi) * 74
        pts.append((x, yy))
    segments = [(0, 24, MINT), (24, 57, YELLOW), (57, 80, PINK)]
    for a, b, color in segments:
        d.line(pts[a : b + 1], fill=color, width=15, joint="curve")
    for t, color in [(0.16, MINT), (0.5, YELLOW), (0.84, PINK)]:
        x = x0 + (x1 - x0) * t
        yy = y + math.sin(t * math.pi) * 74
        d.ellipse((x - 30, yy - 30, x + 30, yy + 30), fill=(255, 255, 255, 140), outline=(255, 255, 255, 220), width=2)
        if t == 0.5:
            d.ellipse((x - 13, yy - 13, x + 13, yy + 13), fill=YELLOW)
        elif t < 0.5:
            d.polygon([(x, yy - 20), (x + 9, yy), (x, yy + 20), (x - 9, yy)], fill=MINT)
        else:
            d.polygon([(x, yy - 22), (x + 18, yy + 18), (x - 18, yy + 18)], fill=PINK)
    draw_text(d, (326, y + 184), "排卵期", 33, fill=(166, 169, 176, 255), bold=True, anchor="ma")
    draw_text(d, (603, y + 184), "黄体期 D18", 40, fill=INK, bold=True, anchor="ma")
    draw_text(d, (879, y + 184), "月经期", 33, fill=(166, 169, 176, 255), bold=True, anchor="ma")


def flower_pixels(d: ImageDraw.ImageDraw, cx: int, base_y: int, state: str, scale: int = 9) -> None:
    s = scale

    def px(gx: int, gy: int, gw: int, gh: int, color) -> None:
        d.rectangle(
            (cx + gx * s, base_y + gy * s, cx + (gx + gw) * s, base_y + (gy + gh) * s),
            fill=color,
        )

    def stem(height: int = 18) -> None:
        px(-1, -height, 1, height, (54, 147, 91, 255))
        px(0, -height, 1, height, (80, 184, 112, 255))
        px(-8, -9, 6, 2, (72, 174, 105, 255))
        px(-10, -10, 3, 2, (109, 204, 139, 255))
        px(-7, -7, 5, 2, (57, 154, 94, 255))
        px(1, -12, 8, 2, (83, 188, 124, 255))
        px(6, -13, 4, 2, (117, 211, 151, 255))
        px(2, -10, 6, 2, (62, 159, 101, 255))

    if state == "seed":
        px(-7, -2, 14, 2, (181, 143, 87, 170))
        px(-5, -6, 10, 6, (187, 137, 71, 255))
        px(-4, -7, 8, 1, (226, 177, 87, 255))
        px(-3, -5, 4, 2, (255, 212, 111, 255))
        px(1, -4, 3, 1, (132, 102, 62, 160))
        return

    if state == "sleep":
        px(-1, -12, 1, 10, (60, 146, 91, 255))
        px(-2, -14, 1, 3, (67, 155, 96, 255))
        px(-4, -16, 2, 3, (68, 159, 98, 255))
        px(-8, -9, 5, 2, (76, 170, 105, 255))
        px(0, -10, 7, 2, (91, 184, 120, 255))
        px(-10, -21, 7, 5, (134, 177, 146, 255))
        px(-12, -20, 3, 4, (172, 204, 182, 255))
        px(-8, -23, 4, 2, (203, 222, 209, 255))
        px(-7, -18, 5, 3, (105, 151, 121, 255))
        px(-6, -19, 2, 1, (230, 238, 228, 180))
    elif state == "bud":
        stem(15)
        px(-5, -26, 10, 2, (222, 112, 145, 255))
        px(-7, -24, 14, 9, (236, 136, 166, 255))
        px(-5, -27, 8, 5, (255, 193, 142, 255))
        px(-3, -29, 5, 4, (255, 221, 125, 255))
        px(2, -24, 4, 8, (248, 168, 188, 255))
        px(-6, -17, 12, 3, (91, 176, 112, 255))
        px(-3, -23, 2, 5, (255, 232, 181, 150))
    elif state == "half":
        stem(18)
        # Petal outline.
        px(-9, -31, 7, 9, (223, 103, 143, 255))
        px(2, -31, 7, 9, (235, 132, 91, 255))
        px(-4, -36, 8, 9, (230, 170, 72, 255))
        px(-7, -26, 14, 8, (225, 106, 150, 255))
        # Lit petal surfaces.
        px(-8, -30, 6, 7, (247, 134, 169, 255))
        px(3, -30, 5, 7, (255, 176, 125, 255))
        px(-3, -35, 6, 8, (255, 223, 130, 255))
        px(-5, -25, 10, 6, (255, 154, 178, 255))
        px(-1, -28, 4, 5, (255, 211, 62, 255))
        px(-6, -29, 2, 2, (255, 219, 228, 155))
        px(4, -28, 2, 2, (255, 235, 206, 150))
    elif state == "bloom":
        stem(20)
        # Back petals: warm outline first, then soft lit fill.
        px(-4, -41, 9, 10, (225, 154, 72, 255))
        px(-13, -35, 10, 10, (220, 93, 136, 255))
        px(4, -35, 10, 10, (231, 118, 75, 255))
        px(-16, -27, 9, 8, (235, 136, 86, 255))
        px(7, -27, 9, 8, (229, 156, 82, 255))
        px(-6, -29, 12, 12, (222, 88, 136, 255))
        # Front fills.
        px(-3, -40, 7, 9, (255, 224, 128, 255))
        px(-12, -34, 8, 8, (246, 130, 168, 255))
        px(5, -34, 8, 8, (255, 164, 104, 255))
        px(-15, -26, 8, 7, (255, 192, 129, 255))
        px(8, -26, 8, 7, (255, 203, 136, 255))
        px(-5, -28, 10, 10, (255, 154, 177, 255))
        px(-2, -30, 5, 7, (255, 214, 57, 255))
        px(-9, -32, 3, 3, (255, 219, 229, 145))
        px(7, -32, 3, 3, (255, 232, 205, 145))
        px(-1, -39, 2, 3, (255, 246, 184, 155))


def draw_rain(d: ImageDraw.ImageDraw, x1: int, y1: int, x2: int, y2: int) -> None:
    drops = [(0.12, 0.15), (0.26, 0.04), (0.39, 0.2), (0.52, 0.08), (0.68, 0.18), (0.82, 0.06)]
    for tx, ty in drops:
        x = int(x1 + (x2 - x1) * tx)
        y = int(y1 + (y2 - y1) * ty)
        d.line((x, y, x - 18, y + 54), fill=(88, 178, 248, 175), width=9)
        d.ellipse((x - 26, y + 51, x + 10, y + 71), fill=(130, 208, 255, 62))


def draw_bowl(
    img: Image.Image,
    d: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    energy: int,
    flower_state: str,
    rain: bool = False,
    glow: bool = False,
) -> None:
    x, y, w, h = box
    if glow:
        add_blurred_ellipse(img, (x + 180, y + 245, x + w - 180, y + h + 80), (255, 214, 100, 64), 52)
    if rain:
        draw_rain(d, x + 210, y + 80, x + w - 210, y + 360)

    mask = Image.new("L", (W, H), 0)
    md = ImageDraw.Draw(mask)
    md.pieslice((x, y, x + w, y + h * 2), 0, 180, fill=255)
    water_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wd = ImageDraw.Draw(water_layer)
    level = 0.28 + min(max(energy, 35), 92) / 100 * 0.34
    water_y = int(y + h - h * level)
    wd.rectangle((x + 20, water_y, x + w - 20, y + h + 120), fill=(119, 191, 255, 72))
    wd.rectangle((x + 20, water_y + 65, x + w - 20, y + h + 130), fill=(255, 205, 171, 80))
    water_layer.putalpha(Image.composite(water_layer.getchannel("A"), Image.new("L", (W, H), 0), mask))
    img.alpha_composite(water_layer)

    # Bowl rim and body.
    d.arc((x, y - 46, x + w, y + 92), 180, 360, fill=(221, 234, 248, 190), width=7)
    d.line((x + 30, y + 24, x + w - 30, y + 24), fill=(225, 237, 249, 220), width=5)
    d.arc((x, y, x + w, y + h * 2), 0, 180, fill=(225, 237, 249, 200), width=7)
    d.line((x + 60, water_y, x + w - 60, water_y), fill=(131, 184, 245, 142), width=5)
    d.arc((x + 40, water_y - 25, x + w - 40, water_y + 45), 180, 360, fill=(255, 255, 255, 70), width=3)

    flower_base = water_y - 18
    flower_pixels(d, x + w // 2, flower_base, flower_state, 8 if flower_state != "bloom" else 9)


def status_card(
    img: Image.Image,
    energy: int,
    status: str,
    line: str,
    flower_state: str,
    rain: bool = False,
    glow: bool = False,
) -> None:
    d = ImageDraw.Draw(img)
    rounded_shadow(img, (80, 395, 1127, 1786), 88, fill=(255, 255, 255, 162), outline=(255, 255, 255, 180), shadow=(116, 170, 205, 30), blur=36)
    draw_text(d, (600, 485), str(energy), 178, fill=BLUE, bold=True, digit=True, anchor="ma")
    draw_text(d, (785, 548), "%", 72, fill=BLUE, bold=True, digit=True)
    draw_text(d, (476, 736), status, 54, fill=INK, bold=True, anchor="ma")
    d.rounded_rectangle((668, 714, 938, 801), 44, fill=(255, 255, 255, 178), outline=(255, 255, 255, 200), width=2)
    draw_text(d, (801, 738), "查看数据", 34, fill=BLUE, bold=True, anchor="ma")
    draw_text(d, (602, 828), line, 30, fill=INK_2, bold=True, anchor="ma")
    draw_bowl(img, d, (155, 1002, 900, 440), energy, flower_state, rain=rain, glow=glow)
    draw_cycle_arc(d, 1570)


def suggestion_card(img: Image.Image, state: str = "fresh", energy: int = 68) -> None:
    d = ImageDraw.Draw(img)
    y1 = 1788
    rounded_shadow(img, (56, y1, 1150, 2225), 52, fill=(255, 255, 255, 223), outline=(255, 255, 255, 230), shadow=(100, 160, 180, 40), blur=28)
    draw_text(d, (118, y1 + 42), "✦", 47, fill=ORANGE, bold=True)
    draw_text(d, (180, y1 + 45), "Vitora 今日建议", 44, bold=True)
    inner = (92, y1 + 128, 1114, y1 + 335)
    d.rounded_rectangle(inner, 36, fill=(255, 255, 255, 145), outline=(255, 255, 255, 185), width=2)
    if state == "running":
        title = "进行中：给恢复种子下一场小雨。"
        body = "你已选择下午留 20 分钟安静恢复。花苞先打开一层，今晚再确认这件事是否真的帮到你。"
        cta = "已记录"
    elif state == "done":
        title = "已记录，今晚复盘时确认它是否真的帮到你。"
        body = f"能量更新到 {energy}%。这不是完成率，而是 Vitora 暂时看到你的状态更稳。"
        cta = "今晚确认"
    else:
        title = "你的恢复处在平衡区，今天适合稳住节奏。"
        body = "睡眠时长略短，但 HRV 没有明显下滑，所以今天不是完全低谷，而是需要避免透支。下午留 20 分钟安静恢复，可以让这颗恢复种子继续打开。"
        cta = "我试试"
    draw_wrapped(d, (128, y1 + 158), title, 930, 41, fill=INK, bold=True, line_gap=2, max_lines=2)
    draw_wrapped(d, (128, y1 + 256), body, 900, 28, fill=INK_2, bold=True, line_gap=2, max_lines=2)
    draw_button(d, (95, y1 + 322, 325, y1 + 416), cta, selected=True, icon_color=BLUE)
    d.rounded_rectangle((352, y1 + 322, 1015, y1 + 416), 46, fill=(255, 255, 255, 150), outline=(255, 255, 255, 180), width=2)
    draw_text(d, (384, y1 + 348), "午后留 20 分钟安静恢复", 31, fill=INK, bold=True)
    d.ellipse((966, y1 + 349, 996, y1 + 379), fill=(83, 191, 134, 255))


def seed_icon(d: ImageDraw.ImageDraw, cx: int, cy: int, color) -> None:
    d.ellipse((cx - 26, cy - 36, cx + 26, cy + 36), fill=rgba(color, 210), outline=(255, 255, 255, 200), width=2)
    d.rectangle((cx - 8, cy - 14, cx + 8, cy + 18), fill=rgba((255, 255, 255, 255), 145))
    d.rectangle((cx + 5, cy - 4, cx + 21, cy + 4), fill=rgba((255, 255, 255, 255), 120))


def frame_01() -> Image.Image:
    img = background("evening")
    d = ImageDraw.Draw(img)
    status_bar(d, "21:46")
    header_today(img, d, "晚间复盘")
    status_card(img, 72, "晚间能量趋稳", "今天的建议等待你确认是否有帮助", "half", glow=True)
    overlay = Image.new("RGBA", (W, H), (18, 24, 38, 55))
    img.alpha_composite(overlay)
    d = ImageDraw.Draw(img)
    rounded_shadow(img, (0, 1130, W, 2625), 82, fill=(255, 255, 255, 235), outline=(255, 255, 255, 230), shadow=(20, 42, 60, 70), blur=42, y_offset=-16)
    d.rounded_rectangle((520, 1163, 686, 1176), 7, fill=(210, 216, 225, 255))
    draw_text(d, (96, 1228), "选择今晚的种子", 48, bold=True)
    draw_wrapped(d, (96, 1292), "让 Vitora 明早看看你的身体恢复到了哪里", 870, 31, fill=INK_2, bold=True)
    cards = [
        ((86, 1415, 1120, 1590), "恢复种子", "适合疲劳、睡眠不足、HRV 偏低", CYAN, True),
        ((86, 1624, 1120, 1799), "留余量种子", "适合明天负荷大、周期低谷前后", YELLOW, False),
        ((86, 1833, 1120, 2008), "轻动种子", "适合低能但需要恢复循环", MINT, False),
    ]
    for box, title, sub, color, selected in cards:
        fill = (236, 248, 255, 255) if selected else (255, 255, 255, 178)
        outline = rgba(BLUE if selected else WHITE, 210)
        d.rounded_rectangle(box, 38, fill=fill, outline=outline, width=3)
        seed_icon(d, box[0] + 80, box[1] + 88, color)
        draw_text(d, (box[0] + 145, box[1] + 42), title, 38, bold=True, fill=INK)
        draw_text(d, (box[0] + 145, box[1] + 96), sub, 28, bold=True, fill=INK_2)
        if selected:
            d.rounded_rectangle((box[2] - 145, box[1] + 50, box[2] - 42, box[1] + 112), 31, fill=rgba(BLUE, 230))
            draw_text(d, (box[2] - 94, box[1] + 63), "已选", 26, fill=WHITE, bold=True, anchor="ma")
    d.rounded_rectangle((86, 2074, 1120, 2229), 40, fill=(245, 250, 255, 255), outline=(255, 255, 255, 255), width=2)
    draw_text(d, (126, 2118), "已种下：恢复种子", 37, fill=INK, bold=True)
    draw_wrapped(d, (126, 2171), "明早会根据睡眠、HRV、心率和周期阶段判断它的状态", 920, 28, fill=INK_2, bold=True)
    return img


def frame_02() -> Image.Image:
    img = background("today")
    d = ImageDraw.Draw(img)
    status_bar(d)
    header_today(img, d)
    status_card(img, 68, "能量平衡", "恢复种子在能量盆里半开，今天适合稳住节奏", "bud")
    suggestion_card(img, "fresh", 68)
    draw_nav(img, "today")
    return img


def frame_03() -> Image.Image:
    img = background("today")
    d = ImageDraw.Draw(img)
    status_bar(d)
    header_today(img, d, "进行中")
    status_card(img, 72, "能量回稳中", "你刚执行的建议让花苞打开一层", "half", rain=True)
    suggestion_card(img, "running", 72)
    draw_nav(img, "today")
    return img


def frame_04() -> Image.Image:
    img = background("evening")
    d = ImageDraw.Draw(img)
    status_bar(d, "21:12")
    draw_text(d, (82, 226), "今晚复盘", 47, bold=True)
    draw_text(d, (82, 282), "确认今天的建议是否真的帮到你", 30, fill=INK_2, bold=True)
    d.rounded_rectangle((958, 228, 1125, 304), 38, fill=(255, 255, 255, 165), outline=(255, 255, 255, 180), width=2)
    draw_text(d, (1042, 252), "关闭", 30, fill=INK_2, bold=True, anchor="ma")
    status_card(img, 88, "晚间能量更稳", "恢复种子接近盛开，等待你的反馈", "bloom", glow=True)
    d = ImageDraw.Draw(img)
    rounded_shadow(img, (58, 1810, 1148, 2440), 54, fill=(255, 255, 255, 232), outline=(255, 255, 255, 235), shadow=(80, 120, 160, 52), blur=30)
    draw_text(d, (104, 1872), "今天这颗恢复种子长成了什么样？", 43, bold=True)
    draw_wrapped(d, (104, 1938), "你下午留出恢复时间后，晚间能量更稳。Vitora 想确认：这条建议对你有帮助吗？", 960, 31, fill=INK_2, bold=True, line_gap=4)
    labels = [("有帮助", BLUE, True), ("一般", YELLOW, False), ("不适合", INK_3, False)]
    x = 104
    for label, color, sel in labels:
        d.rounded_rectangle((x, 2070, x + 292, 2170), 50, fill=(235, 247, 255, 255) if sel else (255, 255, 255, 165), outline=rgba(color, 165), width=3)
        draw_text(d, (x + 146, 2097), label, 33, fill=INK if sel else INK_2, bold=True, anchor="ma")
        x += 320
    d.rounded_rectangle((104, 2215, 1102, 2352), 34, fill=(247, 250, 255, 255), outline=(255, 255, 255, 255), width=2)
    draw_text(d, (144, 2250), "补充一句", 31, bold=True, fill=INK_2)
    draw_text(d, (144, 2297), "例如：午后安静恢复比轻走更适合我", 28, bold=True, fill=INK_3)
    return img


def flower_card(d: ImageDraw.ImageDraw, x: int, y: int, state: str, label: str, selected=False) -> None:
    d.rounded_rectangle((x, y, x + 132, y + 162), 30, fill=(255, 255, 255, 190), outline=rgba(BLUE if selected else WHITE, 170), width=2)
    if state == "bloom":
        flower_pixels(d, x + 66, y + 106, "bloom", 4)
    elif state == "half":
        flower_pixels(d, x + 66, y + 106, "half", 4)
    else:
        flower_pixels(d, x + 66, y + 112, "sleep", 4)
    draw_text(d, (x + 66, y + 126), label, 20, fill=INK_2, bold=True, anchor="ma")


def frame_05() -> Image.Image:
    img = background("cycle")
    d = ImageDraw.Draw(img)
    status_bar(d)
    d.rounded_rectangle((78, 234, 134, 290), 28, fill=(255, 255, 255, 170), outline=(255, 255, 255, 200), width=2)
    d.ellipse((96, 249, 116, 269), fill=INK_2)
    draw_text(d, (182, 225), "周期回顾", 48, bold=True)
    draw_text(d, (182, 283), "复盘成长 · 洞察规律", 30, fill=INK_2, bold=True)
    d.rounded_rectangle((1030, 236, 1088, 294), 29, fill=(255, 255, 255, 170), outline=(255, 255, 255, 200), width=2)
    d.line((1059, 254, 1059, 276), fill=INK_2, width=5)
    d.line((1048, 265, 1059, 254, 1070, 265), fill=INK_2, width=5)

    rounded_shadow(img, (56, 390, 1150, 825), 50, fill=(255, 255, 255, 224), outline=(255, 255, 255, 230), shadow=(100, 140, 180, 40), blur=30)
    draw_text(d, (104, 448), "这 30 天，Vitora 看见的三件事", 39, bold=True)
    d.rounded_rectangle((104, 520, 520, 592), 36, fill=(245, 250, 255, 255), outline=(255, 255, 255, 255), width=2)
    draw_text(d, (155, 540), "本周", 28, fill=INK, bold=True)
    draw_text(d, (292, 540), "趋势（月）", 28, fill=INK_2, bold=True)
    rows = [
        ("有效建议", "安静恢复 > 轻走"),
        ("低谷窗口", "14:00-16:00"),
        ("恢复较好时段", "上午"),
        ("仍需校准", "3 天待确认"),
    ]
    yy = 635
    for left, right in rows:
        draw_text(d, (108, yy), left, 29, fill=INK_2, bold=True)
        draw_text(d, (1010, yy), right, 29, fill=INK, bold=True, anchor="ra")
        yy += 44

    rounded_shadow(img, (56, 875, 1150, 1348), 50, fill=(255, 255, 255, 224), outline=(255, 255, 255, 230), shadow=(100, 140, 180, 40), blur=30)
    draw_text(d, (104, 940), "本周期花架证据", 39, bold=True)
    draw_text(d, (104, 990), "最近 7 次建议 → 反馈，帮助 Vitora 调整判断", 28, fill=INK_2, bold=True)
    states = [("bloom", "有帮助"), ("half", "一般"), ("bloom", "有帮助"), ("sleep", "不适合"), ("bloom", "有帮助"), ("half", "待确认")]
    x = 104
    y = 1064
    for i, (state, label) in enumerate(states):
        flower_card(d, x + i * 160, y, state, label, selected=(i == 0))
    d.rounded_rectangle((104, 1258, 1088, 1315), 28, fill=(245, 250, 255, 255), outline=(255, 255, 255, 255), width=2)
    draw_text(d, (136, 1273), "有效总结：下午安静恢复最稳定；留余量仍需再确认", 27, fill=INK_2, bold=True)

    rounded_shadow(img, (56, 1396, 1150, 1860), 50, fill=(255, 255, 255, 220), outline=(255, 255, 255, 230), shadow=(100, 140, 180, 40), blur=30)
    draw_text(d, (104, 1458), "能量趋势与低谷窗口", 38, bold=True)
    d.rounded_rectangle((875, 1440, 1078, 1510), 34, fill=(245, 250, 255, 255), outline=(255, 255, 255, 255), width=2)
    draw_text(d, (976, 1460), "周", 28, fill=BLUE, bold=True, anchor="ma")
    base_y = 1720
    points = [(150, 150), (290, 70), (440, 92), (590, 190), (735, 162), (900, 118), (1040, 88)]
    curve = [(x, base_y + y - 120) for x, y in points]
    d.line(curve, fill=CYAN, width=9, joint="curve")
    for x, yv in curve:
        d.ellipse((x - 12, yv - 12, x + 12, yv + 12), fill=WHITE, outline=CYAN, width=5)
    d.line((900, 1520, 900, 1765), fill=(109, 160, 210, 120), width=4)
    d.rounded_rectangle((766, 1514, 1036, 1582), 28, fill=(255, 255, 255, 230), outline=(255, 255, 255, 235), width=2)
    draw_text(d, (900, 1532), "今天 68%", 27, fill=INK, bold=True, anchor="ma")
    draw_text(d, (104, 1800), "Vitora 看到：低谷集中在下午，安静恢复反馈更好", 27, fill=INK_2, bold=True)

    rounded_shadow(img, (56, 1906, 1150, 2200), 50, fill=(255, 255, 255, 214), outline=(255, 255, 255, 230), shadow=(100, 140, 180, 34), blur=24)
    draw_text(d, (104, 1966), "下周期建议调整", 38, bold=True)
    draw_wrapped(d, (104, 2024), "低谷窗口前先留 20 分钟恢复，不把它当任务。若连续两次反馈“一般”，Vitora 会降低这类建议权重。", 960, 30, fill=INK_2, bold=True, line_gap=4)
    draw_nav(img, "cycle")
    return img


def make_contact_sheet(files: list[Path]) -> None:
    thumbs = []
    for file in files:
        im = Image.open(file).convert("RGBA")
        im.thumbnail((310, 674), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (330, 720), (255, 255, 255, 255))
        canvas.alpha_composite(im, ((330 - im.width) // 2, 10))
        td = ImageDraw.Draw(canvas)
        draw_text(td, (165, 690), file.stem.replace("-", " "), 17, fill=INK_2, bold=True, anchor="ma")
        thumbs.append(canvas)
    sheet = Image.new("RGBA", (1030, 1500), (248, 251, 255, 255))
    positions = [(0, 0), (350, 0), (700, 0), (170, 750), (520, 750)]
    for thumb, pos in zip(thumbs, positions):
        sheet.alpha_composite(thumb, pos)
    sheet.save(ROOT / "seed-flower-concept-contact-sheet.png")


def main() -> None:
    frames = [
        ("01-evening-seed-selection.png", frame_01()),
        ("02-morning-energy-bowl-bud.png", frame_02()),
        ("03-suggestion-rain-growth.png", frame_03()),
        ("04-evening-review-bloom-feedback.png", frame_04()),
        ("05-cycle-flower-shelf-evidence.png", frame_05()),
    ]
    out_files = []
    for name, image in frames:
        path = ROOT / name
        image.convert("RGB").save(path, quality=96)
        out_files.append(path)
    make_contact_sheet(out_files)


if __name__ == "__main__":
    main()
