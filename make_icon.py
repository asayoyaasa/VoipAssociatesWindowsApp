"""
Generate VoIP Associates icon.ico from the waveform SVG design.
Produces sizes: 16, 32, 48, 64, 128, 256 px — all embedded in one ICO file.
Uses Pillow + numpy for RGBA gradient bars, no external SVG renderer needed.
"""
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# Brand colours
BLUE_BOT = (14, 165, 233)   # #0ea5e9 — bottom of gradient
BLUE_TOP = (34, 211, 238)   # #22d3ee — top of gradient / dot colour


def lerp_colour(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def draw_rounded_rect_gradient(img_arr, x, y, w, h, rx, alpha, canvas_h):
    """
    Draw a vertical-gradient rounded rectangle into img_arr (H×W×4 RGBA numpy array).
    Gradient: BLUE_BOT at bottom, BLUE_TOP at top.
    alpha: bar opacity 0..255.
    """
    for py in range(y, y + h):
        t = 1.0 - (py - y) / max(h - 1, 1)   # 0 at bottom, 1 at top
        colour = lerp_colour(BLUE_BOT, BLUE_TOP, t)
        for px in range(x, x + w):
            # Rounded corner check
            # Distance from nearest corner centre
            cx_l = x + rx
            cx_r = x + w - rx
            cy_t = y + rx
            cy_b = y + h - rx
            in_corner = False
            dist = 0.0
            if px < cx_l and py < cy_t:
                dist = math.hypot(px - cx_l, py - cy_t)
                in_corner = True
            elif px >= cx_r and py < cy_t:
                dist = math.hypot(px - cx_r, py - cy_t)
                in_corner = True
            elif px < cx_l and py >= cy_b:
                dist = math.hypot(px - cx_l, py - cy_b)
                in_corner = True
            elif px >= cx_r and py >= cy_b:
                dist = math.hypot(px - cx_r, py - cy_b)
                in_corner = True
            if in_corner and dist > rx:
                continue
            # Anti-alias at rounded edge
            a = alpha
            if in_corner and dist > rx - 1:
                a = int(alpha * (rx - dist))
            a = max(0, min(255, a))
            # Alpha-composite over existing pixel
            src_a = a / 255.0
            dst_a = img_arr[py, px, 3] / 255.0
            out_a = src_a + dst_a * (1 - src_a)
            if out_a > 0:
                for c in range(3):
                    img_arr[py, px, c] = int(
                        (colour[c] * src_a + img_arr[py, px, c] * dst_a * (1 - src_a)) / out_a
                    )
            img_arr[py, px, 3] = int(out_a * 255)


def draw_circle(img_arr, cx, cy, r, colour, alpha):
    """Draw a soft anti-aliased circle into img_arr."""
    for py in range(max(0, cy - r - 2), min(img_arr.shape[0], cy + r + 2)):
        for px in range(max(0, cx - r - 2), min(img_arr.shape[1], cx + r + 2)):
            dist = math.hypot(px - cx, py - cy)
            if dist > r + 1:
                continue
            a = int(alpha * max(0.0, min(1.0, r - dist + 0.5)))
            src_a = a / 255.0
            dst_a = img_arr[py, px, 3] / 255.0
            out_a = src_a + dst_a * (1 - src_a)
            if out_a > 0:
                for c in range(3):
                    img_arr[py, px, c] = int(
                        (colour[c] * src_a + img_arr[py, px, c] * dst_a * (1 - src_a)) / out_a
                    )
            img_arr[py, px, 3] = int(out_a * 255)


def render_icon(size):
    """
    Render the waveform icon at `size` × `size` pixels.

    Layout (matches logo.svg):
      Bar width=W, gap=G. 5*W+4*G = total_bar_width.
      Centre bars horizontally. Bottom margin ~15% of size.
      Heights: outer=29%, mid=63%, centre=100% of max_bar_h.
    """
    s = size
    img = np.zeros((s, s, 4), dtype=np.uint8)

    # Layout constants (proportional to size)
    margin_bottom = max(1, round(s * 0.15))
    bottom_y = s - margin_bottom              # bottom edge of all bars

    # Bar width and gap chosen to use ~82% of canvas width (matches SVG)
    bw = max(1, round(s * 0.125))            # bar width  (64/512 ≈ 12.5%)
    gap = max(1, round(s * 0.047))           # gap        (24/512 ≈ 4.7%)
    total_w = 5 * bw + 4 * gap
    left = (s - total_w) // 2               # left margin

    xs = [left + i * (bw + gap) for i in range(5)]

    max_h = max(1, round(s * 0.685))         # 350/512 ≈ 68.5%
    heights = [
        max(1, round(max_h * 0.286)),        # outer  100/350
        max(1, round(max_h * 0.629)),        # mid    220/350
        max_h,                               # centre
        max(1, round(max_h * 0.629)),
        max(1, round(max_h * 0.286)),
    ]
    alphas = [97, 158, 255, 158, 97]        # 38%, 62%, 100%

    rx = max(1, bw // 2)

    for i, (bx, bh, ba) in enumerate(zip(xs, heights, alphas)):
        by = bottom_y - bh
        draw_rounded_rect_gradient(img, bx, by, bw, bh, rx, ba, s)

    # Live indicator dot — above rightmost bar, centred on it
    dot_cx = xs[4] + bw // 2
    dot_cy = max(1, round(s * 0.12))
    dot_r  = max(1, round(s * 0.055))       # 28/512 ≈ 5.5%

    # Soft glow
    glow_r = dot_r * 2
    draw_circle(img, dot_cx, dot_cy, glow_r, BLUE_TOP, 45)
    # Solid dot
    draw_circle(img, dot_cx, dot_cy, dot_r, BLUE_TOP, 255)

    return Image.fromarray(img, 'RGBA')


if __name__ == '__main__':
    sizes = [16, 32, 48, 64, 128, 256]
    frames = [render_icon(s) for s in sizes]

    out = r'C:\voipapp\linphone-desktop\Linphone\data\icon.ico'
    # Pillow ICO: pass the largest frame and list all desired sizes — it
    # downscales internally for each entry.
    frames[-1].save(
        out,
        format='ICO',
        sizes=[(s, s) for s in sizes],
    )
    import os
    print(f'Saved {out}  ({os.path.getsize(out):,} bytes)')
    for s in sizes:
        print(f'  {s}×{s}')
