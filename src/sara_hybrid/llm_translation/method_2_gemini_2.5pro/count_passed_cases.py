#!/usr/bin/env python3
import re

def extract_true_cases(run_content):
    """Extract case IDs where 'Result = true' is immediately followed by 'PASSED (Question assertion holds)' for the same case."""
    lines = run_content.splitlines()
    true_cases = []
    for i, line in enumerate(lines):
        m = re.match(r'Case ([^:]+): Result = true', line)
        if m:
            case_id = m.group(1).strip()
            # Check if next line is PASSED for the same case
            if i+1 < len(lines):
                next_line = lines[i+1]
                if re.match(rf'Case {re.escape(case_id)}: PASSED \(Question assertion holds\)', next_line):
                    true_cases.append(case_id)
    return true_cases

def analyze_log_file(file_path):
    """Analyze the log file and count unique passed/tested cases for each run."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Split by the full separator lines for the runs
    runs = re.split(r'^=+\s*(?:First|Second|Third) Run\s*=+$', content, flags=re.MULTILINE)
    
    run_names = ['First Run', 'Second Run', 'Third Run']
    # Start at index 1 because split will have an empty string at the beginning
    for idx, run_content in enumerate(runs[1:], 1):
        if idx > len(run_names): break
        run_name = run_names[idx-1]
        
        # Find all unique tested cases
        tested_cases_list = re.findall(r'testing\(([^)]+)\)', run_content)
        unique_tested_cases = set(tested_cases_list)
        
        # Find all unique passed cases
        passed_cases_list = extract_true_cases(run_content)
        unique_passed_cases = set(passed_cases_list)
        
        print(f"--- {run_name} ---")
        print(f"Unique PASSED cases: {len(unique_passed_cases)}")
        print(f"Case IDs: {sorted(list(unique_passed_cases))}")
        print(f"Unique cases tested: {len(unique_tested_cases)}")
        
        if len(unique_tested_cases) > 0:
            success_rate = (len(unique_passed_cases) / len(unique_tested_cases)) * 100
            print(f"Success rate: {len(unique_passed_cases)}/{len(unique_tested_cases)} ({success_rate:.1f}%)\n")
        else:
            print("Success rate: N/A (no cases tested)\n")

if __name__ == "__main__":
    # Assumes the script is run from the project root
    log_file = "src/sara_hybrid/llm_translation/method_2_gemini_2.5pro/log_gemini.txt"
    analyze_log_file(log_file) 