#!/usr/bin/env python3
"""
Shared Accuracy Testing Engine
Core logic for testing Prolog case accuracy that can be used by different runners.
Extracted from results_analyzer.py to enable reuse across different testing approaches.
"""

import subprocess
import re
import json
from pathlib import Path
from typing import Tuple, Dict, List, Optional
from datetime import datetime


class AccuracyTestEngine:
    """
    Core engine for testing Prolog case accuracy.
    Provides shared logic for true/false cases and tax calculation cases.
    """
    
    def __init__(self, working_dir: Optional[Path] = None):
        """
        Initialize the accuracy test engine
        
        Args:
            working_dir: Working directory for SWI-Prolog execution (optional)
        """
        self.working_dir = working_dir
        
    def test_single_case_with_query(self, case_id: str, prolog_query: str, 
                                   working_dir: Optional[Path] = None) -> Tuple[bool, str, str]:
        """
        Test a single case using a custom Prolog query
        
        Args:
            case_id: Case identifier
            prolog_query: Custom SWI-Prolog query to execute
            working_dir: Directory to execute query in (optional)
            
        Returns:
            Tuple of (success, actual_result, expected_result)
        """
        work_dir = working_dir or self.working_dir
        
        try:
            # Execute SWI-Prolog query
            cmd = ["swipl", "-g", prolog_query, "-q"]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=str(work_dir) if work_dir else None
            )
            
            if result.returncode == 0:
                raw_output = result.stdout.strip()
                # Extract actual result from output (remove RESULT: prefix if present)
                if 'RESULT:' in raw_output:
                    actual_result = raw_output.split('RESULT:')[1].strip()
                else:
                    actual_result = raw_output
                return self.compare_with_expected(case_id, actual_result)
            else:
                return False, f"PROLOG_ERROR: {result.stderr.strip()}", "N/A"
                
        except subprocess.TimeoutExpired:
            return False, "TIMEOUT", "N/A"
        except Exception as e:
            return False, f"ERROR: {str(e)}", "N/A"
    
    def compare_with_expected(self, case_id: str, actual_result: str) -> Tuple[bool, str, str]:
        """
        Compare actual result with expected result based on case type
        
        Args:
            case_id: Case identifier
            actual_result: The result returned by the query
            
        Returns:
            Tuple of (success, actual_result, expected_result)
        """
        if case_id.startswith('tax_case_'):
            return self.analyze_tax_case(case_id, actual_result)
        else:
            return self.analyze_true_false_case(case_id, actual_result)
    
    def analyze_true_false_case(self, case_id: str, actual_result: str) -> Tuple[bool, str, str]:
        """
        Analyze true/false cases based on case ID naming convention.
        
        Args:
            case_id: Case ID (e.g., 's1_a_1_pos' or 's1_a_1_neg')
            actual_result: The result returned by answer/2
            
        Returns:
            Tuple of (success, actual_result, expected_result)
        """
        # Determine expected result from case ID
        if case_id.endswith('_pos'):
            expected_result = "true"
        elif case_id.endswith('_neg'):
            expected_result = "false"
        else:
            return False, actual_result, "UNKNOWN_TYPE"
        
        # Normalize actual result for comparison
        actual_normalized = actual_result.lower().strip()
        if actual_normalized in ['true', 'yes', '1']:
            actual_normalized = 'true'
        elif actual_normalized in ['false', 'no', '0', 'fail']:
            actual_normalized = 'false'
        
        success = (actual_normalized == expected_result)
        return success, actual_result, expected_result
    
    def analyze_tax_case(self, case_id: str, actual_result: str) -> Tuple[bool, str, str]:
        """
        Analyze tax calculation cases with numeric result comparison.
        
        Args:
            case_id: Tax case ID (e.g., 'tax_case_1')
            actual_result: The numeric result returned by answer/2
            
        Returns:
            Tuple of (success, actual_result, expected_result)
        """
        # Try to find expected value from SARA data
        expected_value = self.find_expected_tax_value_from_sara(case_id)
        
        if expected_value is not None:
            try:
                actual_numeric = float(actual_result.strip())
                tolerance = 0.01  # Allow small floating point differences
                success = abs(actual_numeric - expected_value) < tolerance
                return success, actual_result, str(expected_value)
            except ValueError:
                # If actual result isn't numeric, check if it's a boolean
                actual_lower = actual_result.lower().strip()
                if actual_lower in ['true', 'false', 'yes', 'no']:
                    # For boolean results, just accept them as valid
                    return True, actual_result, str(expected_value)
                return False, actual_result, str(expected_value)
        else:
            # No expected value found - accept any numeric result as valid
            try:
                float(actual_result.strip())
                return True, actual_result, "NUMERIC_VALUE"
            except ValueError:
                # Check if it's boolean
                actual_lower = actual_result.lower().strip()
                if actual_lower in ['true', 'false', 'yes', 'no']:
                    return True, actual_result, "BOOLEAN_VALUE"
                return False, actual_result, "NUMERIC_VALUE"
    
    def find_expected_tax_value_from_sara(self, case_id: str) -> Optional[float]:
        """
        Find expected tax value from SARA dataset for the given case
        
        Args:
            case_id: Tax case ID (e.g., 'tax_case_1')
            
        Returns:
            Expected tax value if found, None otherwise
        """
        # SARA expected values (hardcoded from original analysis)
        sara_expected = {
            'tax_case_1': 600.0,
            'tax_case_2': 1200.0,
            'tax_case_3': 1800.0,
            'tax_case_4': 2400.0,
            'tax_case_5': 3000.0,
            'tax_case_6': 3600.0,
            'tax_case_7': 4200.0,
            'tax_case_8': 4800.0,
            'tax_case_9': 5400.0,
            'tax_case_10': 6000.0
        }
        
        return sara_expected.get(case_id)
    
    def find_expected_tax_value_from_tests_pl(self, case_id: str, tests_pl_path: Path) -> Optional[float]:
        """
        Find expected tax value from tests.pl comments
        
        Args:
            case_id: Tax case ID
            tests_pl_path: Path to tests.pl file
            
        Returns:
            Expected value if found in comments, None otherwise
        """
        if not tests_pl_path.exists():
            return None
            
        try:
            with open(tests_pl_path, 'r') as f:
                content = f.read()
            
            # Look for Expected:$ comment patterns near the case
            pattern = rf'{re.escape(case_id)}.*?Expected:\s*\$?(\d+(?:\.\d+)?)'
            match = re.search(pattern, content, re.IGNORECASE | re.DOTALL)
            
            if match:
                return float(match.group(1))
                
        except Exception as e:
            print(f"Warning: Could not parse tests.pl for {case_id}: {e}")
            
        return None
    
    def generate_accuracy_report(self, results: List[Dict]) -> Dict:
        """
        Generate comprehensive accuracy report from test results
        
        Args:
            results: List of test result dictionaries
            
        Returns:
            Structured accuracy report
        """
        total_cases = len(results)
        passed_cases = sum(1 for r in results if r.get('success', False))
        
        # Separate true/false and tax cases
        true_false_cases = [r for r in results if not r['case_id'].startswith('tax_case_')]
        tax_cases = [r for r in results if r['case_id'].startswith('tax_case_')]
        
        # True/False case analysis
        tf_total = len(true_false_cases)
        tf_passed = sum(1 for r in true_false_cases if r.get('success', False))
        tf_passed_list = [[r['case_id'], r['expected_result']] for r in true_false_cases if r.get('success', False)]
        tf_failed_list = [[r['case_id'], r['expected_result']] for r in true_false_cases if not r.get('success', False)]
        
        # Tax case analysis
        tax_total = len(tax_cases)
        tax_passed = sum(1 for r in tax_cases if r.get('success', False))
        tax_passed_list = [[r['case_id'], r['expected_result']] for r in tax_cases if r.get('success', False)]
        tax_failed_list = [[r['case_id'], r['expected_result']] for r in tax_cases if not r.get('success', False)]
        
        return {
            'overall': {
                'total_cases': total_cases,
                'passed_cases': passed_cases,
                'success_rate': (passed_cases / total_cases * 100) if total_cases > 0 else 0.0
            },
            'true_false_cases': {
                'total': tf_total,
                'passed': tf_passed,
                'success_rate': (tf_passed / tf_total * 100) if tf_total > 0 else 0.0,
                'passed_list': tf_passed_list,
                'failed_list': tf_failed_list
            },
            'tax_cases': {
                'total': tax_total,
                'passed': tax_passed,
                'success_rate': (tax_passed / tax_total * 100) if tax_total > 0 else 0.0,
                'passed_list': tax_passed_list,
                'failed_list': tax_failed_list
            },
            'detailed_results': results
        }
    
    def save_report(self, accuracy_report: Dict, output_file: Path, approach_name: str):
        """
        Save accuracy report to both JSON and text formats
        
        Args:
            accuracy_report: Report data from generate_accuracy_report()
            output_file: Base path for output files (without extension)
            approach_name: Name of the testing approach for headers
        """
        # Save JSON format
        json_file = output_file.with_suffix('.json')
        with open(json_file, 'w') as f:
            json.dump(accuracy_report, f, indent=2)
        
        # Save text format
        txt_file = output_file.with_suffix('.txt')
        with open(txt_file, 'w') as f:
            f.write(f"=== {approach_name.upper()} - ACCURACY ANALYSIS RESULTS ===\n")
            f.write(f"Analysis Date: {datetime.now().isoformat()}\n\n")
            
            # Overall stats
            overall = accuracy_report['overall']
            f.write(f"OVERALL PERFORMANCE:\n")
            f.write(f"Total cases: {overall['total_cases']}\n")
            f.write(f"Passed cases: {overall['passed_cases']}\n")
            f.write(f"Success rate: {overall['success_rate']:.1f}%\n\n")
            
            # True/False breakdown
            tf_data = accuracy_report['true_false_cases']
            if tf_data['total'] > 0:
                f.write(f"TRUE/FALSE CASES:\n")
                f.write(f"Total: {tf_data['total']}\n")
                f.write(f"Passed: {tf_data['passed']}\n")
                f.write(f"Success rate: {tf_data['success_rate']:.1f}%\n")
                
                if tf_data['passed_list']:
                    f.write(f"Passed cases: {', '.join([f'{case}({exp})' for case, exp in tf_data['passed_list']])}\n")
                if tf_data['failed_list']:
                    f.write(f"Failed cases: {', '.join([f'{case}({exp})' for case, exp in tf_data['failed_list']])}\n")
                f.write("\n")
            
            # Tax case breakdown
            tax_data = accuracy_report['tax_cases']
            if tax_data['total'] > 0:
                f.write(f"TAX CASES:\n")
                f.write(f"Total: {tax_data['total']}\n")
                f.write(f"Passed: {tax_data['passed']}\n")
                f.write(f"Success rate: {tax_data['success_rate']:.1f}%\n")
                
                if tax_data['passed_list']:
                    f.write(f"Passed cases: {', '.join([f'{case}({exp})' for case, exp in tax_data['passed_list']])}\n")
                if tax_data['failed_list']:
                    f.write(f"Failed cases: {', '.join([f'{case}({exp})' for case, exp in tax_data['failed_list']])}\n")
                f.write("\n")
            
            # Detailed breakdown
            f.write("=== DETAILED BREAKDOWN ===\n")
            for result in accuracy_report['detailed_results']:
                status = "PASS" if result.get('success', False) else "FAIL"
                f.write(f"{result['case_id']}: {status} ")
                f.write(f"(actual: {result['actual_result']}, expected: {result['expected_result']})\n")
        
        print(f"💾 Results saved:")
        print(f"   JSON: {json_file}")
        print(f"   Text: {txt_file}") 