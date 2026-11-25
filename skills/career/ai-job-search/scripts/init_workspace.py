#!/usr/bin/env python3
"""Create a private, editable AI Job Search workspace from the bundled template."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parent.parent
TEMPLATE_ROOT = SKILL_ROOT / "assets" / "workspace-template"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create an AI Job Search workspace for Codex."
    )
    parser.add_argument(
        "target",
        type=Path,
        help="new or empty directory that will hold private job-search data",
    )
    return parser.parse_args()


def ensure_safe_target(target: Path) -> None:
    if target.exists() and not target.is_dir():
        raise ValueError(f"target exists and is not a directory: {target}")
    if target.exists() and any(target.iterdir()):
        raise ValueError(f"target directory is not empty: {target}")


def restore_skill_entrypoints(target: Path) -> int:
    restored = 0
    for template in target.rglob("SKILL.md.template"):
        destination = template.with_name("SKILL.md")
        template.replace(destination)
        restored += 1
    return restored


def initialize(target: Path) -> int:
    if not TEMPLATE_ROOT.is_dir():
        raise RuntimeError(f"bundled workspace template is missing: {TEMPLATE_ROOT}")

    target = target.expanduser().resolve()
    ensure_safe_target(target)
    shutil.copytree(TEMPLATE_ROOT, target, dirs_exist_ok=target.exists())
    restored = restore_skill_entrypoints(target)
    if restored != 9:
        raise RuntimeError(
            f"expected to restore 9 nested skills, restored {restored}; "
            "the bundled template may be incomplete"
        )
    return restored


def main() -> int:
    args = parse_args()
    try:
        restored = initialize(args.target)
    except (OSError, RuntimeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    target = args.target.expanduser().resolve()
    print(f"Created AI Job Search workspace: {target}")
    print(f"Restored {restored} Codex/Agent Skills entrypoints.")
    print("Next:")
    print(f"  cd {target}")
    print("  codex")
    print('  Ask: "Set up my private job-search profile."')
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
