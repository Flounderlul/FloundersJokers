#!/usr/bin/env python3
"""Rebuild Flounder's Joker textures as restrained native-scale pixel art.

The 2x files are treated as composition masters.  Similar neighbouring colours
are consolidated without crossing strong edges, the result is reduced to a
controlled per-card palette, and the 2x companion is reconstructed with exact
nearest-neighbour pixels.  Subjects, framing, crop, and transparency remain in
the same positions.
"""

from __future__ import annotations

import argparse
import json
import shutil
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ONE_X = ROOT / "assets" / "1x"
TWO_X = ROOT / "assets" / "2x"
NATIVE_SIZE = (71, 95)
DOUBLE_SIZE = (142, 190)


@dataclass
class Metrics:
    card: str
    colours_before: int
    colours_after: int
    noise_before: float
    noise_after: float
    strong_edges_before: int
    strong_edges_after: int


def rgba(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    if image.size not in (NATIVE_SIZE, DOUBLE_SIZE):
        raise ValueError(f"{path} has invalid dimensions {image.size}")
    return image


def edge_aware_smooth(rgb: np.ndarray, threshold: float = 52.0) -> np.ndarray:
    """A compact bilateral pass that removes texture chatter but keeps forms."""
    source = rgb.astype(np.float32)
    padded = np.pad(source, ((1, 1), (1, 1), (0, 0)), mode="reflect")
    total = source * 2.4
    weights = np.full(source.shape[:2] + (1,), 2.4, dtype=np.float32)
    for dy in range(3):
        for dx in range(3):
            if dx == 1 and dy == 1:
                continue
            neighbour = padded[dy : dy + source.shape[0], dx : dx + source.shape[1]]
            distance = np.sqrt(np.sum((neighbour - source) ** 2, axis=2, keepdims=True))
            accepted = distance < threshold
            weight = np.where(accepted, np.exp(-(distance / threshold) ** 2), 0.0)
            total += neighbour * weight
            weights += weight
    return np.clip(total / np.maximum(weights, 0.001), 0, 255).astype(np.uint8)


def noise_score(image: Image.Image) -> float:
    """Percentage of low-contrast neighbour changes that read as texture chatter."""
    arr = np.asarray(image.convert("RGB"), dtype=np.float32)
    horizontal = np.sqrt(np.sum(np.diff(arr, axis=1) ** 2, axis=2))
    vertical = np.sqrt(np.sum(np.diff(arr, axis=0) ** 2, axis=2))
    transitions = np.concatenate((horizontal.ravel(), vertical.ravel()))
    chatter = np.count_nonzero((transitions >= 4) & (transitions <= 34))
    return float(chatter / max(1, transitions.size) * 100)


def strong_edges(image: Image.Image) -> int:
    arr = np.asarray(image.convert("RGB"), dtype=np.float32)
    luma = arr[..., 0] * 0.2126 + arr[..., 1] * 0.7152 + arr[..., 2] * 0.0722
    dx = np.abs(np.diff(luma, axis=1))[:, :-1]
    dy = np.abs(np.diff(luma, axis=0))[:-1, :]
    height = min(dx.shape[0], dy.shape[0])
    width = min(dx.shape[1], dy.shape[1])
    return int(np.count_nonzero(np.maximum(dx[:height, :width], dy[:height, :width]) >= 38))


def colour_count(image: Image.Image) -> int:
    return len(image.convert("RGB").getcolors(maxcolors=NATIVE_SIZE[0] * NATIVE_SIZE[1]) or [])


def refine(master: Image.Image, colours: int) -> Image.Image:
    alpha = master.getchannel("A").resize(NATIVE_SIZE, Image.Resampling.BOX)
    native = master.convert("RGB").resize(NATIVE_SIZE, Image.Resampling.BOX)
    smoothed = Image.fromarray(edge_aware_smooth(np.asarray(native)), "RGB")
    shaped = smoothed.filter(ImageFilter.UnsharpMask(radius=0.65, percent=72, threshold=6))
    palette = shaped.quantize(
        colors=colours,
        # MAXCOVERAGE retains small semantic accents (gems, flames, blue steel)
        # that median-cut palettes tend to absorb into a dominant card tint.
        method=Image.Quantize.MAXCOVERAGE,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    output = palette.convert("RGBA")
    output.putalpha(alpha)
    return output


def backup(files: list[Path]) -> Path:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    destination = ROOT / "dist" / f"art-backup-{stamp}"
    for path in files:
        relative = path.relative_to(ROOT)
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    return destination


def write_report(metrics: list[Metrics], path: Path, palette: int) -> None:
    before_noise = sum(item.noise_before for item in metrics) / len(metrics)
    after_noise = sum(item.noise_after for item in metrics) / len(metrics)
    before_colours = sum(item.colours_before for item in metrics) / len(metrics)
    after_colours = sum(item.colours_after for item in metrics) / len(metrics)
    edge_ratio = sum(item.strong_edges_after for item in metrics) / max(
        1, sum(item.strong_edges_before for item in metrics)
    )
    payload = {
        "cards": len(metrics),
        "palette_ceiling": palette,
        "average_colours_before": round(before_colours, 2),
        "average_colours_after": round(after_colours, 2),
        "average_noise_before": round(before_noise, 3),
        "average_noise_after": round(after_noise, 3),
        "noise_reduction_percent": round((1 - after_noise / before_noise) * 100, 2),
        "strong_edge_retention": round(edge_ratio, 3),
        "results": [asdict(item) for item in metrics],
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--palette", type=int, default=24)
    parser.add_argument("--preview-dir", type=Path)
    parser.add_argument("--no-backup", action="store_true")
    args = parser.parse_args()
    if not 16 <= args.palette <= 64:
        raise SystemExit("--palette must be between 16 and 64")

    masters = sorted(TWO_X.glob("j_*.png"))
    if len(masters) != 60:
        raise SystemExit(f"Expected 60 2x Joker masters, found {len(masters)}")
    pairs = [path for master in masters for path in (ONE_X / master.name, master)]
    if not args.preview_dir and not args.no_backup:
        print(f"Backup: {backup(pairs)}")

    report = (args.preview_dir or ROOT / "docs") / "joker-finishing.metrics"
    baseline: dict[str, dict[str, object]] = {}
    existing_report = ROOT / "docs" / "joker-finishing.metrics"
    if not args.preview_dir and existing_report.exists():
        previous = json.loads(existing_report.read_text(encoding="utf-8"))
        baseline = {item["card"]: item for item in previous.get("results", [])}

    metrics: list[Metrics] = []
    for master_path in masters:
        current = rgba(ONE_X / master_path.name)
        native = refine(rgba(master_path), args.palette)
        doubled = native.resize(DOUBLE_SIZE, Image.Resampling.NEAREST)
        prior = baseline.get(master_path.name, {})
        metrics.append(
            Metrics(
                card=master_path.name,
                colours_before=int(prior.get("colours_before", colour_count(current))),
                colours_after=colour_count(native),
                noise_before=float(prior.get("noise_before", round(noise_score(current), 4))),
                noise_after=round(noise_score(native), 4),
                strong_edges_before=int(prior.get("strong_edges_before", strong_edges(current))),
                strong_edges_after=strong_edges(native),
            )
        )
        if args.preview_dir:
            one_target = args.preview_dir / "1x" / master_path.name
            two_target = args.preview_dir / "2x" / master_path.name
        else:
            one_target = ONE_X / master_path.name
            two_target = TWO_X / master_path.name
        one_target.parent.mkdir(parents=True, exist_ok=True)
        two_target.parent.mkdir(parents=True, exist_ok=True)
        native.save(one_target, optimize=True)
        doubled.save(two_target, optimize=True)

    write_report(metrics, report, args.palette)
    print(f"Refined {len(metrics)} Joker pairs; metrics: {report}")


if __name__ == "__main__":
    main()
