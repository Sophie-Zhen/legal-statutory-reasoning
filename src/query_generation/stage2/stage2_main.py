#!/usr/bin/env python3
"""
stage2_main.py - Main orchestrator for Stage 2 pipeline
Converts natural language text to facts, then generates queries
"""

import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import time

try:
    from dotenv import load_dotenv
    env_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts/src/.env"
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print(f"✓ Loaded environment from {env_path}")
    else:
        print(f"⚠️ Warning: .env file not found at {env_path}")
except ImportError:
    print("⚠️ python-dotenv not installed. Install with: pip install python-dotenv")

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import Stage 2 components
try:
    from src.query_generation.stage2.fact_generator import FactGeneratorLLM
    from entity_extractor import EntityExtractor
    from fact_templates import FactTemplates
    from src.query_generation.stage2.example_selector import ExampleSelector
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Make sure all Stage 2 files are in the same directory")
    sys.exit(1)

stage1_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'stage1')
if os.path.exists(stage1_path):
    sys.path.append(stage1_path)
    print(f"✓ Added Stage 1 path: {stage1_path}")
else:
    print("⚠️ Stage 1 directory not found, importing from current directory")

try:
    from case_parser import CaseParser
    from src.query_generation.stage2.query_generator import QueryGeneratorLLM
    from test_accuracy import AccuracyTester
except ImportError as e:
    print(f"❌ Import error for Stage 1 components: {e}")
    print("Please ensure Stage 1 files are accessible")
    sys.exit(1)

