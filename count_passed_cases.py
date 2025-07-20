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
    """Analyze the log file and count/list true cases for each run (First, Second, Third)."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Use regex to split on the full separator lines for three runs
    runs = re.split(r'^=+\s*First Run\s*=+$|^=+\s*Second Run\s*=+$|^=+\s*Third Run\s*=+$', content, flags=re.MULTILINE)
    # The runs list will have: [before, first_run, second_run, third_run, after]
    run_names = ['First Run', 'Second Run', 'Third Run']
    for idx, run_name in enumerate(run_names, 1):
        if len(runs) > idx:
            run_content = runs[idx]
            true_cases = extract_true_cases(run_content)
            total_cases = len(re.findall(r'testing\(', run_content))
            print(f"{run_name} - Unique PASSED cases: {len(set(true_cases))}")
            print(f"Case IDs: {sorted(set(true_cases))}")
            print(f"Total cases tested: {total_cases}")
            if total_cases > 0:
                print(f"Success rate: {len(set(true_cases))}/{total_cases} ({len(set(true_cases))/total_cases*100:.1f}%)\n")
            else:
                print("Success rate: N/A (no cases tested)\n")
        else:
            print(f"{run_name}: Not found in log.\n")

if __name__ == "__main__":
    log_file = "src/sara_hybrid/llm_translation/method_2_gemini_2.5pro/log_gemini.txt"
    analyze_log_file(log_file) 