"""
Integration tests for SARA dataset using Prolog.
Handles loading cases from test split, running tests, and computing metrics.
"""

# Existing imports
import logging
import sys
from pathlib import Path
from typing import Dict
import re
from datetime import datetime
import janus_swi as janus

# Get the project root directory (2 levels up from this script)
PROJECT_ROOT = Path(__file__).parent.parent.parent.parent.parent
SARA_V3_DIR = PROJECT_ROOT / "data" / "sara_v3"

logger = logging.getLogger(__name__)

def get_test_cases():
    """Get case IDs from the test split file."""
    test_file = SARA_V3_DIR / "splits" / "test"
    if not test_file.exists():
        raise FileNotFoundError(f"Test split file not found: {test_file}")
    
    with open(test_file) as f:
        return [line.strip() for line in f if line.strip()]

def get_case_file(case_id):
    """Get the case file path for a given case ID."""
    case_file = SARA_V3_DIR / "cases" / f"{case_id}.pl"
    if not case_file.exists():
        raise FileNotFoundError(f"Case file not found: {case_file}")
    return case_file

def run_test(prolog, case_id):
    """Run a single test case and return the result."""
    try:
        # Consult the case file
        janus.consult(str("cases" / f"{case_id}.pl"))
        # Implicitly runs the embedded test directive and halts.
        return case_id, True
    except Exception as e:
        logger.error(f"Error testing case {case_id}: {e}")
        return case_id, False

def main():
    # Create results directory if it doesn't exist
    results_dir = PROJECT_ROOT / "results"
    results_dir.mkdir(exist_ok=True)
    
    # Get test case IDs
    try:
        test_cases = get_test_cases()
    except FileNotFoundError as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

    # Step 1: set working directory in Prolog
    janus.query_once(f"working_directory(_, '{SARA_V3_DIR}')")
    # Step 2: consult init.pl
    init_path = SARA_V3_DIR / "statutes" / "prolog" / "init.pl"
    janus.consult(str(init_path))

    # Step 3: Prepare counters
    total = len(test_cases)
    true_count = 0
    results = []
    missing_cases = []

    for case_id in test_cases:
        try:
            case_file = get_case_file(case_id)
            # Step 4: consult case file
            janus.consult(str(case_file))
            # Step 5: query the test goal 'goal'
            # extract & run the test directive
            content   = case_file.read_text()
            test_blk  = re.split(r'%\s*Test', content, 1)[1]
            find_goal = re.search(r'goal\s*:-\s*(.*?)\s*\.', test_blk, re.DOTALL)
            if find_goal:
                result = janus.query_once("goal")
            else:
                m         = re.search(r':-\s*(.*?)\s*\.', test_blk, re.DOTALL)
                goal     = m.group(1)
                result   = janus.query_once(goal)
                passed   = (result == "true" or 
                            (isinstance(result, dict) and result.get("truth", False)))
            results.append((case_id, passed))
            if passed:
                true_count += 1
        except FileNotFoundError:
            missing_cases.append(case_id)
        except Exception as e:
            logger.error(f"Error processing case {case_id}: {e}")
            results.append((case_id, False))
            
    accuracy = true_count / total if total else 0
    
    # Prepare log content
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_content = f"Test Run: {timestamp}\n"
    log_content += f"Total cases in test split: {len(test_cases)}\n"
    log_content += f"Cases found and tested: {len(results)}\n"
    if missing_cases:
        log_content += f"Missing cases: {len(missing_cases)}\n"
    log_content += f"True cases: {true_count}\n"
    log_content += f"Accuracy: {accuracy:.2%}\n\n"
    
    if missing_cases:
        log_content += "Missing Cases:\n"
        log_content += "-" * 50 + "\n"
        for case_id in missing_cases:
            log_content += f"{case_id}\n"
        log_content += "\n"
    
    log_content += "Detailed Results:\n"
    log_content += "-" * 50 + "\n"
    for case_id, result in results:
        log_content += f"{case_id}: {'True' if result else 'False'}\n"
    
    # Save results to file
    output_file = results_dir / 'test_split_result.txt'
    with open(output_file, 'w') as f:
        f.write(log_content)
    
    print(f"Results have been saved to {output_file}")
    print(f"Accuracy: {accuracy:.2%}")
    if missing_cases:
        print(f"Warning: {len(missing_cases)} cases were missing from the cases directory")

if __name__ == "__main__":
    main()