class Stage2Pipeline:
    """Main pipeline for Stage 2 - Natural Language to Facts & Query"""
    
    def __init__(self, api_key: Optional[str] = None, run_name: Optional[str] = None):
        # Paths
        self.base_dir = Path("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
        self.test_cases_dir = self.base_dir / "data/sara_v3/splits/test"
        self.all_cases_dir = self.base_dir / "data/sara_v3/cases"
        self.statutes_dir = self.base_dir / "data/sara_v3/statutes/prolog"
        
        # Create results directory
        if run_name:
            self.results_dir = Path("results") / f"stage2_{run_name}"
        else:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            self.results_dir = Path("results") / f"stage2_run_{timestamp}"
        
        self.results_dir.mkdir(parents=True, exist_ok=True)
        
        # Create subdirectories
        self.facts_dir = self.results_dir / "generated_facts"
        self.queries_dir = self.results_dir / "generated_queries"
        self.facts_dir.mkdir(exist_ok=True)
        self.queries_dir.mkdir(exist_ok=True)
        
        print(f"📁 Results directory: {self.results_dir}")
        
        # Initialise components
        try:
            # Stage 2 components
            self.fact_generator = FactGeneratorLLM(api_key=api_key)
            print("✓ Fact generator initialized")
            
            self.entity_extractor = EntityExtractor()
            print("✓ Entity extractor initialized")
            
            self.fact_templates = FactTemplates()
            print("✓ Fact templates loaded")
            
            # Stage 1 components (reuse)
            self.parser = CaseParser(self.all_cases_dir)
            print("✓ Case parser initialized")
            
            self.query_generator = QueryGeneratorLLM(api_key=api_key)
            print("✓ Query generator initialized")
            
            self.tester = AccuracyTester(
                statutes_dir=str(self.statutes_dir),
                cases_dir=str(self.all_cases_dir)
            )
            print("✓ Accuracy tester initialized")
            
        except Exception as e:
            print(f"❌ Initialization error: {e}")
            raise
    
    def load_all_statutes(self) -> str:
        """Load all .pl statute files and concatenate their content"""
        print("📚 Loading all statute files...")
        statutes_text = ""
        
        # Get all .pl files from statutes directory
        statute_files = sorted([f for f in self.statutes_dir.glob("*.pl") if f.name != "init.pl"])
        
        print(f"   Found {len(statute_files)} statute files")
        
        for statute_file in statute_files:
            try:
                with open(statute_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # Add file name as comment for clarity
                    statutes_text += f"\n% ===== {statute_file.name} =====\n"
                    statutes_text += content
                    statutes_text += "\n"
            except Exception as e:
                print(f"   ⚠️ Error reading {statute_file.name}: {e}")
        
        print(f"   Loaded {len(statutes_text)} characters of statute text")
        return statutes_text
    
    def process_case(self, case_file: str, statutes_text: str) -> Dict:
        """Process a single case through the full pipeline"""
        try:
            # Try to find the case file
            case_path = None
            
            # First try test directory
            if self.test_cases_dir.exists():
                test_case_path = self.test_cases_dir / case_file
                if test_case_path.exists():
                    case_path = test_case_path
            
            # If not found, try all cases directory
            if case_path is None:
                all_case_path = self.all_cases_dir / case_file
                if all_case_path.exists():
                    case_path = all_case_path
            
            if case_path is None:
                raise FileNotFoundError(f"Case file not found: {case_file}")
            
            # Parse case using the found path
            original_cases_dir = self.parser.cases_dir
            self.parser.cases_dir = case_path.parent
            case_data = self.parser.parse_case(case_path.name)
            self.parser.cases_dir = original_cases_dir  
            
            case_id = case_data['case_id']
            
            print(f"  Step 1: Generating facts from text...", end='', flush=True)
            
            # Generate facts from natural language text
            generated_facts = self.fact_generator.generate_facts(
                case_data['text'], 
                case_data['question'],
                statutes_text
            )
            
            # Save generated facts
            facts_file = self.facts_dir / f"{case_id}_facts.pl"
            with open(facts_file, 'w') as f:
                f.write(f"% Stage 2 Generated Facts\n")
                f.write(f"% Case: {case_id}\n")
                f.write(f"% Text: {case_data['text']}\n")
                f.write(f"% Question: {case_data['question']}\n\n")
                f.write(generated_facts)
                f.write("\n")
            
            print(" ✓")
            print(f"  Step 2: Generating query from facts...", end='', flush=True)
            
            # Create modified case data with generated facts
            case_data_with_facts = case_data.copy()
            case_data_with_facts['facts'] = generated_facts
            
            # Generate query from facts
            generated_query = self.query_generator.generate_query(
                case_data_with_facts,
                statutes_text
            )
            
            # Save generated query
            query_file = self.queries_dir / f"{case_id}.pl"
            with open(query_file, 'w') as f:
                f.write(f"% Stage 2 Generated Query\n")
                f.write(f"% Case: {case_id}\n")
                f.write(f"% Question: {case_data['question']}\n\n")
                f.write(generated_query)
                f.write("\n")
            
            print(" ✓")
            print(f"  Step 3: Testing query...", end='', flush=True)
            
            # Create test case data with generated facts
            test_case_data = {
                'case_id': case_id,
                'facts': generated_facts,
                'query': generated_query
            }
            
            # Test the query with generated facts
            test_result = self._test_with_generated_facts(
                case_id, 
                generated_facts, 
                generated_query,
                case_data.get('test', '')
            )
            
            if test_result.get('success'):
                if test_result.get('correct'):
                    print(" ✓ CORRECT")
                else:
                    print(f" ✗ WRONG (expected: {test_result.get('expected')}, got: {test_result.get('actual')})")
            else:
                print(f" ✗ ERROR: {test_result.get('error')}")
            
            return {
                'case_id': case_id,
                'text': case_data['text'],
                'question': case_data['question'],
                'generated_facts': generated_facts,
                'generated_query': generated_query,
                'facts_file': str(facts_file),
                'query_file': str(query_file),
                'test_result': test_result,
                'golden_facts': case_data.get('facts', ''),
                'golden_test': case_data.get('test', '')
            }
            
        except Exception as e:
            print(f" ✗ ERROR")
            import traceback
            traceback.print_exc()
            return {
                'case_id': case_file.replace('.pl', ''),
                'error': str(e),
                'test_result': {'success': False, 'error': str(e)}
            }
    
    def _test_with_generated_facts(self, case_id: str, facts: str, query: str, golden_test: str) -> Dict:
        """Test query with generated facts"""
        import subprocess
        import tempfile
        import uuid

        # Determine expected result from case_id and golden test with proper parsing of golden test format
        if golden_test:
            golden_test = golden_test.strip()
            if golden_test.startswith(':- tax(') and golden_test.endswith('.'):
                expected = 'true'  
            elif golden_test.startswith(':- \\+') or golden_test.startswith(':-\\+'):
                expected = 'false' 
            elif golden_test.startswith(':- ') and '\\+' not in golden_test:
                expected = 'true' 
            elif 'answer(' in golden_test and '-> Result = ' in golden_test:
                if '-> Result = true' in golden_test:
                    expected = 'true'
                else:
                    expected = 'false'
            else:
                if '_pos' in case_id:
                    expected = 'true'
                elif '_neg' in case_id:
                    expected = 'false'
                else:
                    expected = 'true' if case_id.startswith('tax_case') else 'unknown'
        else:
            if '_pos' in case_id:
                expected = 'true'
            elif '_neg' in case_id:
                expected = 'false'
            else:
                expected = 'true' if case_id.startswith('tax_case') else 'unknown'

        temp_filename = f"temp_{case_id}_{uuid.uuid4().hex[:8]}.pl"
        temp_filepath = self.statutes_dir / temp_filename

        try:
            with open(temp_filepath, 'w') as f:
                # Write the test file content
                f.write("% Temporary test file for Stage 2\n")
                f.write("% Load all predicates first\n")
                f.write(":- ['init'].\n\n")

                # Write generated facts
                f.write("% Generated facts\n")
                for line in facts.strip().split('\n'):
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

            cmd = ['swipl', '-g', 'true', '-t', 'halt(2)', temp_filename]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=10,
                cwd=str(self.statutes_dir)
            )

            # Parse output
            output = result.stdout
            stderr = result.stderr
            actual = None
            error_msg = None

            if 'RESULT: ' in output:
                actual = output.split('RESULT: ')[1].split('\n')[0].strip()
            elif 'ERROR: ' in output:
                error_details = output.split('ERROR: ')[1].split('\n')[0].strip()
                # Parse the error
                if 'existence_error(procedure,' in error_details:
                    import re
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

            # Builds result
            if actual is not None:
                return {
                    'success': True,
                    'expected': expected,
                    'actual': actual,
                    'correct': actual == expected,
                    'golden_test': golden_test
                }
            else:
                return {
                    'success': False,
                    'error': error_msg,
                    'expected': expected,
                    'golden_test': golden_test,
                    'debug_output': output if output else None,
                    'debug_stderr': stderr if stderr else None
                }
        
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'error': 'Timeout after 10 seconds',
                'expected': expected,
                'golden_test': golden_test
            }
        finally:
            # Cleans up temp file
            if temp_filepath.exists():
                temp_filepath.unlink()

    def get_test_cases(self, n: Optional[int] = None) -> List[str]:
        """Get test cases from the test split directory"""
        if not self.test_cases_dir.exists():
            print(f"⚠️  Test directory not found: {self.test_cases_dir}")
            print(f"   Checking alternate location...")
            
            alt_locations = [
                self.base_dir / "data/sara_v3/splits/test",
                self.base_dir / "data/sara_v3/cases/test_split",
                self.base_dir / "data/sara_v3/test_cases"
            ]
            
            for alt_dir in alt_locations:
                if alt_dir.exists():
                    print(f"   Found test cases at: {alt_dir}")
                    self.test_cases_dir = alt_dir
                    break
            else:
                # If no test directory found, use all cases as fallback
                print(f"   No test directory found. Using all cases from: {self.all_cases_dir}")
                if self.all_cases_dir.exists():
                    test_files = sorted([f.name for f in self.all_cases_dir.glob("*.pl")])
                    print(f"   Found {len(test_files)} cases total")
                    
                    # Filter to get test-like cases if needed
                    if n is not None:
                        return self._select_diverse_cases(test_files, n)
                    return test_files
                else:
                    raise ValueError(f"No cases found at any location!")
        
        # Get all .pl files from test directory
        test_files = sorted([f.name for f in self.test_cases_dir.glob("*.pl")])
        print(f"   Found {len(test_files)} test cases in {self.test_cases_dir}")
        
        if n is not None:
            return self._select_diverse_cases(test_files, n)
        
        return test_files
    
    def _select_diverse_cases(self, test_files: List[str], n: int) -> List[str]:
        """Select a diverse subset of cases"""
        # Try to get different types
        tax_cases = [f for f in test_files if f.startswith('tax_case')]
        s1_cases = [f for f in test_files if f.startswith('s1_')]
        s63_cases = [f for f in test_files if f.startswith('s63_')]
        s151_cases = [f for f in test_files if f.startswith('s151_')]
        s152_cases = [f for f in test_files if f.startswith('s152_')]
        other_cases = [f for f in test_files if not any(f.startswith(p) for p in ['tax_case', 's1_', 's63_', 's151_', 's152_'])]
        
        selected = []
        categories = [tax_cases, s1_cases, s63_cases, s151_cases, s152_cases, other_cases]
        per_category = max(1, n // len(categories))
        
        for category in categories:
            if category:
                selected.extend(category[:per_category])

        all_remaining = [f for f in test_files if f not in selected]
        remaining_slots = n - len(selected)
        if remaining_slots > 0:
            selected.extend(all_remaining[:remaining_slots])
        
        return selected[:n]
    
    def run_batch(self, case_files: List[str], batch_size: int = 10, delay: float = 10.0) -> Dict:
        """Process multiple cases with rate limiting"""
        results = []
        total = len(case_files)
        
        print(f"\n🚀 Stage 2 Pipeline: Natural Language → Facts → Query")
        print(f"Processing {total} cases from test split")
        print(f"Results will be saved to: {self.results_dir}")
        print("-" * 80)

        statutes_text = self.load_all_statutes()

        stats = {
            'total_cases': total,
            'successful_fact_generation': 0,
            'successful_query_generation': 0,
            'successful_execution': 0,
            'correct_results': 0,
            'errors': {
                'fact_generation': 0,
                'query_generation': 0,
                'execution': 0,
                'undefined_predicate': 0,
                'contradiction_failures': 0,
                'entailment_failures': 0
            }
        }
        
        for i, case_file in enumerate(case_files, 1):
            print(f"\n[{i}/{total}] Processing {case_file}...")
            
            result = self.process_case(case_file, statutes_text)
            results.append(result)

            if 'error' not in result:
                if result.get('generated_facts'):
                    stats['successful_fact_generation'] += 1
                if result.get('generated_query'):
                    stats['successful_query_generation'] += 1
                
                test = result.get('test_result', {})
                if test.get('success'):
                    stats['successful_execution'] += 1
                    if test.get('correct'):
                        stats['correct_results'] += 1
                    else:
                        # Track failure types
                        expected = test.get('expected')
                        actual = test.get('actual')
                        if expected == 'false' and actual == 'true':
                            stats['errors']['contradiction_failures'] += 1
                        elif expected == 'true' and actual == 'false':
                            stats['errors']['entailment_failures'] += 1
                else:
                    stats['errors']['execution'] += 1
                    error = test.get('error', '')
                    if 'Undefined predicate' in error:
                        stats['errors']['undefined_predicate'] += 1
            else:
                stats['errors']['fact_generation'] += 1

            if i % batch_size == 0 and i < total:
                print(f"\n  [Rate limit pause - waiting {delay}s]")
                time.sleep(delay)

        self._save_results(results, stats)
        self._print_summary(stats)
        
        return {
            'stats': stats,
            'results': results,
            'results_dir': str(self.results_dir)
        }
    
    def _save_results(self, results: List[Dict], stats: Dict):
        """Save results and statistics"""
        total = stats['total_cases']
        if total == 0:
            print("⚠️  No cases processed, skipping results save")
            return
        
        # Save detailed results
        results_file = self.results_dir / "results.json"
        with open(results_file, 'w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'stats': stats,
                'results': results
            }, f, indent=2)

        summary_file = self.results_dir / "summary.json"
        with open(summary_file, 'w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'total_cases': total,
                'accuracy': f"{stats['correct_results']/total*100:.2f}%" if total > 0 else "N/A",
                'fact_generation_rate': f"{stats['successful_fact_generation']/total*100:.2f}%" if total > 0 else "N/A",
                'query_generation_rate': f"{stats['successful_query_generation']/total*100:.2f}%" if total > 0 else "N/A",
                'execution_rate': f"{stats['successful_execution']/total*100:.2f}%" if total > 0 else "N/A",
                'errors': stats['errors']
            }, f, indent=2)

        failed_cases = [r for r in results if not r.get('test_result', {}).get('correct')]
        if failed_cases:
            failures_file = self.results_dir / "failures.json"
            with open(failures_file, 'w') as f:
                json.dump(failed_cases, f, indent=2)
    
    def _print_summary(self, stats: Dict):
        """Print final summary"""
        total = stats['total_cases']
        
        print(f"\n{'='*80}")
        print(f"📊 STAGE 2 RESULTS SUMMARY")
        print(f"{'='*80}")
        print(f"Total cases: {total}")
        
        if total == 0:
            print("⚠️  No cases were processed!")
            return
        
        print(f"\nPipeline Success Rates:")
        print(f"  Fact generation: {stats['successful_fact_generation']}/{total} ({stats['successful_fact_generation']/total*100:.1f}%)")
        print(f"  Query generation: {stats['successful_query_generation']}/{total} ({stats['successful_query_generation']/total*100:.1f}%)")
        print(f"  Execution: {stats['successful_execution']}/{total} ({stats['successful_execution']/total*100:.1f}%)")
        print(f"\nFinal Accuracy: {stats['correct_results']}/{total} ({stats['correct_results']/total*100:.1f}%)")
        
        if stats['errors']['contradiction_failures'] > 0 or stats['errors']['entailment_failures'] > 0:
            print(f"\nFailure Analysis:")
            print(f"  Contradiction failures: {stats['errors']['contradiction_failures']}")
            print(f"  Entailment failures: {stats['errors']['entailment_failures']}")
            print(f"  Undefined predicates: {stats['errors']['undefined_predicate']}")
            print(f"  Other execution errors: {stats['errors']['execution'] - stats['errors']['undefined_predicate']}")
        
        print(f"\nResults saved to: {self.results_dir}")

