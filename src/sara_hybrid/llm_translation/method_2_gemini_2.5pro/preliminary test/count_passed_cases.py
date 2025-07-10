#!/usr/bin/env python3
import re
import os
import sys
from pathlib import Path

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
    
    # Split by the run separator lines - handle both old and new formats
    # Old format: "======================= First Run =========================="
    # New format: "========================= Run 1 ========================="
    runs = re.split(r'^=+\s*(?:First|Second|Third|Run \d+)\s*=+$', content, flags=re.MULTILINE)
    
    # If no runs found with the new format, try the old format
    if len(runs) <= 1:
        runs = re.split(r'^=+\s*(?:First|Second|Third) Run\s*=+$', content, flags=re.MULTILINE)
    
    run_names = ['First Run', 'Second Run', 'Third Run']
    # Start at index 1 because split will have an empty string at the beginning
    for idx, run_content in enumerate(runs[1:], 1):
        if idx > len(run_names): 
            run_name = f"Run {idx}"
        else:
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

def find_log_file():
    """Find the appropriate log file to analyze."""
    script_dir = Path(__file__).parent
    
    # Focus on current pipeline results only
    log_files = [
        "prolog_execution.log",  # Current pipeline output
    ]
    
    for log_file in log_files:
        log_path = script_dir / log_file
        if log_path.exists():
            return log_path
    
    return None

if __name__ == "__main__":
    # Try to find the current pipeline log file
    log_file = find_log_file()
    
    # If no log file found, check command line arguments
    if log_file is None:
        if len(sys.argv) > 1:
            log_file = Path(sys.argv[1])
            if not log_file.exists():
                print(f"Error: Log file {log_file} not found!")
                sys.exit(1)
        else:
            print("Error: No pipeline log file found!")
            print("Expected file: prolog_execution.log")
            print("Available options:")
            print("1. Run the pipeline first: python prolog_pipeline.py")
            print("2. Specify log file path as argument: python count_passed_cases.py <log_file>")
            sys.exit(1)
    
    print(f"Analyzing current pipeline results: {log_file}")
    print("=" * 50)
    
    try:
        analyze_log_file(log_file)
    except Exception as e:
        print(f"Error analyzing log file: {e}")
        sys.exit(1) 