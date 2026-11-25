#!/usr/bin/env python3
"""Regression tests for the AI Job Search workspace initializer."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
INITIALIZER = SCRIPT_DIR / "init_workspace.py"


class InitWorkspaceTests(unittest.TestCase):
    def run_initializer(self, target: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(INITIALIZER), str(target)],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_creates_codex_workspace_and_restores_nested_skill_entrypoints(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / "job-search"

            result = self.run_initializer(target)

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((target / "AGENTS.md").is_file())
            self.assertTrue((target / ".claude" / "commands" / "apply.md").is_file())
            self.assertTrue(
                (
                    target
                    / ".agents"
                    / "skills"
                    / "linkedin-search"
                    / "cli"
                    / "src"
                    / "cli.ts"
                ).is_file()
            )
            self.assertEqual(len(list(target.rglob("SKILL.md"))), 9)
            self.assertEqual(len(list(target.rglob("SKILL.md.template"))), 0)

    def test_refuses_to_overwrite_a_non_empty_target(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / "existing"
            target.mkdir()
            sentinel = target / "keep.txt"
            sentinel.write_text("keep me", encoding="utf-8")

            result = self.run_initializer(target)

            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(sentinel.read_text(encoding="utf-8"), "keep me")
            self.assertIn("not empty", result.stderr.lower())


if __name__ == "__main__":
    unittest.main()
