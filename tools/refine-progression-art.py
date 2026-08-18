#!/usr/bin/env python3
"""Normalize progression sheets to Balatro-scale, transparent, aligned frames."""

from __future__ import annotations

import json
import shutil
from collections import deque
from datetime import datetime
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
FILES = {
    "b_loaded.png": (71, 95),
    "b_workshop.png": (71, 95),
    "b_curator.png": (71, 95),
    "v_wax_stamp.png": (71, 95),
    "v_sealing_press.png": (71, 95),
    "v_display_case.png": (71, 95),
    "v_private_collection.png": (71, 95),
    "bl_quarry.png": (34, 34),
    "bl_lock.png": (34, 34),
    "bl_house.png": (34, 34),
    "bl_mirror.png": (34, 34),
}
FRAMES = 6


def largest_component(mask: np.ndarray) -> tuple[int, int, int, int]:
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    best: list[tuple[int, int]] = []
    for y, x in zip(*np.nonzero(mask)):
        if visited[y, x]:
            continue
        queue = deque([(int(y), int(x))])
        visited[y, x] = True
        component: list[tuple[int, int]] = []
        while queue:
            cy, cx = queue.popleft()
            component.append((cy, cx))
            for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
                if 0 <= ny < height and 0 <= nx < width and mask[ny, nx] and not visited[ny, nx]:
                    visited[ny, nx] = True
                    queue.append((ny, nx))
        if len(component) > len(best):
            best = component
    if not best:
        raise ValueError("No foreground component found")
    ys = [point[0] for point in best]
    xs = [point[1] for point in best]
    return min(xs), min(ys), max(xs) + 1, max(ys) + 1


def foreground(frame: Image.Image, threshold: float = 18.0) -> np.ndarray:
    pixels = np.asarray(frame.convert("RGB"), dtype=np.float32)
    corners = np.array(
        [pixels[0, 0], pixels[0, -1], pixels[-1, 0], pixels[-1, -1]], dtype=np.float32
    )
    background = np.median(corners, axis=0)
    return np.sqrt(np.sum((pixels - background) ** 2, axis=2)) > threshold


def remove_background(image: Image.Image, threshold: float = 13.0) -> Image.Image:
    pixels = np.asarray(image.convert("RGBA")).copy()
    rgb = pixels[..., :3].astype(np.float32)
    corners = np.array([rgb[0, 0], rgb[0, -1], rgb[-1, 0], rgb[-1, -1]])
    background = np.median(corners, axis=0)
    distance = np.sqrt(np.sum((rgb - background) ** 2, axis=2))
    pixels[..., 3] = np.where(distance > threshold, pixels[..., 3], 0)
    return Image.fromarray(pixels, "RGBA")


def palette_finish(image: Image.Image, colours: int = 48) -> Image.Image:
    alpha = image.getchannel("A")
    flattened = Image.new("RGB", image.size, (8, 8, 10))
    flattened.paste(image.convert("RGB"), mask=alpha)
    reduced = flattened.quantize(
        colors=colours, method=Image.Quantize.MAXCOVERAGE, dither=Image.Dither.NONE
    ).convert("RGBA")
    reduced.putalpha(alpha)
    return reduced


def rebuild(name: str, native_size: tuple[int, int]) -> dict[str, object]:
    master_path = ROOT / "assets" / "2x" / name
    master = Image.open(master_path).convert("RGBA")
    double_frame = (native_size[0] * 2, native_size[1] * 2)
    if master.size != (double_frame[0] * FRAMES, double_frame[1]):
        raise ValueError(f"{name}: unexpected sheet size {master.size}")
    frames = [
        master.crop((index * double_frame[0], 0, (index + 1) * double_frame[0], double_frame[1]))
        for index in range(FRAMES)
    ]
    boxes = [largest_component(foreground(frame)) for frame in frames]
    crop = (
        max(0, min(box[0] for box in boxes) - 3),
        max(0, min(box[1] for box in boxes) - 3),
        min(double_frame[0], max(box[2] for box in boxes) + 3),
        min(double_frame[1], max(box[3] for box in boxes) + 3),
    )
    margin = 3 if native_size[0] == 71 else 2
    inner = (native_size[0] - margin * 2, native_size[1] - margin * 2)
    native_frames: list[Image.Image] = []
    occupancies: list[float] = []
    for frame in frames:
        subject = remove_background(frame.crop(crop))
        subject.thumbnail(inner, Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", native_size, (0, 0, 0, 0))
        x = (native_size[0] - subject.width) // 2
        y = (native_size[1] - subject.height) // 2
        canvas.alpha_composite(subject, (x, y))
        canvas = palette_finish(canvas)
        native_frames.append(canvas)
        occupancies.append(float(np.count_nonzero(np.asarray(canvas)[..., 3] > 8) / (native_size[0] * native_size[1])))
    native_sheet = Image.new("RGBA", (native_size[0] * FRAMES, native_size[1]), (0, 0, 0, 0))
    for index, frame in enumerate(native_frames):
        native_sheet.alpha_composite(frame, (index * native_size[0], 0))
    double_sheet = native_sheet.resize(
        (native_size[0] * 2 * FRAMES, native_size[1] * 2), Image.Resampling.NEAREST
    )
    native_sheet.save(ROOT / "assets" / "1x" / name, optimize=True)
    double_sheet.save(ROOT / "assets" / "2x" / name, optimize=True)
    return {
        "asset": name,
        "source_crop_2x": crop,
        "occupancy_min": round(min(occupancies), 4),
        "occupancy_max": round(max(occupancies), 4),
    }


def main() -> None:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = ROOT / "dist" / f"progression-art-backup-{stamp}"
    for scale in ("1x", "2x"):
        for name in FILES:
            source = ROOT / "assets" / scale / name
            target = backup / scale / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    results = [rebuild(name, size) for name, size in FILES.items()]
    report = ROOT / "docs" / "progression-art.metrics"
    report.write_text(json.dumps({"frames_per_asset": FRAMES, "results": results}, indent=2) + "\n")
    print(f"Rebuilt {len(results)} progression sheets; backup: {backup}; report: {report}")


if __name__ == "__main__":
    main()
