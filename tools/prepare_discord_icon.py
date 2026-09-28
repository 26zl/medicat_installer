#!/usr/bin/env python3
"""Build res/discord.ico from res/discord.png (replace the PNG to update the icon).

Pillow is optional: without it the committed res/discord.ico is kept and its timestamp refreshed, so a
fresh clone builds without extra Python packages. Only a missing icon turns a missing Pillow into an error.
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
PNG_PATH = REPO / "res" / "discord.png"
ICO_PATH = REPO / "res" / "discord.ico"
ICO_SIZES = (16, 24, 32, 48)


def main() -> int:
    if not PNG_PATH.is_file():
        print(f"Missing source icon: {PNG_PATH}", file=sys.stderr)
        print("Add res/discord.png (square PNG with transparency), then rebuild.", file=sys.stderr)
        return 1

    try:
        from PIL import Image
    except ImportError:
        if ICO_PATH.is_file():
            ICO_PATH.touch()
            print("Pillow is not installed; keeping the committed res/discord.ico (pip install pillow to regenerate it)")
            return 0
        print("Pillow is required to build res/discord.ico: pip install pillow", file=sys.stderr)
        return 1

    source = Image.open(PNG_PATH).convert("RGBA")
    icons = []
    for size in ICO_SIZES:
        resized = source.resize((size, size), Image.Resampling.LANCZOS)
        icons.append(resized if resized.mode == "RGBA" else resized.convert("RGBA"))
    icons[0].save(
        ICO_PATH,
        format="ICO",
        sizes=[(img.width, img.height) for img in icons],
        append_images=icons[1:],
    )
    print(f"Wrote {ICO_PATH.relative_to(REPO)} from {PNG_PATH.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
