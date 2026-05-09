#!/usr/bin/env python3
"""Create a real transparent PNG from logos with baked light/checker backgrounds."""

from __future__ import annotations

import argparse
import collections
import datetime as dt
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def tool(name: str) -> str:
    found = shutil.which(name)
    if not found:
        raise SystemExit(f"missing required tool: {name}")
    return found


def image_tools() -> tuple[str, str]:
    identify = tool("identify")
    convert = shutil.which("magick") or tool("convert")
    return identify, convert


def run(args: list[str], *, input_bytes: bytes | None = None) -> bytes:
    proc = subprocess.run(args, input=input_bytes, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if proc.returncode != 0:
        cmd = " ".join(args)
        err = proc.stderr.decode("utf-8", "replace").strip()
        raise SystemExit(f"command failed: {cmd}\n{err}")
    return proc.stdout


def identify_info(path: Path, identify: str) -> tuple[int, int, str]:
    out = run([identify, "-format", "%w %h %[channels]", str(path)]).decode().strip()
    parts = out.split()
    if len(parts) < 3:
        raise SystemExit(f"could not read image info for {path}: {out}")
    return int(parts[0]), int(parts[1]), parts[2]


def corner_is_transparent(path: Path, convert: str) -> bool:
    pixel = run([convert, str(path), "-format", "%[pixel:p{0,0}]", "info:"]).decode().strip()
    if "srgba" not in pixel and "rgba" not in pixel:
        return False
    tail = pixel.rsplit(",", 1)[-1].rstrip(")")
    try:
        return float(tail) == 0.0
    except ValueError:
        return tail in {"0", "0.0"}


def rgb_bytes(path: Path, convert: str) -> bytes:
    return run([convert, str(path), "-alpha", "remove", "-depth", "8", "rgb:-"])


def make_background_mask(
    rgb: bytes,
    width: int,
    height: int,
    *,
    min_light: int,
    neutral_tolerance: int,
) -> bytearray:
    total = width * height
    seen = bytearray(total)
    queue: collections.deque[int] = collections.deque()

    def is_candidate(index: int) -> bool:
        base = index * 3
        r, g, b = rgb[base], rgb[base + 1], rgb[base + 2]
        return max(r, g, b) - min(r, g, b) <= neutral_tolerance and (r + g + b) / 3 >= min_light

    def add(index: int) -> None:
        if not seen[index] and is_candidate(index):
            seen[index] = 1
            queue.append(index)

    for x in range(width):
        add(x)
        add((height - 1) * width + x)
    for y in range(height):
        add(y * width)
        add(y * width + width - 1)

    while queue:
        index = queue.popleft()
        x = index % width
        y = index // width
        for dy in (-1, 0, 1):
            ny = y + dy
            if not 0 <= ny < height:
                continue
            for dx in (-1, 0, 1):
                if dx == 0 and dy == 0:
                    continue
                nx = x + dx
                if 0 <= nx < width:
                    add(ny * width + nx)

    return seen


def write_rgba_png(rgb: bytes, mask: bytearray, width: int, height: int, output: Path, convert: str) -> None:
    rgba = bytearray(width * height * 4)
    for index in range(width * height):
        rgba[index * 4 : index * 4 + 3] = rgb[index * 3 : index * 3 + 3]
        rgba[index * 4 + 3] = 0 if mask[index] else 255
    run(
        [
            convert,
            "-size",
            f"{width}x{height}",
            "-depth",
            "8",
            "rgba:-",
            f"png32:{output}",
        ],
        input_bytes=bytes(rgba),
    )


def apply_open_mask(source: Path, radius: int, output: Path, convert: str, tmpdir: Path) -> None:
    if radius <= 0:
        if source != output:
            shutil.copy2(source, output)
        return
    alpha = tmpdir / "alpha.png"
    opened = tmpdir / "alpha-open.png"
    run([convert, str(source), "-alpha", "extract", str(alpha)])
    run([convert, str(alpha), "-morphology", "Open", f"Disk:{radius}", str(opened)])
    run(
        [
            convert,
            str(source),
            str(opened),
            "-alpha",
            "off",
            "-compose",
            "CopyOpacity",
            "-composite",
            f"png32:{output}",
        ]
    )


def backup_input(path: Path) -> Path:
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_dir = Path(tempfile.gettempdir()) / "png-alpha-cleaner-backups" / stamp
    backup_dir.mkdir(parents=True, exist_ok=True)
    backup = backup_dir / path.name
    shutil.copy2(path, backup)
    return backup


def preview(output: Path, colors: list[str], convert: str) -> list[Path]:
    previews: list[Path] = []
    for raw_color in colors:
        safe = raw_color.replace("#", "").replace("/", "-")
        path = output.with_name(f"{output.stem}.preview-{safe}.png")
        run([convert, str(output), "-background", raw_color, "-alpha", "remove", str(path)])
        previews.append(path)
    return previews


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    parser.add_argument("--in-place", action="store_true")
    parser.add_argument("--min-light", type=int, default=220)
    parser.add_argument("--neutral-tolerance", type=int, default=12)
    parser.add_argument("--open-radius", type=int, default=4)
    parser.add_argument("--preview-color", action="append", default=[])
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    if not args.input.exists():
        raise SystemExit(f"input not found: {args.input}")
    if args.output and args.in_place:
        raise SystemExit("use either --output or --in-place, not both")
    if not args.output and not args.in_place:
        args.output = args.input.with_name(f"{args.input.stem}.alpha.png")
    output = args.input if args.in_place else args.output
    assert output is not None
    output.parent.mkdir(parents=True, exist_ok=True)

    identify, convert = image_tools()
    width, height, channels = identify_info(args.input, identify)
    backup = backup_input(args.input) if args.in_place else None

    with tempfile.TemporaryDirectory(prefix="png-alpha-cleaner-") as tmp:
        tmpdir = Path(tmp)
        if "a" in channels.lower() and corner_is_transparent(args.input, convert):
            run([convert, str(args.input), f"png32:{output}"])
            transparent_count = "already-alpha"
        else:
            rgb = rgb_bytes(args.input, convert)
            if len(rgb) != width * height * 3:
                raise SystemExit("unexpected RGB byte count from ImageMagick")
            mask = make_background_mask(
                rgb,
                width,
                height,
                min_light=args.min_light,
                neutral_tolerance=args.neutral_tolerance,
            )
            transparent = sum(1 for value in mask if value)
            if transparent == 0:
                raise SystemExit("no edge-connected light/neutral background detected")
            raw = tmpdir / "raw-alpha.png"
            write_rgba_png(rgb, mask, width, height, raw, convert)
            apply_open_mask(raw, args.open_radius, output, convert, tmpdir)
            transparent_count = str(transparent)

    out_width, out_height, out_channels = identify_info(output, identify)
    corner = run([convert, str(output), "-format", "%[pixel:p{0,0}]", "info:"]).decode().strip()
    preview_paths = preview(output, args.preview_color, convert)

    print(f"output={output}")
    print(f"format=PNG size={out_width}x{out_height} channels={out_channels}")
    print(f"corner={corner}")
    print(f"background_pixels={transparent_count}")
    if backup:
        print(f"backup={backup}")
    for item in preview_paths:
        print(f"preview={item}")

    if out_width != width or out_height != height:
        raise SystemExit("output size changed unexpectedly")
    if "a" not in out_channels.lower():
        raise SystemExit("output does not contain alpha")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
