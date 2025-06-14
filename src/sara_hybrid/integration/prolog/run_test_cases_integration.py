"""
Test runner for all test split cases in the SARA dataset.
This script runs tests on all cases in the test split and reports results.
Results are saved to a CSV file with detailed statistics.
"""

import logging
import sys
import csv
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from .prolog_utils import (
    setup_logging, translate_and_query,
    REPO_ROOT, DATA_ROOT, CASES_DIR, SPLITS_DIR
)

logger = logging.getLogger(__name__)

def run_test_cases() -> Dict:
    """Run all cases from test split and compute accuracy metrics.
    
    Returns:
        Dictionary containing test results and metrics
    """
    # Load test split
    test_file = SPLITS_DIR / "test"
    if not test_file.exists():
        logger.error(f"Test split file not found: {test_file}")
        sys.exit(1)
    with open(test_file) as f:
        test_cases = [line.strip() for line in f if line.strip()]
    
    # Process cases and run tests
    total = len(test_cases)
    passed = 0
    failed_cases = []
    case_results = []  # Store detailed results for each case
    
    for case_id in test_cases:
        case_file = CASES_DIR / f"{case_id}.pl"
        if not case_file.exists():
            logger.warning(f"Case file not found: {case_file}")
            continue
            
        logger.info(f"\n{'='*50}\nProcessing case: {case_id}\n{'='*50}")
        
        # Load and process case file
        with open(case_file) as f:
            content = f.read()
            
        # Remove text and question sections
        content = content.split("% Facts")[-1]
        
        # Split into facts and test sections
        sections = content.split("% Test")
        if len(sections) != 2:
            logger.error(f"Invalid case file format in {case_file}")
            continue
            
        facts = sections[0].strip()
        test = sections[1].strip()
        
        # Run the test
        case = {
            "id": case_id,
            "facts": facts,
            "test": test
        }
        
        result = translate_and_query(case)
        if result:
            passed += 1
            status = "PASS"
        else:
            failed_cases.append(case_id)
            status = "FAIL"
            
        # Store detailed result
        case_results.append({
            "case_id": case_id,
            "status": status,
            "timestamp": datetime.now().isoformat()
        })
    
    accuracy = passed / total if total > 0 else 0
    
    return {
        "total": total,
        "passed": passed,
        "accuracy": accuracy,
        "failed_cases": failed_cases,
        "case_results": case_results
    }

def save_results(results: Dict, output_dir: Path = None) -> Path:
    """Save test results to CSV files.
    
    Args:
        results: Dictionary containing test results
        output_dir: Directory to save results (defaults to REPO_ROOT/results)
        
    Returns:
        Path to the results directory
    """
    if output_dir is None:
        output_dir = REPO_ROOT / "results"
    output_dir.mkdir(exist_ok=True)
    
    # Generate timestamp for unique filenames
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save detailed case results
    case_results_file = output_dir / f"case_results_{timestamp}.csv"
    with open(case_results_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["case_id", "status", "timestamp"])
        writer.writeheader()
        writer.writerows(results["case_results"])
    
    # Save summary statistics
    summary_file = output_dir / f"test_summary_{timestamp}.txt"
    with open(summary_file, 'w') as f:
        f.write("Test Results Summary\n")
        f.write("===================\n\n")
        f.write(f"Total cases: {results['total']}\n")
        f.write(f"Passed: {results['passed']}\n")
        f.write(f"Accuracy: {results['accuracy']:.2%}\n\n")
        
        if results['failed_cases']:
            f.write("Failed cases:\n")
            for case_id in results['failed_cases']:
                f.write(f"- {case_id}\n")
    
    return output_dir

def main():
    """Main entry point for running all test cases."""
    # Setup logging
    log_file = setup_logging()
    logger.info("Starting SARA test run")
    
    # Run tests
    results = run_test_cases()
    
    # Save results
    output_dir = save_results(results)
    
    # Print summary
    logger.info("\nTest Results Summary:")
    logger.info(f"Total cases: {results['total']}")
    logger.info(f"Passed: {results['passed']}")
    logger.info(f"Accuracy: {results['accuracy']:.2%}")
    
    if results['failed_cases']:
        logger.info("\nFailed cases:")
        for case_id in results['failed_cases']:
            logger.info(f"- {case_id}")
    
    logger.info(f"\nResults saved to: {output_dir}")
    
    # Exit with appropriate status code
    sys.exit(0 if results['passed'] == results['total'] else 1)

if __name__ == "__main__":
    main() 