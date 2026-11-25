"""Regression checks for fork-source metadata; no third-party dependencies."""

from __future__ import annotations

import json
from pathlib import Path
from tempfile import TemporaryDirectory

from library_inventory import check_fork_sources


def test_fork_sources() -> None:
    skill_id, fork, commit = "forks/demo", "Example/demo", "a" * 40
    entrypoint = "skills/demo/SKILL.md"
    record: dict[str, object] = {"id": skill_id, "source": "skills/forks/demo/SKILL.md", "category": "forks"}
    entry = dict(fork=fork, entrypoint=entrypoint, mode="bundled", license_files=["LICENSE"])
    repository = {"commit": commit, "status": "imported"}
    manifest = {"repositories": {fork: repository}, "skills": {skill_id: entry}}

    with TemporaryDirectory() as directory:
        root = Path(directory)
        src = root / str(record["source"])
        src.parent.mkdir(parents=True)
        src.write_text(f"https://github.com/{fork}/blob/{commit}/{entrypoint}\n", encoding="utf-8")
        (src.parent / "LICENSE").write_text("Example license\n", encoding="utf-8")
        config = root / "catalog" / "fork-sources.json"
        config.parent.mkdir()

        assert check_fork_sources([record], root=root)[0].startswith("fork-sources.json:")
        config.write_text("{]", encoding="utf-8")
        assert check_fork_sources([record], root=root)[0].startswith("fork-sources.json:")
        config.write_text(json.dumps(manifest), encoding="utf-8")
        assert check_fork_sources([record], root=root) == []

        cases = (
            ("skills", {}, "missing forks/demo"),
            ("skills", {**manifest["skills"], "forks/unknown": entry}, "unknown forks/unknown"),
            ("skills", {skill_id: None}, "invalid source entry"),
            ("repositories", {fork: {**repository, "status": "source-only"}}, "fork is not marked imported"),
            ("repositories", {fork: {**repository, "commit": "abc"}}, "upstream pin differs"),
            ("repositories", {fork: {**repository, "commit": "b" * 40}}, "upstream pin differs"),
            ("skills", {skill_id: {**entry, "entrypoint": "skills/demo/SKILL.m"}}, "upstream pin differs"),
            ("skills", {skill_id: {**entry, "entrypoint": ""}}, "upstream pin differs"),
            ("skills", {skill_id: {**entry, "mode": "unknown"}}, "unknown source mode"),
            ("skills", {skill_id: {**entry, "license_files": []}}, "missing local license notices"),
            ("skills", {skill_id: {**entry, "license_files": ["../LICENSE"]}}, "missing local license notices"),
            ("skills", {skill_id: {**entry, "license_files": ["NOTICE"]}}, "missing local license notices"),
        )
        for field, value, expected in cases:
            bad = {**manifest, field: value}
            config.write_text(json.dumps(bad), encoding="utf-8")
            issues = check_fork_sources([record], root=root)
            assert any(expected in issue for issue in issues), (expected, issues)


if __name__ == "__main__":
    test_fork_sources()
