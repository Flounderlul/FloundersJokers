#!/usr/bin/env python3
"""Build GitHub-safe, game-like README panels from the shipped runtime atlases."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "2x"
OUTPUT = ROOT / "docs" / "progression-runtime-qa.png"
SEAL_OUTPUT = ROOT / "docs" / "seal-animation-board.png"
BG = (10, 16, 20, 255)
PANEL = (19, 29, 34, 255)
GOLD = (205, 159, 66, 255)
GREEN = (47, 116, 88, 255)
INK = (238, 235, 214, 255)
MUTED = (163, 184, 173, 255)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    name = "consolab.ttf" if bold else "consola.ttf"
    return ImageFont.truetype(str(Path("C:/Windows/Fonts") / name), size)


def first_frame(name: str, frame_size: tuple[int, int]) -> Image.Image:
    sheet = Image.open(ASSETS / name).convert("RGBA")
    return sheet.crop((0, 0, frame_size[0], frame_size[1]))


def framed(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], title: str) -> None:
    draw.rounded_rectangle(box, radius=12, fill=PANEL, outline=GREEN, width=3)
    x1, y1, x2, _ = box
    draw.rectangle((x1 + 3, y1 + 3, x2 - 3, y1 + 48), fill=(24, 43, 43, 255))
    draw.text((x1 + 18, y1 + 10), title, font=font(22, True), fill=INK)


def card_row(
    canvas: Image.Image,
    draw: ImageDraw.ImageDraw,
    names: list[tuple[str, str]],
    origin: tuple[int, int],
    frame_size: tuple[int, int],
    scale: int,
    gap: int,
) -> None:
    x, y = origin
    for filename, label in names:
        art = first_frame(filename, frame_size).resize(
            (frame_size[0] * scale, frame_size[1] * scale), Image.Resampling.NEAREST
        )
        canvas.alpha_composite(art, (x, y))
        width = frame_size[0] * scale
        label_box = draw.textbbox((0, 0), label, font=font(15, True))
        label_width = label_box[2] - label_box[0]
        draw.text((x + (width - label_width) // 2, y + frame_size[1] * scale + 8), label, font=font(15, True), fill=MUTED)
        x += width + gap


def main() -> None:
    canvas = Image.new("RGBA", (1500, 930), BG)
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((5, 5, 1494, 924), radius=18, outline=GOLD, width=8)
    draw.rounded_rectangle((18, 18, 1481, 911), radius=13, outline=GREEN, width=3)
    draw.text((55, 42), "CURIO CIRCUIT / PROGRESSION COLLECTION", font=font(34, True), fill=INK)
    draw.text((58, 88), "SHIPPED 2X ATLASES • FRAME 1 OF 6 • TRANSPARENT NATIVE-SCALE SILHOUETTES", font=font(17), fill=MUTED)

    framed(draw, (45, 140, 1455, 450), "DECK BACKS")
    card_row(
        canvas,
        draw,
        [("b_loaded.png", "LOADED"), ("b_workshop.png", "WORKSHOP"), ("b_curator.png", "CURATOR")],
        (320, 195),
        (142, 190),
        1,
        120,
    )

    framed(draw, (45, 475, 990, 875), "VOUCHER CHAINS")
    card_row(
        canvas,
        draw,
        [
            ("v_wax_stamp.png", "WAX STAMP"),
            ("v_sealing_press.png", "SEALING PRESS"),
            ("v_display_case.png", "DISPLAY CASE"),
            ("v_private_collection.png", "PRIVATE COLLECTION"),
        ],
        (105, 540),
        (142, 190),
        1,
        60,
    )

    framed(draw, (1015, 475, 1455, 875), "BOSS BLINDS")
    card_row(
        canvas,
        draw,
        [
            ("bl_quarry.png", "QUARRY"),
            ("bl_lock.png", "LOCK"),
            ("bl_house.png", "HOUSE"),
            ("bl_mirror.png", "MIRROR"),
        ],
        (1050, 575),
        (68, 68),
        1,
        34,
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(OUTPUT, optimize=True)
    seals = Image.new("RGBA", (1500, 600), BG)
    seal_draw = ImageDraw.Draw(seals)
    seal_draw.rounded_rectangle((5, 5, 1494, 594), radius=18, outline=GOLD, width=8)
    seal_draw.rounded_rectangle((18, 18, 1481, 581), radius=13, outline=GREEN, width=3)
    seal_draw.text((55, 42), "DICE SEAL / TWELVE-FRAME TOKEN STUDY", font=font(34, True), fill=INK)
    seal_draw.text((58, 88), "SQUASH • SETTLE • TRAVELLING GLINT • REDUCED-MOTION SAFE", font=font(17), fill=MUTED)
    for row, (filename, label) in enumerate(
        (("dice_seal_animated.png", "DICE SEAL"), ("cursed_dice_seal_animated.png", "CURSED DICE SEAL"))
    ):
        y = 165 + row * 205
        seal_draw.rounded_rectangle((50, y - 25, 1450, y + 160), radius=10, fill=PANEL, outline=GREEN, width=2)
        seal_draw.text((72, y + 48), label, font=font(18, True), fill=INK)
        sheet = Image.open(ROOT / "assets" / "1x" / filename).convert("RGBA")
        start_x = 300
        for index in range(12):
            frame = sheet.crop((index * 71, 0, (index + 1) * 71, 95))
            bounds = frame.getchannel("A").getbbox()
            token = frame.crop(bounds) if bounds else frame
            token.thumbnail((62, 62), Image.Resampling.NEAREST)
            token_x = start_x + index * 88 + (71 - token.width) // 2
            token_y = y + 22 + (62 - token.height) // 2
            seals.alpha_composite(token, (token_x, token_y))
            seal_draw.text((start_x + index * 88 + 27, y + 118), f"{index + 1:02d}", font=font(12), fill=MUTED)
    seals.convert("RGB").save(SEAL_OUTPUT, optimize=True)
    print(f"Wrote {OUTPUT} and {SEAL_OUTPUT}")


if __name__ == "__main__":
    main()
