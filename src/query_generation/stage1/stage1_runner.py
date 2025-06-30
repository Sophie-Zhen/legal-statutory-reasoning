import os
import subprocess
from llm.gemini_client import GeminiClient
import re

# --- CONFIGURATION ---
CASE_ID = "s151_a_neg"
BASE_DIR = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
STAGE1_DIR = os.path.join(BASE_DIR, "src/query_generation/stage1")
# **MODIFICATION**: Use the new, simple prompt file
PROMPT_PATH = os.path.join(STAGE1_DIR, f"prompts/stage1_{CASE_ID}_simple_prompt.txt")
RAW_QUERIES_DIR = os.path.join(STAGE1_DIR, "stage1_results/raw_queries")
GENERATED_QUERY_PATH = os.path.join(RAW_QUERIES_DIR, f"{CASE_ID}.pl")
SARA_DATA_DIR = os.path.join(BASE_DIR, "data/sara_v3")

# **MODIFICATION**: Define paths for temporary sanitized files
TEMP_TEST_FILE = os.path.join(STAGE1_DIR, "temp_main_test.pl")
TEMP_CASE_FACTS_FILE = os.path.join(STAGE1_DIR, "temp_case_facts.pl")


def run_prototype():
    """Main function to run the end-to-end process for a single case."""
    
    # --- PHASE 1: GENERATION ---
    print(f"--- Phase 1: Generating query for {CASE_ID} ---")
    
    os.makedirs(RAW_QUERIES_DIR, exist_ok=True)
    
    try:
        with open(PROMPT_PATH, 'r') as f:
            prompt_content = f.read()
        print(f"Successfully read prompt file: {PROMPT_PATH}")
    except FileNotFoundError:
        print(f"ERROR: Prompt file not found at {PROMPT_PATH}")
        return

    try:
        client = GeminiClient()
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return

    generated_query = client.generate(prompt_content)
    
    with open(GENERATED_QUERY_PATH, 'w') as f:
        f.write(generated_query)
    print(f"Generated query saved to: {GENERATED_QUERY_PATH}")

    if not generated_query or "ERROR:" in generated_query:
        print("Halting evaluation due to generation failure.")
        return

    # --- PHASE 2: EVALUATION ---
    print(f"\n--- Phase 2: Evaluating generated query for {CASE_ID} ---")
    
    ground_truth_result = "true."
    print(f"Ground truth for this case is: {ground_truth_result}")

    # **MODIFICATION**: Sanitize the original case file to prevent pathing errors
    original_case_path = os.path.join(SARA_DATA_DIR, f'cases/{CASE_ID}.pl')
    try:
        with open(original_case_path, 'r') as f_in:
            lines = f_in.readlines()
        # Filter out the problematic line
        sanitized_lines = [line for line in lines if "statutes/prolog/init" not in line]
        with open(TEMP_CASE_FACTS_FILE, 'w') as f_out:
            f_out.write("".join(sanitized_lines))
        print(f"Sanitized case facts saved to: {TEMP_CASE_FACTS_FILE}")
    except FileNotFoundError:
        print(f"ERROR: Original case file not found at {original_case_path}")
        return

    init_pl_path = os.path.relpath(os.path.join(SARA_DATA_DIR, 'statutes/prolog/init.pl'), STAGE1_DIR)
    llm_query_path = os.path.relpath(GENERATED_QUERY_PATH, STAGE1_DIR)

    temp_prolog_content = f"""
:- consult('{init_pl_path}').
:- consult('{TEMP_CASE_FACTS_FILE}'). 
:- consult('{llm_query_path}').

run_test_and_print :-
    (   answer('{CASE_ID}', Result)
    ->  write(Result)
    ;   write('failed_to_answer')
    ),
    halt.
"""
    with open(TEMP_TEST_FILE, "w") as f:
        f.write(temp_prolog_content)
    print(f"Created temporary test file: {TEMP_TEST_FILE}")

    print("Executing SWI-Prolog...")
    command = ["swipl", "-q", "-s", TEMP_TEST_FILE, "-g", "run_test_and_print"]
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        prolog_output = result.stdout.strip()
    except FileNotFoundError:
        print("ERROR: 'swipl' command not found. Is SWI-Prolog installed and in your PATH?")
        return
    except Exception as e:
        print(f"An error occurred during Prolog execution: {e}")
        return
        
    print(f"Prolog output: '{prolog_output}'")
    
    if prolog_output == ground_truth_result:
        print(f"\n*** Case {CASE_ID}: PASSED ***")
    else:
        print(f"\n*** Case {CASE_ID}: FAILED ***")
        if result.stderr:
            print("\nProlog Errors/Warnings:")
            print(result.stderr)
            
    # Cleanup all temporary files
    os.remove(TEMP_TEST_FILE)
    os.remove(TEMP_CASE_FACTS_FILE)
    print(f"Cleaned up temporary files.")

if __name__ == '__main__':
    run_prototype()