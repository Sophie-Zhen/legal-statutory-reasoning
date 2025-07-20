#!/usr/bin/env python3
"""
Method 2 Codebase Accuracy Runner
Tests accuracy using the original Method 2 approach with tests.pl containing all answer/2 predicates.
Uses the shared accuracy engine for consistent testing logic.
"""

import os
from pathlib import Path
from typing import List, Dict
from shared_accuracy_engine import AccuracyTestEngine


class Method2CodebaseAccuracyRunner:
    """
    Runner for testing Method 2 codebase accuracy using tests.pl approach
    """
    
    def __init__(self, base_dir: Path = None):
        """
        Initialize the Method 2 codebase accuracy runner
        
        Args:
            base_dir: Base directory for the pipeline (defaults to parent of script)
        """
        if base_dir is None:
            self.base_dir = Path(__file__).parent.parent
        else:
            self.base_dir = Path(base_dir)
        
        self.prolog_dir = self.base_dir / "prolog_codebase"
        self.results_dir = self.base_dir / "results"/"acc_analysis"
        
        # Create results directory if it doesn't exist
        self.results_dir.mkdir(exist_ok=True)
        
        # Initialize accuracy engine
        self.accuracy_engine = AccuracyTestEngine(working_dir=self.prolog_dir)
        
        # Hardcoded list of Method 2 expected cases
        self.expected_cases = [
            # True/False cases
            's152_c_1_E_pos', 's152_d_2_F_pos', 's1_a_1_iii_neg', 's1_a_1_pos', 
            's1_b_iii_neg', 's1_c_i_neg', 's1_c_iv_pos', 's1_d_iv_neg', 
            's2_a_2_B_pos', 's3306_a_1_neg', 's3306_b_10_A_neg', 's3306_b_7_neg', 
            's3306_b_pos', 's3306_c_5_pos', 's63_c_2_B_neg', 's63_c_3_pos', 
            's68_b_1_A_neg', 's7703_b_1_pos',
            # Tax calculation cases
            'tax_case_13', 'tax_case_26', 'tax_case_40', 'tax_case_61', 
            'tax_case_63', 'tax_case_70', 'tax_case_79', 'tax_case_89'
        ]
    
    def check_required_files(self) -> tuple[bool, List[str]]:
        """
        Check if all required files exist for running tests
        
        Returns:
            Tuple of (all_present, missing_files)
        """
        required_files = [
            "tests.pl",
            "helpers.pl", 
            "knowledge_base.pl"
        ]
        
        section_files = [
            "section1.pl", "section2.pl", "section63.pl", 
            "section68.pl", "section151.pl", "section152.pl",
            "section3301.pl", "section3306.pl", "section7703.pl"
        ]
        
        missing_files = []
        
        # Check required files
        for filename in required_files:
            filepath = self.prolog_dir / filename
            if not filepath.exists():
                missing_files.append(filename)
        
        # Check if at least some section files exist
        existing_sections = [f for f in section_files if (self.prolog_dir / f).exists()]
        if len(existing_sections) < 3:
            missing_files.append(f"insufficient_section_files ({len(existing_sections)}/9)")
        
        return len(missing_files) == 0, missing_files
    
    def test_single_case(self, case_id: str) -> Dict:
        """
        Test a single case using the Method 2 codebase approach
        
        Args:
            case_id: Case identifier to test
            
        Returns:
            Test result dictionary
        """
        # Create SWI-Prolog query for Method 2 codebase
        query = f"consult(tests), (answer({case_id}, Result) -> (write('RESULT:'), write(Result)) ; write('NO_RESULT')), halt."
        
        # Test using shared accuracy engine
        success, actual_result, expected_result = self.accuracy_engine.test_single_case_with_query(
            case_id, query, working_dir=self.prolog_dir
        )
        
        # For tax cases, try to get expected value from tests.pl
        if case_id.startswith('tax_case_') and expected_result == "numeric_result":
            tests_pl_path = self.prolog_dir / "tests.pl"
            if tests_pl_path.exists():
                expected_value = self.accuracy_engine.find_expected_tax_value_from_tests_pl(
                    case_id, tests_pl_path
                )
                if expected_value is not None:
                    # Re-analyze with the expected value
                    try:
                        actual_numeric = float(actual_result)
                        success = abs(actual_numeric - expected_value) < 0.01
                        expected_result = str(expected_value)
                    except ValueError:
                        success = False
        
        return {
            'case_id': case_id,
            'success': success,
            'actual_result': actual_result,
            'expected_result': expected_result,
            'approach': 'method2_codebase'
        }
    
    def run_accuracy_test(self) -> Dict:
        """
        Run accuracy test on all Method 2 expected cases
        
        Returns:
            Comprehensive test results
        """
        print("🧪 Running Method 2 Codebase Accuracy Test...")
        print(f"📁 Working directory: {self.prolog_dir}")
        print(f"📋 Testing {len(self.expected_cases)} cases")
        
        # Check if required files exist
        all_present, missing_files = self.check_required_files()
        if not all_present:
            return {
                'error': f"Missing required files: {missing_files}",
                'approach': 'method2_codebase',
                'results': []
            }
        
        # Change to prolog directory for execution
        original_cwd = os.getcwd()
        
        try:
            os.chdir(self.prolog_dir)
            
            results = []
            
            for i, case_id in enumerate(self.expected_cases, 1):
                print(f"🔍 Testing case {i}/{len(self.expected_cases)}: {case_id}")
                
                try:
                    result = self.test_single_case(case_id)
                    results.append(result)
                    
                    status = "✅ PASS" if result['success'] else "❌ FAIL"
                    print(f"   {status} (result: {result['actual_result']}, expected: {result['expected_result']})")
                    
                except Exception as e:
                    print(f"   💥 ERROR: {str(e)}")
                    results.append({
                        'case_id': case_id,
                        'success': False,
                        'actual_result': f"ERROR: {str(e)}",
                        'expected_result': "N/A",
                        'approach': 'method2_codebase'
                    })
            
            # Generate accuracy report
            accuracy_report = self.accuracy_engine.generate_accuracy_report(results)
            
            print(f"\n📊 Method 2 Codebase Test Complete:")
            print(f"   Total cases: {accuracy_report['overall']['total_cases']}")
            print(f"   Passed: {accuracy_report['overall']['passed_cases']}")
            print(f"   Success rate: {accuracy_report['overall']['success_rate']:.1f}%")
            
            return {
                'approach': 'method2_codebase',
                'results': results,
                'accuracy_report': accuracy_report,
                'test_info': {
                    'working_directory': str(self.prolog_dir),
                    'expected_cases_count': len(self.expected_cases),
                    'files_checked': all_present
                }
            }
            
        finally:
            # Restore original working directory
            os.chdir(original_cwd)
    
    def save_results(self, test_results: Dict):
        """
        Save test results to files
        
        Args:
            test_results: Results from run_accuracy_test()
        """
        if 'error' in test_results:
            print(f"❌ Cannot save results due to error: {test_results['error']}")
            return
        
        # Save using shared accuracy engine
        accuracy_report = test_results['accuracy_report']
        output_file = self.results_dir / "method2_codebase_accuracy"
        
        self.accuracy_engine.save_report(
            accuracy_report, 
            output_file, 
            approach_name="Method 2 Codebase"
        )
        
        # Also save detailed results
        import json
        detailed_file = self.results_dir / "method2_codebase_detailed_results.json"
        with open(detailed_file, 'w') as f:
            json.dump(test_results, f, indent=2)
        
        print(f"   Detailed: {detailed_file}")


def main():
    """Main entry point for Method 2 codebase accuracy testing"""
    print("🎯 Method 2 Codebase Accuracy Runner")
    print("=" * 60)
    
    runner = Method2CodebaseAccuracyRunner()
    
    # Run accuracy test
    results = runner.run_accuracy_test()
    
    # Save results
    runner.save_results(results)
    
    print("\n✅ Method 2 codebase accuracy testing complete!")


if __name__ == "__main__":
    main() 