#!/usr/bin/env python3
"""embed-search.py — semantic fallback for smart-loader.

Called by smart-lookup.sh when CUE_USE_EMBEDDINGS=1 and the keyword
returns no scored hits. Loads the cached embedding index, encodes the
query, returns top-K names by cosine similarity.

Usage:
    embed-search.py "<query>" [top_k]

Output (TSV): <category/name>\t<cosine_score>
Empty output = no embeddings file or no result above floor.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

EMB = Path(os.environ.get(
    "CUE_EMBEDDINGS",
    str(Path.home() / ".cache/cue/embeddings.npz"),
))
MODEL_NAME = os.environ.get("CUE_EMBED_MODEL", "all-MiniLM-L6-v2")
FLOOR = float(os.environ.get("CUE_EMBED_FLOOR", "0.35"))


def main() -> int:
    if len(sys.argv) < 2:
        return 2
    query = sys.argv[1]
    top_k = int(sys.argv[2]) if len(sys.argv) > 2 else 5

    if not EMB.exists():
        return 0

    try:
        import numpy as np
        from sentence_transformers import SentenceTransformer
    except ImportError:
        return 0

    data = np.load(EMB, allow_pickle=True)
    vectors = data["vectors"]
    names = data["names"]

    model = SentenceTransformer(MODEL_NAME)
    q = model.encode([query], normalize_embeddings=True)[0]
    sims = vectors @ q

    order = sims.argsort()[::-1][:top_k]
    for i in order:
        s = float(sims[i])
        if s < FLOOR:
            break
        print(f"{names[i]}\t{s:.3f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
