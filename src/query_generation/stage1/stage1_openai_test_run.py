#!/usr/bin/env python3
"""
stage1_openai_test_run.py - Test runner using OpenAI o1-mini model
Optimized for smaller context window - focuses on facts only
"""

import os
import sys
import json
import time
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

# For loading the API key from a .env file
try:
    from dotenv import load_dotenv
    env_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts/src/.env"
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print("Found .env file, loading keys from there.")
except ImportError:
    print("Warning: python-dotenv isn't installed. You should 'pip install' it to handle your API key better.")

# Add parent directory to path so it can find the other scripts
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    from case_parser import CaseParser
    from query_generator_openai import QueryGeneratorOpenAI  # Import our new OpenAI generator
    from test_accuracy import AccuracyTester
except ImportError as e:
    print(f"Import failed: {e}")
    print("Are all the other .py files (case_parser, etc.) in the same folder as this script?")
    sys.exit(1)

class Stage1OpenAITestRunner:
    def __init__(self, api_key: Optional[str] = None, minimal_fallback: bool = False, model_name: str = 'o4-mini-2025-04-16'):
        self.base_dir = Path("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
        self.cases_dir = self.base_dir / "data/sara_v3/cases"
        self.statutes_dir = self.base_dir / "data/sara_v3/statutes/prolog"
        
        # Folder for the OpenAI test run
        self.output_dir = Path("results") / f"stage1_openai_{model_name.replace('-', '_').replace('.', '_')}_test"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"Saving generated files to: {self.output_dir}")
        
        # Initializing all the helper classes with OpenAI generator
        try:
            self.parser = CaseParser(self.cases_dir)
            self.generator = QueryGeneratorOpenAI(api_key=api_key, minimal_fallback=minimal_fallback, model_name=model_name)
            self.tester = AccuracyTester(
                statutes_dir=str(self.statutes_dir),
                cases_dir=str(self.cases_dir)
            )
            print("Parser, OpenAI Generator, and Tester are ready.")
            if minimal_fallback:
                print("⚠️ Using minimal fallback - true LLM performance testing")
        except Exception as e:
            print(f"Initialization error: {e}")
            raise
        
        # To keep track of stats as it runs
        self.stats = {
            'total_cases': 0,
            'successful_generation': 0,
            'successful_execution': 0,
            'correct_results': 0,
            'errors': [],
            'contradiction_failures': 0,
            'entailment_failures': 0,
            'unknown_failures': 0,
            'openai_llm_generations': 0,
            'minimal_fallback_generations': 0
        }
    
    def get_specific_test_cases(self) -> List[str]:
        """
        Returns a focused set of test cases for OpenAI testing.
        You can modify this to focus on specific types of cases.
        """
        # Start with a smaller subset for testing OpenAI
        test_case_ids = [
            # Section 151 cases (exemptions)
            's151_d_1_neg', 's151_d_1_pos', 's151_d_3_A_neg', 's151_d_3_A_pos',
            's151_d_5_neg', 's151_d_5_pos',
            
            # Section 152 cases (dependents)
            's152_a_neg', 's152_a_pos', 's152_c_2_A_neg', 's152_c_2_A_pos',
            
            # Section 63 cases (taxable income)
            's63_b_neg', 's63_b_pos', 's63_c_2_A_i_neg', 's63_c_2_A_i_pos',
            's63_c_6_B_neg', 's63_c_6_B_pos', 's63_c_6_D_neg', 's63_c_6_D_pos',
            
            # Section 1 cases (tax calculations)
            's1_a_2_iv_neg', 's1_a_2_iv_pos', 's1_a_2_neg', 's1_a_2_pos',
            's1_b_i_neg', 's1_b_i_pos', 's1_c_iii_neg', 's1_c_iii_pos',
            
            # Some tax cases for comparison
            'tax_case_28', 'tax_case_30', 'tax_case_31', 'tax_case_34',
            'tax_case_43', 'tax_case_46', 'tax_case_48', 'tax_case_49'
        ]
        
        # Add .pl extension to each name
        return [f"{case_id}.pl" for case_id in test_case_ids]

    def process_case(self, case_file: str, case_number: int, total: int, force_regenerate: bool) -> Dict:
        """This function handles one case at a time."""
        try:
            case_data = self.parser.parse_case(case_file)
            case_id = case_data['case_id']
            
            query_file = self.output_dir / f"{case_id}.pl"
            if query_file.exists() and not force_regenerate:
                print(f"[{case_number}/{total}] {case_id}: Found existing file, skipping generation.")
                with open(query_file, 'r') as f:
                    content = f.read()
                query = next((line.strip() for line in content.split('\n') if line.strip().startswith('answer(')), None)
            else:
                print(f"[{case_number}/{total}] Processing {case_id}...", end=' ', flush=True)
                # Note: We don't pass full statutes_text since OpenAI has smaller context window
                query = self.generator.generate_query(case_data)
                self.stats['successful_generation'] += 1
                
                # Track generation method
                if case_id in self.generator.generation_methods:
                    method = self.generator.generation_methods[case_id]
                    if method == 'openai_llm':
                        self.stats['openai_llm_generations'] += 1
                    elif method == 'minimal_fallback':
                        self.stats['minimal_fallback_generations'] += 1
                
                with open(query_file, 'w') as f:
                    # Keep the generated prolog file clean
                    f.write(f"% Generated by OpenAI {self.generator.model_name} for case: {case_id}\n")
                    f.write(f"% Question: {case_data['question']}\n")
                    f.write(query + "\n")

            test_result = self.tester.test_query(case_id, query)
            
            if test_result.get('success'):
                self.stats['successful_execution'] += 1
                if test_result.get('correct'):
                    self.stats['correct_results'] += 1
                    print(f"-> PASSED")
                else:
                    expected = test_result.get('expected')
                    actual = test_result.get('actual')
                    print(f"-> FAILED (expected {expected}, got {actual})")
                    
                    # Track failure types
                    if expected == 'false' and actual == 'true':
                        self.stats['contradiction_failures'] += 1
                    elif expected == 'true' and actual == 'false':
                        self.stats['entailment_failures'] += 1
                    elif expected == 'unknown':
                        self.stats['unknown_failures'] += 1
            else:
                error = test_result.get('error', 'Unknown error')
                print(f"-> Prolog Error: {error}")
                self.stats['errors'].append({'case_id': case_id, 'error': error})

            return {'case_id': case_id, 'generated_query': query, 'test_result': test_result}
            
        except Exception as e:
            print(f"-> MAJOR EXCEPTION: {e}")
            self.stats['errors'].append({'case_id': case_file.replace('.pl', ''), 'error': str(e)})
            return {'case_id': case_file.replace('.pl', ''), 'error': str(e)}

    def run_test_set(self, batch_size: int, delay: float, force_regenerate: bool):
        """Kicks off the run for the OpenAI test cases."""
        cases = self.get_specific_test_cases()
        total = len(cases)
        self.stats['total_cases'] = total
        
        print(f"\n--- Starting OpenAI {self.generator.model_name} Test Run ---")
        print(f"Total cases: {total}")
        if force_regenerate:
            print("Mode: Forcing regeneration of all queries.")
        print("="*50)
        
        for i, case_file in enumerate(cases):
            # Check if this case exists
            case_path = self.cases_dir / case_file
            if not case_path.exists():
                print(f"[{i+1}/{total}] {case_file}: FILE NOT FOUND, skipping...")
                self.stats['errors'].append({'case_id': case_file.replace('.pl', ''), 'error': 'File not found'})
                continue
                
            self.process_case(case_file, i + 1, total, force_regenerate)
            
            # Rate limiting - be more conservative with OpenAI
            if (i + 1) % batch_size == 0 and (i + 1) < total:
                print(f"  [Rate limit pause - waiting {delay}s]")
                time.sleep(delay)
        
        self.save_results()
        self.print_final_stats()
        
    def print_final_stats(self):
        """Prints the final summary with detailed failure analysis."""
        total = self.stats['total_cases']
        if total == 0:
            print("No cases were processed.")
            return

        print("\n" + "="*50)
        print("--- FINAL ACCURACY ---")
        print("="*50)
        print(f"Cases Tested: {total}")
        print(f"Correct: {self.stats['correct_results']} / {total}")
        print(f"Accuracy: {self.stats['correct_results']/total*100:.2f}%")
        
        print("\n--- GENERATION METHOD ANALYSIS ---")
        print(f"OpenAI LLM successful generations: {self.stats['openai_llm_generations']}")
        print(f"Minimal fallback generations: {self.stats['minimal_fallback_generations']}")
        if total > 0:
            print(f"OpenAI success rate: {self.stats['openai_llm_generations']/total*100:.2f}%")
        
        print("\n--- FAILURE ANALYSIS ---")
        print(f"Contradiction failures (expected false, got true): {self.stats['contradiction_failures']}")
        print(f"Entailment failures (expected true, got false): {self.stats['entailment_failures']}")
        print(f"Unknown case failures: {self.stats['unknown_failures']}")
        
        if self.stats['errors']:
            print(f"\nEncountered {len(self.stats['errors'])} errors during the run.")
            print("Error types:")
            error_types = {}
            for err in self.stats['errors']:
                error_msg = err['error']
                if 'File not found' in error_msg:
                    key = 'File not found'
                elif 'Undefined predicate' in error_msg:
                    key = 'Undefined predicate'
                else:
                    key = 'Other'
                error_types[key] = error_types.get(key, 0) + 1
            
            for error_type, count in error_types.items():
                print(f"  {error_type}: {count}")
        
        print(f"\nGenerated files are in: {self.output_dir}")

    def save_results(self):
        """Saves a detailed results file."""
        summary_file = self.output_dir / "summary.json"
        with open(summary_file, 'w') as f:
            total = self.stats['total_cases']
            correct = self.stats['correct_results']
            accuracy = (correct / total * 100) if total > 0 else 0
            
            summary = {
                'run_timestamp': datetime.now().isoformat(),
                'model_used': self.generator.model_name,
                'total_cases': total,
                'correct_cases': correct,
                'accuracy': f"{accuracy:.2f}%",
                'openai_llm_generations': self.stats['openai_llm_generations'],
                'minimal_fallback_generations': self.stats['minimal_fallback_generations'],
                'openai_success_rate': f"{(self.stats['openai_llm_generations']/total*100) if total > 0 else 0:.2f}%",
                'contradiction_failures': self.stats['contradiction_failures'],
                'entailment_failures': self.stats['entailment_failures'],
                'unknown_failures': self.stats['unknown_failures'],
                'errors': self.stats['errors']
            }
            
            json.dump(summary, f, indent=2)

