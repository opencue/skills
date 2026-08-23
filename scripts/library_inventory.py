#!/usr/bin/env python3
"""Validate the skill library and maintain generated organization metadata."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
README = ROOT / "README.md"
CATALOG = ROOT / "catalog" / "catalog.json"
INDEX = ROOT / "catalog" / "index.json"
ALIASES = ROOT / "catalog" / "aliases.json"
START = "<!-- BEGIN GENERATED CATEGORY TABLE -->"
END = "<!-- END GENERATED CATEGORY TABLE -->"


def skill_paths() -> list[Path]:
    """Return tracked and untracked, non-ignored skill entrypoints.

    A plain filesystem glob also sees host-local ignored skills. Regenerating
    catalog metadata from that view makes CI fail because those files are not
    present in a clean checkout. Git's cached+others view keeps new skills
    visible before their first commit while excluding ignored local material.
    """
    try:
        output = subprocess.check_output(
            [
                "git",
                "ls-files",
                "--cached",
                "--others",
                "--exclude-standard",
                "--",
                "skills/**/SKILL.md",
            ],
            cwd=ROOT,
            text=True,
        )
        return sorted(ROOT / line for line in output.splitlines() if line)
    except (OSError, subprocess.CalledProcessError):
        return sorted(SKILLS.glob("**/SKILL.md"))


def frontmatter(path: Path) -> dict[str, object]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise ValueError("missing opening frontmatter delimiter")
    end = text.find("\n---", 4)
    if end < 0:
        raise ValueError("missing closing frontmatter delimiter")

    lines = text[4:end].splitlines()
    values: dict[str, object] = {}
    i = 0
    while i < len(lines):
        match = re.match(r"^([A-Za-z][A-Za-z0-9_-]*):(?:\s*(.*))?$", lines[i])
        if not match:
            i += 1
            continue
        key, raw = match.groups()
        raw = raw or ""
        if raw in {"|", ">", "|-", ">-"}:
            parts: list[str] = []
            i += 1
            while i < len(lines) and (not lines[i] or lines[i][0].isspace()):
                if lines[i].strip():
                    parts.append(lines[i].strip())
                i += 1
            values[key] = " ".join(parts)
            continue
        if not raw:
            items: list[str] = []
            i += 1
            while i < len(lines) and re.match(r"^\s+-\s+", lines[i]):
                items.append(re.sub(r"^\s+-\s+", "", lines[i]).strip("'\""))
                i += 1
            values[key] = items
            continue
        values[key] = raw.strip("'\"")
        i += 1
    return values


def inventory() -> tuple[list[dict[str, object]], list[str], list[str]]:
    records: list[dict[str, object]] = []
    errors: list[str] = []
    warnings: list[str] = []
    names: defaultdict[str, list[str]] = defaultdict(list)

    for path in skill_paths():
        rel = path.relative_to(ROOT).as_posix()
        parts = path.relative_to(SKILLS).parts
        skill_id = f"{parts[0]}/{'/'.join(parts[1:-1])}"
        try:
            meta = frontmatter(path)
        except ValueError as exc:
            errors.append(f"{rel}: {exc}")
            continue
        name = str(meta.get("name", "")).strip()
        if not name:
            errors.append(f"{rel}: missing name")
        names[name].append(skill_id)
        declared = str(meta.get("category", "")).strip()
        if declared and declared != parts[0]:
            warnings.append(
                f"{rel}: category '{declared}' differs from folder '{parts[0]}'"
            )
        if len(parts) > 3 and parts[-2] == parts[-3]:
            warnings.append(f"{rel}: nested same-name directory")
        records.append(
            {
                "id": skill_id,
                "name": name,
                "category": parts[0],
                "source": rel,
                "meta": meta,
            }
        )

    for name, ids in sorted(names.items()):
        if name and len(ids) > 1:
            warnings.append(f"duplicate name '{name}': {', '.join(ids)}")

    # Generated gstack files must retain the metadata controlled by templates.
    for template in sorted((SKILLS / "gstack").glob("*/SKILL.md.tmpl")):
        generated = Path(str(template).removesuffix(".tmpl"))
        if not generated.exists():
            errors.append(f"{template.relative_to(ROOT)}: generated SKILL.md missing")
            continue
        source_meta = frontmatter(template)
        generated_meta = frontmatter(generated)
        for key in ("allowed-tools", "category"):
            if source_meta.get(key) != generated_meta.get(key):
                errors.append(
                    f"{generated.relative_to(ROOT)}: {key} differs from template"
                )

    return records, errors, warnings


def category_block(records: list[dict[str, object]]) -> str:
    counts = Counter(str(record["category"]) for record in records)
    rows = [START, "| Category | Skills |", "|----------|-------:|"]
    rows.extend(f"| `{category}` | {count} |" for category, count in counts.most_common())
    rows.append(END)
    return "\n".join(rows)


def expected_readme(records: list[dict[str, object]]) -> str:
    text = README.read_text(encoding="utf-8")
    counts = Counter(str(record["category"]) for record in records)
    text = re.sub(
        r"> \d+ skills across \d+ categories\.",
        f"> {len(records)} skills across {len(counts)} categories.",
        text,
        count=1,
    )
    block = category_block(records)
    if START in text and END in text:
        return re.sub(
            re.escape(START) + r".*?" + re.escape(END),
            block,
            text,
            flags=re.DOTALL,
        )
    heading = "## Categories\n"
    start = text.index(heading) + len(heading)
    end = text.index("\n## ", start)
    return text[:start] + "\n" + block + "\n" + text[end:]


def check_catalog(path: Path, records: list[dict[str, object]], key: str) -> list[str]:
    issues: list[str] = []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"{path.relative_to(ROOT)}: unreadable: {exc}"]
    entries = data.get(key, [])
    expected = {str(record["id"]) for record in records}
    actual = {
        str(item.get("id") or f"{item.get('category', '')}/{item.get('name', '')}")
        for item in entries
    }
    if actual != expected:
        issues.append(
            f"{path.relative_to(ROOT)}: IDs differ from tree "
            f"(missing={len(expected - actual)}, extra={len(actual - expected)})"
        )
    absolute = [str(item.get("source", "")) for item in entries if Path(str(item.get("source", ""))).is_absolute()]
    if absolute:
        issues.append(f"{path.relative_to(ROOT)}: {len(absolute)} absolute source paths")
    return issues


def check_aliases(records: list[dict[str, object]]) -> list[str]:
    issues: list[str] = []
    try:
        aliases = json.loads(ALIASES.read_text(encoding="utf-8")).get("aliases", {})
    except (OSError, json.JSONDecodeError) as exc:
        return [f"catalog/aliases.json: unreadable: {exc}"]
    ids = {str(record["id"]) for record in records}
    for old_id, target_id in aliases.items():
        if old_id in ids:
            issues.append(f"catalog/aliases.json: alias source still exists: {old_id}")
        if target_id not in ids:
            issues.append(f"catalog/aliases.json: missing alias target: {target_id}")
        if old_id == target_id:
            issues.append(f"catalog/aliases.json: self-referential alias: {old_id}")
    return issues


def normalize_index(records: list[dict[str, object]]) -> None:
    data = json.loads(INDEX.read_text(encoding="utf-8"))
    by_record = {str(record["id"]): record for record in records}
    skills = []
    seen: set[str] = set()
    for existing in data.get("skills", []):
        skill_id = str(existing.get("id", ""))
        if skill_id not in by_record:
            continue
        record = by_record[skill_id]
        item = existing.copy()
        item["name"] = record["name"]
        item["category"] = record["category"]
        item["source"] = record["source"]
        skills.append(item)
        seen.add(skill_id)
    for skill_id in sorted(set(by_record) - seen):
        record = by_record[skill_id]
        meta = record["meta"]
        skills.append(
            {
                "id": skill_id,
                "name": record["name"],
                "category": record["category"],
                "description": meta.get("description", ""),
                "source": record["source"],
            }
        )
    data["skills"] = skills
    data["counts"] = {
        "skills": len(skills),
        "withTriggers": sum(bool(item.get("triggers")) for item in skills),
        "withCapability": sum(bool(item.get("capability")) for item in skills),
        "withRequires": sum(bool(item.get("requires", {}).get("mcps")) for item in skills),
    }
    data.pop("catalog_mtime", None)
    INDEX.write_text(json.dumps(data, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="refresh README and catalog index metadata")
    args = parser.parse_args()
    records, errors, warnings = inventory()

    expected = expected_readme(records)
    if args.write:
        README.write_text(expected, encoding="utf-8")
        normalize_index(records)
    elif README.read_text(encoding="utf-8") != expected:
        errors.append("README.md: generated skill/category counts are stale")

    if not args.write:
        errors.extend(check_catalog(CATALOG, records, "installed"))
        errors.extend(check_catalog(INDEX, records, "skills"))
        errors.extend(check_aliases(records))

    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    print(f"inventory: {len(records)} skills, {len(set(r['category'] for r in records))} categories, {len(warnings)} warnings, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
