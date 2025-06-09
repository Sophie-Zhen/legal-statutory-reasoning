# src/sara_hybrid/symbolic/executor.py
"""
sara_hybrid.symbolic.executor
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Universal `exec_rules` helper.
"""
from __future__ import annotations
import re # Import the regular expression module
from typing import Dict, List, Tuple

# ---------------------------------------------------------------------------
# ── 1 ──  “real” backend (SWI-Prolog via PySwip)  ───────────────────────────
# ---------------------------------------------------------------------------
try:
    from pyswip import Prolog
except Exception:
    Prolog = None

def _exec_rules_swipl(
    rules: str, facts: str, query: str
) -> Tuple[bool, List[Dict[str, str]] | None]:
    """Run the query in a fresh SWI-Prolog instance."""
    assert Prolog is not None
    p = Prolog()

    # Assert all the rules, one per line.
    for rule_line in rules.splitlines():
        if (code := rule_line.strip().rstrip(".")):
            p.assertz(code)

    # --- THIS IS THE FIX ---
    # Use a regular expression to find all Prolog terms like 'functor(...)'
    # This correctly handles terms with commas inside them.
    list_of_facts = re.findall(r'\b\w+\(.*?\)', facts)
    for fact_to_assert in list_of_facts:
        if fact_to_assert:
            print(f"DEBUG (executor.py): Asserting fact -> {fact_to_assert}")
            p.assertz(fact_to_assert)
    # --- END OF FIX ---

    res = list(p.query(query.rstrip(".")))
    return bool(res), res or None


# ---------------------------------------------------------------------------
# ── 2 ──  tiny pure-Python Horn-clause engine  ──────────────────────────────
# ---------------------------------------------------------------------------
def _parse(atom: str):
    fun, args = atom.split("(", 1)
    return fun.strip(), [a.strip() for a in args.rstrip(")").split(",")]

def _ground(args, σ):
    return tuple(σ.get(a, a) for a in args)

def _exec_rules_tiny(
    rules: str, facts: str, query: str
) -> Tuple[bool, List[Dict[str, str]] | None]:
    KB: set[tuple[str, tuple[str, ...]]] = set()
    
    # Also update the tiny engine to use the regex parser for consistency.
    list_of_facts = re.findall(r'\b\w+\(.*?\)', facts)
    for fact in list_of_facts:
        if fact:
            f, a = _parse(fact)
            KB.add((f, tuple(a)))

    clauses = []
    for clause in rules.split("."):
        clause = clause.strip()
        if not clause: continue
        if ":-" in clause:
            head, body = clause.split(":-")
            body_atoms = [b.strip() for b in body.split(",")]
        else:
            head, body_atoms = clause, []
        h_fun, h_args = _parse(head.strip())
        b_parsed = [_parse(b) for b in body_atoms]
        clauses.append((h_fun, h_args, b_parsed))
    changed = True
    while changed:
        changed = False
        for h_fun, h_args, body in clauses:
            vars_ = {a for a in h_args if a[0].isupper()}
            for _, a in body:
                vars_.update(v for v in a if v[0].isupper())
            if not vars_:
                needed = all((b_fun, tuple(b_args)) in KB for b_fun, b_args in body)
                if needed and (h_fun, tuple(h_args)) not in KB:
                    KB.add((h_fun, tuple(h_args)))
                    changed = True
                continue
            var = next(iter(vars_))
            constants = {arg for _, args in KB for arg in args}
            for c in constants:
                σ = {var: c}
                if all((b_fun, _ground(b_args, σ)) in KB for b_fun, b_args in body):
                    head_ground = (h_fun, _ground(h_args, σ))
                    if head_ground not in KB:
                        KB.add(head_ground)
                        changed = True
    q_fun, q_args = _parse(query.rstrip("."))
    ok = (q_fun, tuple(q_args)) in KB
    return ok, ([{}] if ok else None)

# ---------------------------------------------------------------------------
# ── 3 ──  public shim  ──────────────────────────────────────────────────────
# ---------------------------------------------------------------------------
def exec_rules(
    rules: str, facts: str, query: str
) -> Tuple[bool, List[Dict[str, str]] | None]:
    """
    Evaluate *query* given *rules* + *facts*.
    Returns ``(True, bindings_or_None)`` if the query succeeds,
    otherwise ``(False, None)``.
    """
    if Prolog is not None:
        try:
            return _exec_rules_swipl(rules, facts, query)
        except Exception as e:
            print(f"WARNING (exec_rules): SWI-Prolog execution failed ('{e}'). Falling back to tiny engine.")
            pass
    return _exec_rules_tiny(rules, facts, query)

__all__ = ["exec_rules"]