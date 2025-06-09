from sara_hybrid.hybrid.router import decide_case, ENTAILMENT, CONTRADICTION

# Tiny self-contained statute & case
STATUTE = "If Alice is a parent of Bob, and Bob is a parent of Carol, then Alice is an ancestor of Carol."
# In tests/test_router.py
PROLOG = "test_prolog_rules(ok)." # Any non-empty string will do for the patched translator
CASE = {
    "id": "test_case_entail",
    "statute_text": "If X then Y.",
    "prolog_facts": "fact(a).",
    "prolog_query": "entailment.", # This needs to match the 'q' in the mock
    # For LLM fallback path, if it were ever taken by this test (it shouldn't be):
    "scenario_text": "X is true.",
    "hypothesis_text": "Y is true."
}

def test_decide_entail():
    # monkey-patch translator to return our known rule to keep the test fast/det-erministic
    import sara_hybrid.hybrid.router as R
    R.translate_statute_to_prolog = lambda _: PROLOG
    R.exec_rules                  = lambda r,f,q: (q == "entailment.", [{}])  # pretend entail succeeds
    assert decide_case(CASE) == ENTAILMENT
