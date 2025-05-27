from sara_hybrid.hybrid.router import decide_case, ENTAILMENT, CONTRADICTION

# Tiny self-contained statute & case
STATUTE = "If Alice is a parent of Bob, and Bob is a parent of Carol, then Alice is an ancestor of Carol."
PROLOG  = "ancestor(X,Y) :- parent(X,Y).\nancestor(X,Y) :- parent(X,Z), ancestor(Z,Y)."
CASE = {
    "statute": STATUTE,
    "test case": "Alice is a parent of Bob. Bob is a parent of Carol.",
    "answer": "Entailment"  # gold
}

def test_decide_entail():
    # monkey-patch translator to return our known rule to keep the test fast/det-erministic
    import sara_hybrid.hybrid.router as R
    R.translate_statute_to_prolog = lambda _: PROLOG
    R.exec_rules                  = lambda r,f,q: (q == "entailment.", [{}])  # pretend entail succeeds
    assert decide_case(CASE) == ENTAILMENT
