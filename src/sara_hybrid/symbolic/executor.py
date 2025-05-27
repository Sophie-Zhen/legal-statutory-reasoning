#  ──────────────────────────────────────────────────────────────────────
#  src/sara_hybrid/symbolic/executor.py
#
#  Tiny wrapper around PySwip that
#  1.  makes Home-brew SWI-Prolog visible on macOS / Linux,
#  2.  exposes a single public helper:
#
#         exec_rules(rules:str, facts:str, query:str)
#            → (ok:bool, bindings | None)
#
#     ‘bindings’ is a list of dicts [{var: value, …}] when the query
#     succeeds, otherwise None.
#  ──────────────────────────────────────────────────────────────────────
from __future__ import annotations

import os
import shutil
import sys
from typing import List, Dict, Tuple, Optional

# ---------------------------------------------------------------------
#  Step 1: ensure PySwip can find the SWI-Prolog shared library
# ---------------------------------------------------------------------
def _patch_swipl_locator() -> None:
    """Monkey-patch pyswip.core so it finds Home-brew installs."""
    try:
        from pyswip import core as _core  # type: ignore
    except Exception:
        return  # PySwip not importable – we’ll fall back later.

    if hasattr(_core, "_find_swipl"):
        return  # Recent PySwip already knows the path.

    # Older PySwip: inject a simplified resolver.
    def _find_swipl() -> Tuple[str, str]:
        # Common Home-brew / apt locations (extend if needed)
        candidates = [
            "/opt/homebrew/bin/swipl",  # macOS arm64 (brew)
            "/usr/local/bin/swipl",     # macOS Intel (brew)
            "/usr/bin/swipl",           # Debian/Ubuntu
        ]
        for exe in candidates:
            if shutil.which(exe):  # executable exists & on PATH
                swi_home = os.path.dirname(os.path.dirname(exe))
                return exe, swi_home
        raise _core.SwiPrologNotFoundError("SWI-Prolog executable not found")

    _core._find_swipl = _find_swipl  # type: ignore[attr-defined]


_patch_swipl_locator()

# ---------------------------------------------------------------------
#  Step 2: import PySwip *after* patching
# ---------------------------------------------------------------------
try:
    from pyswip import Prolog  # type: ignore
except Exception as e:  # pragma: no cover
    Prolog = None          # type: ignore[assignment]
    _IMPORT_ERROR = e
else:
    _IMPORT_ERROR = None

# ---------------------------------------------------------------------
#  Step 3: public helper
# ---------------------------------------------------------------------
def exec_rules(
    rules: str,
    facts: str,
    query: str,
) -> Tuple[bool, Optional[List[Dict[str, str]]]]:
    """
    Load *rules* + *facts* into a fresh Prolog engine, run *query*.

    Returns
    -------
    (True, bindings)      if query succeeds
    (False, None)         otherwise
    """
    if Prolog is None:  # PySwip not available
        raise RuntimeError(f"PySwip unavailable: {_IMPORT_ERROR}")

    pl = Prolog()

    # Feed rules (can be multi-line)
    for clause in rules.strip().splitlines():
        if clause.strip():
            pl.assertz(clause.rstrip("."))  # remove trailing dot for assertz/1

    # Feed facts (each must end with '.')
    for fact in facts.strip().splitlines():
        if fact.strip():
            pl.assertz(fact.rstrip("."))

    # Run the yes/no query
    result = list(pl.query(query.rstrip(".")))  # remove trailing dot

    return (len(result) > 0, result or None)
