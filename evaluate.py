# evaluate.py

import json
from pathlib import Path
from collections import Counter
from tqdm import tqdm
from dotenv import load_dotenv

# Load environment variables from .env file (for the OpenAI key)
load_dotenv()

from sara_hybrid.io.sara_loader import load_cases
from sara_hybrid.hybrid.router import decide_case, ENTAILMENT, CONTRADICTION

CACHE_FILE = Path("llm_cache.json")

def load_llm_cache():
    """Loads the LLM cache file if it exists."""
    if CACHE_FILE.is_file():
        with open(CACHE_FILE, 'r') as f:
            print("INFO: Loading existing LLM cache.")
            return json.load(f)
    return {}

def save_llm_cache(cache_data):
    """Saves the given data to the LLM cache file."""
    with open(CACHE_FILE, 'w') as f:
        json.dump(cache_data, f, indent=4)

def print_results(results):
    # ... (this function does not need any changes) ...
    total_cases = len(results)
    correct_predictions = sum(1 for r in results if r["correct"])
    accuracy = (correct_predictions / total_cases) * 100 if total_cases > 0 else 0
    print("\n--- SARA Hybrid System Evaluation ---")
    print(f"\nTotal Cases Processed: {total_cases}")
    print(f"Correct Predictions:   {correct_predictions}")
    print(f"Accuracy:              {accuracy:.2f}%")
    print("\nConfusion Matrix:")
    predictions = [r["prediction"] for r in results]
    ground_truths = [r["ground_truth"] for r in results]
    matrix = Counter(zip(ground_truths, predictions))
    header = f"{'':<20} | {'Predicted: Entailment':<25} | {'Predicted: Contradiction':<25}"
    print(header); print("-" * len(header))
    true_ent_pred_ent = matrix.get((ENTAILMENT, ENTAILMENT), 0)
    true_ent_pred_con = matrix.get((ENTAILMENT, CONTRADICTION), 0)
    print(f"{'Actual: Entailment':<20} | {true_ent_pred_ent:<25} | {true_ent_pred_con:<25}")
    true_con_pred_ent = matrix.get((CONTRADICTION, ENTAILMENT), 0)
    true_con_pred_con = matrix.get((CONTRADICTION, CONTRADICTION), 0)
    print(f"{'Actual: Contradiction':<20} | {true_con_pred_ent:<25} | {true_con_pred_con:<25}")
    print("\n-------------------------------------\n")

def main():
    """Main function to load data, run evaluation with caching, and print results."""
    all_cases = load_cases()
    if not all_cases: return

    llm_cache = load_llm_cache()
    results = []
    
    # First, process all cases already in the cache
    cases_to_process_api = []
    for case in all_cases:
        case_id = case.get("case id")
        if case_id and case_id in llm_cache:
            prediction = llm_cache[case_id]
            results.append({"id": case_id, "prediction": prediction, "ground_truth": case.get("answer"), "correct": prediction == case.get("answer")})
        else:
            cases_to_process_api.append(case)

    print(f"INFO: Found {len(llm_cache)} cases in cache. Processing {len(cases_to_process_api)} new cases via API.")

    # Now, process the remaining cases via the API
    for case in tqdm(cases_to_process_api, desc="Evaluating new SARA Cases via API"):
        case_id = case.get("case id")
        prediction = decide_case(case)
        
        if prediction is None:
            print(f"API call failed for case {case_id} (e.g. out of quota). Stopping evaluation.")
            print("Saving partial results to cache...")
            save_llm_cache(llm_cache)
            break # Stop processing to save quota

        # Add successful prediction to results and cache
        results.append({"id": case_id, "prediction": prediction, "ground_truth": case.get("answer"), "correct": prediction == case.get("answer")})
        if case_id:
            llm_cache[case_id] = prediction

    # Save the final cache and print results
    save_llm_cache(llm_cache)
    print_results(results)

if __name__ == "__main__":
    main()