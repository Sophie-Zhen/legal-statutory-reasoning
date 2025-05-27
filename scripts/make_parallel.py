#!/usr/bin/env python3
"""
scripts/make_parallel.py

Extract statute→logic pairs by splitting on blank lines.
"""

import json
from pathlib import Path
import re

PROJECT_ROOT = Path(__file__).resolve().parent.parent
STATUTES     = PROJECT_ROOT / "external" / "gpt-statutes" / "sara_run" / "all_sara_statutes.txt"
OUT          = PROJECT_ROOT / "data" / "sara_parallel.jsonl"
OUT.parent.mkdir(exist_ok=True)

def main():
    # Read the whole file and split on one-or-more blank lines
    text = STATUTES.read_text(encoding="utf-8").strip()
    blocks = [b.strip() for b in re.split(r'\n\s*\n', text) if b.strip()]

    pairs = []
    for block in blocks:
        lines = block.splitlines()
        if len(lines) < 2:
            continue
        statute = lines[0].strip()
        logic   = "\n".join(l.strip() for l in lines[1:] if l.strip())
        pairs.append({"statute": statute, "logic": logic})

    print(f"Found {len(pairs)} statute↔logic pairs")
    with open(OUT, "w", encoding="utf-8") as f:
        for p in pairs:
            f.write(json.dumps(p, ensure_ascii=False) + "\n")
    print(f"Wrote {OUT}")

if __name__ == "__main__":
    main()
