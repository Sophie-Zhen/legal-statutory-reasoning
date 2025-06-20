#!/usr/bin/env python3
import re

def extract_true_cases(run_content):
    """Extract case IDs where 'Result = true' is immediately followed by 'PASSED (Question assertion holds)' for the same case."""
    lines = run_content.splitlines()
    true_cases = []
    for i, line in enumerate(lines):
        m = re.match(r'Case ([^:]+): Result = true', line)
        if m:
            case_id = m.group(1)
            # Check if next line is PASSED for the same case
            if i+1 < len(lines):
                next_line = lines[i+1]
                if re.match(rf'Case {re.escape(case_id)}: PASSED \(Question assertion holds\)', next_line):
                    true_cases.append(case_id)
    return true_cases

def analyze_log_file(file_path):
    """Analyze the log file and count/list true cases for each run."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Use regex to split on the full separator lines
    runs = re.split(r'^=+\s*First Run\s*=+$|^=+\s*Second Run\s*=+$', content, flags=re.MULTILINE)
    # The runs list will have: [before, first_run, second_run, after]
    if len(runs) >= 3:
        first_run = runs[1]
        second_run = runs[2]
        first_true_cases = extract_true_cases(first_run)
        second_true_cases = extract_true_cases(second_run)
        first_run_cases = len(re.findall(r'testing\(', first_run))
        second_run_cases = len(re.findall(r'testing\(', second_run))
        print("Analysis of log_gemini.txt:")
        print("=" * 40)
        print(f"First Run - Unique PASSED cases: {len(first_true_cases)}")
        print(f"Case IDs: {first_true_cases}")
        print(f"Second Run - Unique PASSED cases: {len(second_true_cases)}")
        print(f"Case IDs: {second_true_cases}")
        print(f"\nFirst Run - Total cases tested: {first_run_cases}")
        print(f"Second Run - Total cases tested: {second_run_cases}")
        if first_run_cases > 0:
            print(f"First Run - Success rate: {len(first_true_cases)}/{first_run_cases} ({len(first_true_cases)/first_run_cases*100:.1f}%)")
        else:
            print("First Run - Success rate: N/A (no cases tested)")
        if second_run_cases > 0:
            print(f"Second Run - Success rate: {len(second_true_cases)}/{second_run_cases} ({len(second_true_cases)/second_run_cases*100:.1f}%)")
        else:
            print("Second Run - Success rate: N/A (no cases tested)")
        return first_true_cases, second_true_cases
    else:
        print("Could not identify separate runs in the log file.")
        return [], []

if __name__ == "__main__":
    log_file = "src/sara_hybrid/llm_translation/method_2_gemini_2.5pro/log_gemini.txt"
    analyze_log_file(log_file) 