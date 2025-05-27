from sara_hybrid.io.sara_loader import load_cases

def test_counts():
    all_cases = load_cases()
    # We should have the full ~359 cases
    assert len(all_cases) >= 350