#!/usr/bin/env python3
"""
Stage 3 Individual Accuracy Runner
Tests accuracy using the Stage 3 approach with individual Prolog files.
Loads cases from generated Prolog files and tests them individually.
Uses the shared accuracy engine for consistent testing logic.
"""

import os
import subprocess
from pathlib import Path
from typing import List, Dict, Optional
from shared_accuracy_engine import AccuracyTestEngine


class Stage3IndividualAccuracyRunner:
    """
    Runner for testing Stage 3 individual file accuracy
    """
    
    def __init__(self, base_dir: Path = None):
        """
        Initialize the Stage 3 individual accuracy runner
        
        Args:
            base_dir: Base directory for the pipeline (defaults to parent of script)
        """
        if base_dir is None:
            self.base_dir = Path(__file__).parent.parent
        else:
            self.base_dir = Path(base_dir)
        
        self.prolog_codebase_dir = self.base_dir / "prolog_codebase"
        self.stage3_prolog_dir = self.base_dir / "results" / "stage3_test_split" / "prolog"
        self.results_dir = self.base_dir / "results" / "acc_analysis"
        
        # Create results directory if it doesn't exist
        self.results_dir.mkdir(parents=True, exist_ok=True)
        
        # Initialize accuracy engine
        self.accuracy_engine = AccuracyTestEngine()
        
        # Cases will be discovered dynamically
        self.discovered_cases = []
    
    def discover_cases(self) -> List[str]:
        """
        Discover cases from generated Stage 3 Prolog files
        
        Returns:
            List of case IDs found in the prolog directory
        """
        if not self.stage3_prolog_dir.exists():
            print(f"❌ Stage 3 prolog directory not found: {self.stage3_prolog_dir}")
            return []
        
        # Find all .pl files
        prolog_files = list(self.stage3_prolog_dir.glob("*.pl"))
        case_ids = [f.stem for f in prolog_files if f.stem != "temp"]
        
        self.discovered_cases = sorted(case_ids)
        
        print(f"🔍 Discovered {len(self.discovered_cases)} cases in {self.stage3_prolog_dir}")
        
        return self.discovered_cases
    
    def check_required_files(self) -> tuple[bool, List[str]]:
        """
        Check if required files exist for Stage 3 testing
        
        Returns:
            Tuple of (all_present, missing_files)
        """
        missing_files = []
        
        # Check if prolog codebase directory exists
        if not self.prolog_codebase_dir.exists():
            missing_files.append("prolog_codebase directory")
        
        # Check if stage3 prolog directory exists
        if not self.stage3_prolog_dir.exists():
            missing_files.append("stage3_test_split/prolog directory")
        
        # Check some essential prolog codebase files
        essential_files = ["helpers.pl", "knowledge_base.pl"]
        for filename in essential_files:
            filepath = self.prolog_codebase_dir / filename
            if not filepath.exists():
                missing_files.append(f"prolog_codebase/{filename}")
        
        return len(missing_files) == 0, missing_files
    
    def test_single_case(self, case_id: str) -> Dict:
        """
        Test a single case using the Stage 3 individual file approach
        
        Args:
            case_id: Case identifier to test
            
        Returns:
            Test result dictionary
        """
        prolog_file = self.stage3_prolog_dir / f"{case_id}.pl"
        
        if not prolog_file.exists():
            return {
                'case_id': case_id,
                'success': False,
                'actual_result': "FILE_NOT_FOUND",
                'expected_result': "N/A",
                'approach': 'stage3_individual'
            }
        
        # Create temporary consultation file (same approach as stage3_pipeline.py)
        temp_file = self.stage3_prolog_dir / f"temp_{case_id}.pl"
        
        try:
            with open(temp_file, 'w') as f:
                # Add path to Method 2 codebase
                f.write(f":- add_to_path('{self.prolog_codebase_dir}').\n")
                
                # Load the generated case file
                f.write(f":- consult('{prolog_file}').\n")
                
                # Query the answer predicate
                f.write(f":- answer('{case_id}', Result), write('RESULT: '), write(Result), nl, halt.\n")
                f.write(f":- write('ERROR: Failed to get result'), nl, halt(1).\n")
            
            # Execute with SWI-Prolog
            cmd = ['swipl', '-q', '-t', 'halt', '-s', str(temp_file)]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=str(self.prolog_codebase_dir)
            )
            
            # Parse result
            if result.returncode == 0:
                output = result.stdout.strip()
                if 'RESULT:' in output:
                    actual_result = output.split('RESULT:')[1].strip()
                    
                    # Use shared accuracy engine to compare with expected
                    success, _, expected_result = self.accuracy_engine.compare_with_expected(
                        case_id, actual_result
                    )
                    
                    return {
                        'case_id': case_id,
                        'success': success,
                        'actual_result': actual_result,
                        'expected_result': expected_result,
                        'approach': 'stage3_individual'
                    }
                else:
                    return {
                        'case_id': case_id,
                        'success': False,
                        'actual_result': "NO_RESULT",
                        'expected_result': "N/A",
                        'approach': 'stage3_individual'
                    }
            else:
                return {
                    'case_id': case_id,
                    'success': False,
                    'actual_result': f"PROLOG_ERROR: {result.stderr.strip() if result.stderr else 'Unknown error'}",
                    'expected_result': "N/A",
                    'approach': 'stage3_individual'
                }
                
        except subprocess.TimeoutExpired:
            return {
                'case_id': case_id,
                'success': False,
                'actual_result': "TIMEOUT",
                'expected_result': "N/A",
                'approach': 'stage3_individual'
            }
        except Exception as e:
            return {
                'case_id': case_id,
                'success': False,
                'actual_result': f"ERROR: {str(e)}",
                'expected_result': "N/A",
                'approach': 'stage3_individual'
            }
        finally:
            # Clean up temp file
            if temp_file.exists():
                temp_file.unlink()
    
    def run_accuracy_test(self, max_cases: Optional[int] = None) -> Dict:
        """
        Run accuracy test on Stage 3 individual cases
        
        Args:
            max_cases: Maximum number of cases to test (None for all)
            
        Returns:
            Comprehensive test results
        """
        print("🧪 Running Stage 3 Individual Accuracy Test...")
        print(f"📁 Prolog codebase: {self.prolog_codebase_dir}")
        print(f"📁 Stage 3 prolog files: {self.stage3_prolog_dir}")
        
        # Check if required files exist
        all_present, missing_files = self.check_required_files()
        if not all_present:
            return {
                'error': f"Missing required files: {missing_files}",
                'approach': 'stage3_individual',
                'results': []
            }
        
        # Discover cases
        cases = self.discover_cases()
        if not cases:
            return {
                'error': "No cases found in Stage 3 prolog directory",
                'approach': 'stage3_individual',
                'results': []
            }
        
        # Limit cases if requested
        if max_cases is not None:
            cases = cases[:max_cases]
            print(f"📋 Testing first {len(cases)} cases (limited from {len(self.discovered_cases)})")
        else:
            print(f"📋 Testing all {len(cases)} cases")
        
        results = []
        
        for i, case_id in enumerate(cases, 1):
            print(f"🔍 Testing case {i}/{len(cases)}: {case_id}")
            
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
                    'approach': 'stage3_individual'
                })
        
        # Generate accuracy report
        accuracy_report = self.accuracy_engine.generate_accuracy_report(results)
        
        print(f"\n📊 Stage 3 Individual Test Complete:")
        print(f"   Total cases: {accuracy_report['overall']['total_cases']}")
        print(f"   Passed: {accuracy_report['overall']['passed_cases']}")
        print(f"   Success rate: {accuracy_report['overall']['success_rate']:.1f}%")
        
        return {
            'approach': 'stage3_individual',
            'results': results,
            'accuracy_report': accuracy_report,
            'test_info': {
                'prolog_codebase_dir': str(self.prolog_codebase_dir),
                'stage3_prolog_dir': str(self.stage3_prolog_dir),
                'total_discovered_cases': len(self.discovered_cases),
                'tested_cases_count': len(cases),
                'files_checked': all_present
            }
        }
    
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
        output_file = self.results_dir / "stage3_individual_accuracy"
        
        self.accuracy_engine.save_report(
            accuracy_report, 
            output_file, 
            approach_name="Stage 3 Individual"
        )
        
        # Also save detailed results
        import json
        detailed_file = self.results_dir / "stage3_individual_detailed_results.json"
        with open(detailed_file, 'w') as f:
            json.dump(test_results, f, indent=2)
        
        print(f"   Detailed: {detailed_file}")


def main():
    """Main entry point for Stage 3 individual accuracy testing"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Stage 3 Individual Accuracy Runner")
    parser.add_argument('--max-cases', type=int, help='Maximum number of cases to test')
    args = parser.parse_args()
    
    print("🎯 Stage 3 Individual Accuracy Runner")
    print("=" * 60)
    
    runner = Stage3IndividualAccuracyRunner()
    
    # Run accuracy test
    results = runner.run_accuracy_test(max_cases=args.max_cases)
    
    # Save results
    runner.save_results(results)
    
    print("\n✅ Stage 3 individual accuracy testing complete!")


if __name__ == "__main__":
    main() 