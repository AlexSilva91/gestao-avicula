#!/usr/bin/env python3
"""Generate Android launcher icons from the official SELETO logo."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "SELETO_LOGO.png"
TARGETS = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"Logo not found: {SOURCE}")

    source = Image.open(SOURCE).convert("RGBA")
    side = max(source.size)
    canvas = Image.new("RGBA", (side, side), (255, 255, 255, 0))
    canvas.alpha_composite(
        source,
        ((side - source.width) // 2, (side - source.height) // 2),
    )

    for folder, size in TARGETS.items():
        target_dir = ROOT / "android" / "app" / "src" / "main" / "res" / folder
        target_dir.mkdir(parents=True, exist_ok=True)
        target = target_dir / "ic_launcher.png"
        canvas.resize((size, size), Image.Resampling.LANCZOS).save(target)
        print(f"generated {target.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
