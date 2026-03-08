#!/usr/bin/env python
"""Batch-remove portrait backgrounds and write transparent PNGs."""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path


SUPPORTED_SOURCE_SUFFIXES = {".jpg", ".jpeg", ".jiff", ".jfif"}


@dataclass
class ProcessResult:
    processed: int = 0
    skipped: int = 0
    deleted: int = 0
    failed: int = 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Cast Mage Hand Matte on one portrait or a folder of portraits. "
            "Converts source JPG/JPEG/JIFF/JFIF files into transparent PNGs using rembg."
        )
    )
    parser.add_argument("input_path", help="Source file or folder to process.")
    parser.add_argument(
        "--output-dir",
        help=(
            "Optional output directory. When processing folders, relative paths are "
            "preserved under this directory."
        ),
    )
    parser.add_argument(
        "--recursive",
        action="store_true",
        help="Recurse into subdirectories when the input path is a folder.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing PNG outputs instead of skipping them.",
    )
    parser.add_argument(
        "--delete-source",
        action="store_true",
        help="Delete the source JPEG-family file and matching .import file after a successful conversion.",
    )
    parser.add_argument(
        "--model",
        default="u2net",
        help="rembg model name to use. Default: u2net",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    input_path = Path(args.input_path).resolve()
    output_root = Path(args.output_dir).resolve() if args.output_dir else None

    if not input_path.exists():
        print(f"Input path does not exist: {input_path}", file=sys.stderr)
        return 1

    try:
        from PIL import Image
        from rembg import new_session, remove
    except ImportError as exc:
        print(
            "Missing dependency. Run this tool with the rembg environment, or install "
            "'rembg' and 'pillow' first.",
            file=sys.stderr,
        )
        print(str(exc), file=sys.stderr)
        return 1

    source_files = collect_source_files(input_path, recursive=args.recursive)
    if not source_files:
        print("No supported JPEG-family portraits found to process.", file=sys.stderr)
        return 1

    if output_root is not None:
        output_root.mkdir(parents=True, exist_ok=True)

    session = new_session(model_name=args.model)
    result = ProcessResult()

    for source_file in source_files:
        destination = build_output_path(source_file, input_path, output_root)
        destination.parent.mkdir(parents=True, exist_ok=True)

        if destination.exists() and not args.overwrite:
            print(f"Skipping existing output: {destination}")
            result.skipped += 1
            continue

        try:
            with Image.open(source_file) as image:
                cutout = remove(image.convert("RGBA"), session=session)
                cutout.save(destination, format="PNG")
        except Exception as exc:  # pragma: no cover - defensive CLI handling
            print(f"Failed: {source_file} -> {destination} ({exc})", file=sys.stderr)
            result.failed += 1
            continue

        print(f"Converted: {source_file} -> {destination}")
        result.processed += 1

        if args.delete_source:
            delete_source_files(source_file, result)

    print(
        "Done. "
        f"converted={result.processed} skipped={result.skipped} "
        f"deleted={result.deleted} failed={result.failed}"
    )
    return 1 if result.failed else 0


def collect_source_files(input_path: Path, recursive: bool) -> list[Path]:
    if input_path.is_file():
        return [input_path] if input_path.suffix.lower() in SUPPORTED_SOURCE_SUFFIXES else []

    pattern = "**/*" if recursive else "*"
    files = [
        path
        for path in input_path.glob(pattern)
        if path.is_file() and path.suffix.lower() in SUPPORTED_SOURCE_SUFFIXES
    ]
    files.sort()
    return files


def build_output_path(source_file: Path, root_input: Path, output_root: Path | None) -> Path:
    if output_root is None:
        return source_file.with_suffix(".png")

    if root_input.is_file():
        return output_root / source_file.with_suffix(".png").name

    relative_path = source_file.relative_to(root_input).with_suffix(".png")
    return output_root / relative_path


def delete_source_files(source_file: Path, result: ProcessResult) -> None:
    import_file = source_file.with_name(f"{source_file.name}.import")

    for candidate in (source_file, import_file):
        if not candidate.exists():
            continue
        candidate.unlink()
        result.deleted += 1
        print(f"Deleted: {candidate}")


if __name__ == "__main__":
    raise SystemExit(main())
