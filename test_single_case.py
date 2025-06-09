from sara_hybrid.io.sara_loader import load_cases
from sara_hybrid.hybrid.router import decide_case

def main():
    """
    Loads all cases and runs only the specific one we want to debug.
    """
    all_cases = load_cases()
    case_to_test = None

    target_case_id = "s7703_a_2_pos"

    for case in all_cases:
        if case.get("case id") == target_case_id:
            case_to_test = case
            break

    if case_to_test:
        print(f"--- Running single case debug for: {target_case_id} ---")
        result = decide_case(case_to_test)
        print(f"\n--- FINAL RESULT for {target_case_id} ---")
        print(f"Prediction: {result}")
        print(f"Ground Truth: {case_to_test.get('answer')}")
        print("------------------------------------------")
    else:
        print(f"Could not find case with ID: {target_case_id}")

if __name__ == "__main__":
    main()