def main():
    print("🎯 Stage 2: Natural Language to Facts & Query Generation")
    
    parser = argparse.ArgumentParser(description='Stage 2 Pipeline')
    parser.add_argument('--test', type=int, help='Number of test cases to run')
    parser.add_argument('--all', action='store_true', help='Run on all 100 test cases')
    parser.add_argument('--run-name', help='Name for results directory')
    parser.add_argument('--api-key', help='Gemini API key (or set GEMINI_API_KEY env var)')
    parser.add_argument('--batch-size', type=int, default=10, help='Batch size for rate limiting')
    parser.add_argument('--delay', type=float, default=10.0, help='Delay between batches (seconds)')
    parser.add_argument('--cases', nargs='+', help='Specific case files to process')
    
    args = parser.parse_args()
    
    # Check for API key
    api_key = args.api_key or os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("\n❌ Error: No Gemini API key provided!")
        print("Please provide via one of these methods:")
        print("1. Command line: --api-key YOUR_KEY")
        print("2. Environment variable: export GEMINI_API_KEY=YOUR_KEY")
        print("3. In your .env file: GEMINI_API_KEY=YOUR_KEY")
        sys.exit(1)
    else:
        print(f"✓ Using Gemini API key: {api_key[:10]}...")
    
    try:
        pipeline = Stage2Pipeline(api_key=api_key, run_name=args.run_name)
        if args.cases:
            case_files = args.cases
            print(f"\n📋 Running on {len(case_files)} specified cases")
        elif args.all:
            # All test cases
            case_files = pipeline.get_test_cases()
            print(f"\n📋 Running on all {len(case_files)} test cases")
        else:
            # Limited number of test cases
            num_cases = args.test or 20
            case_files = pipeline.get_test_cases(num_cases)
            print(f"\n📋 Running on {len(case_files)} test cases")

        case_files = [f if f.endswith('.pl') else f"{f}.pl" for f in case_files]

        pipeline.run_batch(
            case_files, 
            batch_size=args.batch_size,
            delay=args.delay
        )
        
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
