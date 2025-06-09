from __future__ import annotations
import json, os
from pathlib import Path
from typing import List, Dict

_ENV = "SARA_DATA"                       # export this once in ~/.zshrc
_DEFAULT = Path.home() / "datasets" / "SARA"

def _loc() -> Path:
    root = Path(os.getenv(_ENV, _DEFAULT))
    return root / "sara_cases.json"

def load_cases(split: str = "all") -> List[Dict]:
    data = json.loads(_loc().read_text())
    if split == "all":
        return data
    return [c for c in data if c["split"] == split]
