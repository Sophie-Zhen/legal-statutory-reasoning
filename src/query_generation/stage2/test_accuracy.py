#!/usr/bin/env python3
"""
This load all the predicates to test for accuracy
"""

import subprocess
import json
import os
from pathlib import Path
from typing import Dict, Optional
import uuid

class AccuracyTester:
    def __init__(self, statutes_dir: str, cases_dir: str):
        self.statutes_dir = Path(statutes_dir)
        self.cases_dir = Path(cases_dir)
    
    def test_query(self, case_id: str, query: str, timeout: int = 10) -> Dict:
        """Test a single query with proper initialization"""
        try:
            # Get case facts
            case_file = self.cases_dir / f"{case_id}.pl"
            if not case_file.exists():
                return {
                    'case_id': case_id,
                    'success': False,
                    'error': f'Case file not found: {case_file}'
                }
            
            with open(case_file, 'r') as f:
                content = f.read()
            
            # Extract facts
            import re
            facts_match = re.search(r'%\s*Facts\s*\n(.*?)(?=\n%\s*Test)', content, re.DOTALL)
            facts = facts_match.group(1) if facts_match else ""
            
            # Extract golden test
            test_match = re.search(r'%\s*Test\s*\n(.*?)(?:\n|$)', content, re.DOTALL)
            golden_test = test_match.group(1).strip() if test_match else ""
            
            # Determine expected result
            if golden_test.startswith(':- \\+'):
                expected = 'false'
            elif golden_test.startswith(':- '):
                expected = 'true'
            else:
                expected = 'unknown'
            temp_filename = f"temp_{case_id}_{uuid.uuid4().hex[:8]}.pl"
            temp_filepath = self.statutes_dir / temp_filename
            
            try:
                with open(temp_filepath, 'w') as f:
                    # Write the test file content
                    f.write("% Temporary test file\n")
                    f.write("% Load all predicates first\n")
                    f.write(":- ['init'].\n\n")
                    
                    # Write facts WITHOUT the init directive
                    f.write("% Facts from case file\n")
                    for line in facts.strip().split('\n'):
                        # Skip the init directive line
                        if not (line.strip().startswith(":-") and "'init'" in line):
                            f.write(line + '\n')
                    f.write("\n")
                    
                    # Write the generated query
                    f.write("% Generated query\n")
                    f.write(query)
                    f.write("\n\n")
                    
                    # Test harness
                    f.write("% Test execution\n")
                    f.write("run_test :-\n")
                    f.write(f"    catch(\n")
                    f.write(f"        (answer('{case_id}', Result),\n")
                    f.write(f"         write('RESULT: '), write(Result), nl,\n")
                    f.write(f"         halt(0)),\n")
                    f.write(f"        Error,\n")
                    f.write(f"        (write('ERROR: '), write(Error), nl,\n")
                    f.write(f"         halt(1))\n")
                    f.write(f"    ).\n")
                    f.write(":- initialization(run_test).\n")
                
                # Execute with just the filename from the statutes directory
                cmd = ['swipl', '-g', 'true', '-t', 'halt(2)', temp_filename]
                
                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=timeout,
                    cwd=str(self.statutes_dir)
                )
                
                # Parse output
                output = result.stdout
                stderr = result.stderr
                
                # Check for result
                actual = None
                error_msg = None
                
                if 'RESULT: ' in output:
                    actual = output.split('RESULT: ')[1].split('\n')[0].strip()
                elif 'ERROR: ' in output:
                    error_details = output.split('ERROR: ')[1].split('\n')[0].strip()
                    # Parse the error
                    if 'existence_error(procedure,' in error_details:
                        pred_match = re.search(r'procedure,([^/)]+)/(\d+)', error_details)
                        if pred_match:
                            error_msg = f"Undefined predicate: {pred_match.group(1)}/{pred_match.group(2)}"
                        else:
                            error_msg = f"Undefined predicate in: {error_details}"
                    else:
                        error_msg = error_details
                
                # Check stderr for additional errors
                if not actual and not error_msg:
                    if "ERROR:" in stderr:
                        error_msg = "Prolog error - check stderr"
                    elif result.returncode != 0:
                        error_msg = f"Prolog exited with code {result.returncode}"
                    else:
                        error_msg = "No result produced"
                
                # Build result
                if actual is not None:
                    return {
                        'case_id': case_id,
                        'success': True,
                        'expected': expected,
                        'actual': actual,
                        'correct': actual == expected,
                        'golden_test': golden_test
                    }
                else:
                    return {
                        'case_id': case_id,
                        'success': False,
                        'error': error_msg,
                        'expected': expected,
                        'golden_test': golden_test,
                        'debug_output': output if output else None,
                        'debug_stderr': stderr if stderr else None
                    }
                
            except subprocess.TimeoutExpired:
                return {
                    'case_id': case_id,
                    'success': False,
                    'error': f'Timeout after {timeout} seconds',
                    'expected': expected,
                    'golden_test': golden_test
                }
            finally:
                # Clean up temp file
                if temp_filepath.exists():
                    temp_filepath.unlink()
                    
        except Exception as e:
            import traceback
            return {
                'case_id': case_id,
                'success': False,
                'error': f'Test error: {str(e)}',
                'traceback': traceback.format_exc()
            }
    
    def test_results_directory(self, results_dir: str, verbose: bool = False):
        """Test all queries in a results directory"""
        results_dir = Path(results_dir)
        if not results_dir.exists():
            print(f"❌ Results directory not found: {results_dir}")
            return []
        
        results = []
        
        # Get all query files
        query_files = sorted([f for f in results_dir.glob("*.pl")])
        total = len(query_files)
        
        if total == 0:
            print(f"❌ No .pl files found in {results_dir}")
            print(f"Contents: {[f.name for f in results_dir.iterdir()]}")
            return []
        
        print(f"🧪 Testing {total} queries from {results_dir}")
        print(f"📁 Working directory: {self.statutes_dir}")
        print("-" * 60)
        
        for i, query_file in enumerate(query_files, 1):
            case_id = query_file.stem
            print(f"[{i}/{total}] Testing {case_id}...", end=' ', flush=True)
            
            # Read query
            with open(query_file, 'r') as f:
                content = f.read()
                query = None
                for line in content.split('\n'):
                    if line.strip().startswith('answer('):
                        query = line.strip()
                        break
                
                if not query:
                    print("✗ NO QUERY FOUND")
                    results.append({
                        'case_id': case_id,
                        'success': False,
                        'error': 'No answer() predicate found'
                    })
                    continue
            
            # Test
            result = self.test_query(case_id, query)
            results.append(result)
            
            if result.get('success'):
                if result.get('correct'):
                    print("✓ CORRECT")
                else:
                    print(f"✗ WRONG (expected: {result.get('expected')}, got: {result.get('actual')})")
            else:
                print(f"✗ ERROR: {result.get('error')}")
                if verbose:
                    if result.get('debug_output'):
                        print(f"   Output: {result['debug_output'][:100]}...")
                    if result.get('debug_stderr'):
                        print(f"   Stderr: {result['debug_stderr'][:100]}...")
        
        # Summary
        successful = sum(1 for r in results if r.get('success'))
        correct = sum(1 for r in results if r.get('correct'))
        
        print(f"\n{'='*60}")
        print(f"📊 RESULTS:")
        print(f"Execution Success: {successful}/{total} ({successful/total*100:.1f}%)")
        print(f"Accuracy: {correct}/{total} ({correct/total*100:.1f}%)")
        
        # Error analysis
        if successful < total:
            print(f"\n📋 Error Distribution:")
            error_counts = {}
            for r in results:
                if not r.get('success'):
                    error = r.get('error', 'Unknown')
                    error_counts[error] = error_counts.get(error, 0) + 1
            
            for error, count in sorted(error_counts.items(), key=lambda x: -x[1]):
                print(f"  {error}: {count} cases")
        
        # Save results
        summary_file = results_dir / "test_results.json"
        with open(summary_file, 'w') as f:
            json.dump({
                'total': total,
                'successful': successful,
                'correct': correct,
                'execution_rate': f"{successful/total*100:.1f}%",
                'accuracy': f"{correct/total*100:.1f}%",
                'results': results
            }, f, indent=2)
        
        print(f"\n💾 Results saved to: {summary_file}")
        
        return results

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('results_dir', nargs='?', default=None,
                       help='Results directory to test')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show detailed output')
    parser.add_argument('--stage1', action='store_true', help='Test stage1_queries_generated folder')
    args = parser.parse_args()
  
    if args.stage1:
        args.results_dir = 'results/stage1_queries_generated'
    elif args.results_dir is None:
        parser.error("Either specify results_dir or use --stage1 flag")
    
    base_dir = Path("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
    tester = AccuracyTester(
        statutes_dir=base_dir / "data/sara_v3/statutes/prolog",
        cases_dir=base_dir / "data/sara_v3/cases"
    )
    
    tester.test_results_directory(args.results_dir, verbose=args.verbose)

if __name__ == "__main__":
    main()