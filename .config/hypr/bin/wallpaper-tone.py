#!/usr/bin/env python3
# Helpers for wallpaper.sh gruvify.
#   flatbg <image>       prints the background colour if the image's edges are one flat colour
#   bgmask <image> <out> writes a mask of that background (white), skipping small patches of
#                        the same colour inside the subject
#   orange <in> <out>    pulls the dominant non-warm hue family to Gruvbox orange
import subprocess
import sys

import numpy as np
from PIL import Image

ORANGE_HUE = 27


def flatbg(path):
    bg, flat = edges_bg(np.asarray(Image.open(path).convert("RGB")).astype(int))
    if flat:
        print("srgb({},{},{})".format(*bg.astype(int)))


def edges_bg(a):
    edges = np.concatenate([a[:4].reshape(-1, 3), a[-4:].reshape(-1, 3),
                            a[:, :4].reshape(-1, 3), a[:, -4:].reshape(-1, 3)])
    bg = np.median(edges, 0)
    return bg, (np.abs(edges - bg).max(1) < 12).mean() > 0.9


def bgmask(path, dst):
    a = np.asarray(Image.open(path).convert("RGB")).astype(int)
    h, w = a.shape[:2]
    bg, _ = edges_bg(a)
    near = (np.abs(a - bg).max(2) <= 15).astype(np.uint8) * 255
    labels = subprocess.run(
        ["magick", "-size", f"{w}x{h}", "-depth", "8", "gray:-",
         "-connected-components", "4", "-depth", "16", "gray:-"],
        input=near.tobytes(), capture_output=True, check=True).stdout
    labels = np.frombuffer(labels, "<u2").reshape(h, w)
    area = np.bincount(labels.ravel())
    big = area >= w * h // 1000
    keep = big[labels] & (near > 0)
    Image.fromarray(keep.astype(np.uint8) * 255).save(dst)


def to_hsv(a):
    mx, mn = a.max(2), a.min(2)
    c = mx - mn
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    h = np.zeros_like(mx)
    m = c > 1e-6
    rr = (mx == r) & m
    gg = (mx == g) & m & ~rr
    bb = m & ~rr & ~gg
    h[rr] = ((g - b)[rr] / c[rr]) % 6
    h[gg] = (b - r)[gg] / c[gg] + 2
    h[bb] = (r - g)[bb] / c[bb] + 4
    return h * 60, np.where(mx > 0, c / np.maximum(mx, 1e-6), 0), mx


def from_hsv(h, s, v):
    i = (h // 60).astype(int) % 6
    f = h / 60 - np.floor(h / 60)
    p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    k = [i == n for n in range(6)]
    return np.stack([np.select(k, [v, q, p, p, t, v]),
                     np.select(k, [t, v, v, q, p, p]),
                     np.select(k, [p, p, t, v, v, q])], -1)


def orange(src, dst):
    img = Image.open(src).convert("RGB")
    h, s, v = to_hsv(np.asarray(img) / 255.0)
    # warm hues (reds, oranges, skin) are already on-theme
    cool = (s > 0.12) & (h > 55) & (h < 340)
    if cool.mean() < 0.005:
        img.save(dst)
        return
    centre = np.degrees(np.angle(np.exp(1j * np.radians(h[cool])).mean())) % 360
    d = np.abs((h - centre + 180) % 360 - 180)
    w = np.clip((75 - d) / 20, 0, 1) * np.clip((s - 0.05) / 0.1, 0, 1)
    h = (h + w * ((ORANGE_HUE - h + 180) % 360 - 180)) % 360
    # dark orange reads as brown, so lift what moved a little
    s = np.clip(s * (1 + 0.2 * w), 0, 1)
    v = np.clip(v * (1 + 0.25 * w), 0, 1)
    Image.fromarray((from_hsv(h, s, v) * 255 + 0.5).astype(np.uint8)).save(dst)


if __name__ == "__main__":
    {"flatbg": flatbg, "bgmask": bgmask, "orange": orange}[sys.argv[1]](*sys.argv[2:])
