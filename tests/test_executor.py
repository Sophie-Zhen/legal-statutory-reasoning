import pytest

# Skip this entire module if pyswip or the executor fails to import
try:
    from pyswip import Prolog
    from sara_hybrid.symbolic.executor import exec_rules
except Exception as e:
    pytest.skip(f"Skipping symbolic executor tests: {e}", allow_module_level=True)

# Toy rules for testing
RULES = """
parent(alice, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
"""
FACTS = ""  # no extra facts needed

def test_ancestor_true():
    ok, trace = exec_rules(RULES, FACTS, "ancestor(alice, carol).")
    assert ok, "alice should be ancestor of carol"
    assert isinstance(trace, list) and len(trace) >= 1

def test_nonexistent_false():
    ok, trace = exec_rules(RULES, FACTS, "ancestor(carol, alice).")
    assert not ok
    assert trace is None
