#!/usr/bin/env python3
"""build-embeddings.py — opt-in semantic index for smart-loader.

Reads the cue skills catalog and writes a numpy file with sentence-transformer
embeddings of each skill's (name + description + triggers + tags). Used by
embed-search.py at query time when CUE_USE_EMBEDDINGS=1 is set.

Run after `rebuild-catalog-local.sh`. Idempotent. ~5-10s on first run, much
faster after the model is cached locally (~80MB in ~/.cache/torch/).

Usage:
    python3 build-embeddings.py
    CUE_EMBED_MODEL=all-MiniLM-L6-v2 python3 build-embeddings.py

Output:
    ~/.cache/cue/embeddings.npz  with arrays: vectors (N x D), names (N,)
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

CATALOG = Path(os.environ.get(
    "CUE_CATALOG",
    str(Path.home() / "Documents/cue/resources/skills/catalog/catalog.json"),
))
OUT = Path(os.environ.get(
    "CUE_EMBEDDINGS",
    str(Path.home() / ".cache/cue/embeddings.npz"),
))
MODEL_NAME = os.environ.get("CUE_EMBED_MODEL", "all-MiniLM-L6-v2")


def main() -> int:
    try:
        import numpy as np
        from sentence_transformers import SentenceTransformer
    except ImportError as e:
        print(
            f"ERROR: missing dep: {e}. Install with: pip install sentence-transformers numpy",
            file=sys.stderr,
        )
        return 2

    if not CATALOG.exists():
        print(f"ERROR: catalog not found: {CATALOG}", file=sys.stderr)
        return 2

    with CATALOG.open() as f:
        data = json.load(f)

    entries = data.get("installed", [])
    if not entries:
        print("WARN: catalog has no installed skills", file=sys.stderr)
        return 0

    texts: list[str] = []
    names: list[str] = []
    for e in entries:
        name = e.get("name", "")
        cat = e.get("category", "")
        desc = e.get("description", "")
        triggers = " ".join(e.get("triggers", []) or [])
        tags = " ".join(e.get("tags", []) or [])
        composed = f"{name} {cat} {desc} {triggers} {tags}".strip()
        if not composed:
            continue
        texts.append(composed)
        names.append(f"{cat}/{name}")

    print(f"Loading model {MODEL_NAME}...", file=sys.stderr)
    model = SentenceTransformer(MODEL_NAME)
    print(f"Embedding {len(texts)} skills...", file=sys.stderr)
    vectors = model.encode(texts, normalize_embeddings=True, show_progress_bar=False)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    np.savez(OUT, vectors=vectors, names=np.array(names, dtype=object))
    print(f"wrote {OUT} ({len(texts)} vectors, dim={vectors.shape[1]})", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
