"""
Integration tests for SARA dataset using Prolog.
Handles loading cases from train split, running tests, and computing metrics.
"""

import logging
import sys
from pathlib import Path
from typing import Dict
from .prolog_utils import (
    setup_logging, translate_and_query,
    REPO_ROOT, DATA_ROOT, CASES_DIR, SPLITS_DIR
)

logger = logging.getLogger(__name__)

def run_all_cases() -> Dict:
    """Run all cases from train split and compute accuracy metrics.
    
    Args:
        threshold: Minimum accuracy required to pass (default: 1.0)
        
    Returns:
        Dictionary containing test results and metrics
    """
    # Load train split
    train_file = SPLITS_DIR / "train"
    if not train_file.exists():
        logger.error(f"Train split file not found: {train_file}")
        sys.exit(1)
    with open(train_file) as f:
        train_cases = [line.strip() for line in f if line.strip()]
    
    # Process cases and run tests
    total = len(train_cases)
    passed = 0
    failed_cases = []
    
    for case_id in train_cases:
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
        else:
            failed_cases.append(case_id)
    
    accuracy = passed / total if total > 0 else 0
    
    return {
        "total": total,
        "passed": passed,
        "accuracy": accuracy,
        "failed_cases": failed_cases
    }

def main():
    """Main entry point for running SARA tests."""
    # Setup logging
    setup_logging()
    
    # Run tests
    results = run_all_cases()
    
    logger.info("Test Results:")
    logger.info(f"Total cases: {results['total']}")
    logger.info(f"Passed: {results['passed']}")
    logger.info(f"Accuracy: {results['accuracy']:.2%}")

    if results['failed_cases']:
        logger.warning("Failed cases:")
        for case_id in results['failed_cases']:
            logger.warning(f"- {case_id}")
            
if __name__ == "__main__":
    main()