def main():
    parser = argparse.ArgumentParser(description='Runs OpenAI o1-mini test for Stage 1.')
    parser.add_argument('--api-key', help='Your OpenAI API key.')
    parser.add_argument('--model', default='o4-mini-2025-04-16', 
                       help='OpenAI model to use (default: o4-mini-2025-04-16)')
    parser.add_argument('--batch-size', type=int, default=5, 
                       help='How many API calls before a quick pause (default: 5, conservative for OpenAI).')
    parser.add_argument('--delay', type=float, default=15.0, 
                       help='Seconds to pause between batches (default: 15, conservative for OpenAI).')
    parser.add_argument('--force', action='store_true', 
                       help='Regenerates queries even if they already exist in the output folder.')
    parser.add_argument('--minimal-fallback', action='store_true', 
                       help='Use minimal fallback (no pattern matching) for true LLM testing')
    args = parser.parse_args()
    
    api_key = args.api_key or os.getenv('OPENAI_API_KEY')
    if not api_key:
        print("\nAPI key missing!")
        print("You need to provide your OpenAI API key. Use the --api-key flag or set it as an environment variable OPENAI_API_KEY.")
        sys.exit(1)
    
    print("OpenAI API key loaded.")
    
    try:
        runner = Stage1OpenAITestRunner(
            api_key=api_key, 
            minimal_fallback=args.minimal_fallback,
            model_name=args.model
        )
        runner.run_test_set(
            batch_size=args.batch_size,
            delay=args.delay,
            force_regenerate=args.force
        )
    except Exception as e:
        print(f"\nSomething went really wrong: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()