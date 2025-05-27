#!/usr/bin/env python3
"""
scripts/make_parallel.py

Reads the raw statute‐to‐Prolog translations provided in the Blair-Stanek gpt-statutes
repo and writes out data/sara_parallel.jsonl with one JSON line per (statute, logic) pair.
"""

import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# 1. point this at your local clone of the baseline repo
BASE = PROJECT_ROOT / "external" / "gpt-statutes" / "sara_run"

# 2. The file that contains every statute section followed by its Prolog rule(s):
STATUTES = BASE / "all_sara_statutes.txt"

# 3. output path in your project
OUT = PROJECT_ROOT / "data" / "sara_parallel.jsonl"
OUT.parent.mkdir(exist_ok=True)


def main():
    text = STATUTES.read_text(encoding="utf-8").strip()
    # split on two newlines: each block is one section + its logic
    blocks = [b for b in text.split("\n\n") if b.strip()]
    pairs = []
    for block in blocks:
        lines = block.splitlines()
        statute = lines[0].strip()
        logic   = "\n".join(l.strip() for l in lines[1:])
        pairs.append({"statute": statute, "logic": logic})

    print(f"Found {len(pairs)} statute↔logic pairs")
    with open(OUT, "w", encoding="utf-8") as f:
        for p in pairs:
            f.write(json.dumps(p, ensure_ascii=False) + "\n")
    print(f"Wrote {OUT}")

if __name__ == "__main__":
    main()
