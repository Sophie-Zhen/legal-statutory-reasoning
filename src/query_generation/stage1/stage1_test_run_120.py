#!/usr/bin/env python3
"""
stage1_test_run_120.py - Run Stage 1 on your specific 120 test cases
I updated it to work with full statute text approach
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
    from query_generator import QueryGeneratorLLM
    from test_accuracy import AccuracyTester
except ImportError as e:
    print(f"Import failed: {e}")
    print("Are all the other .py files (case_parser, etc.) in the same folder as this script?")
    sys.exit(1)

class Stage1TestRunner:
    def __init__(self, api_key: Optional[str] = None, minimal_fallback: bool = False):
        self.base_dir = Path("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
        self.cases_dir = self.base_dir / "data/sara_v3/cases"
        self.statutes_dir = self.base_dir / "data/sara_v3/statutes/prolog"
        
        # Folder for the 120-case test run
        self.output_dir = Path("results") / "stage1_test120_run"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"Saving generated files to: {self.output_dir}")
        
        # Initialising all the helper classes
        try:
            self.parser = CaseParser(self.cases_dir)
            self.generator = QueryGeneratorLLM(api_key=api_key, minimal_fallback=minimal_fallback)
            self.tester = AccuracyTester(
                statutes_dir=str(self.statutes_dir),
                cases_dir=str(self.cases_dir)
            )
            print("Parser, Generator, and Tester are ready.")
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
            'unknown_failures': 0
        }
    
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
        
    def get_specific_test_cases(self) -> List[str]:
        """
        Returns your specific list of 120 test cases.
        """
        test_case_ids = [
            's151_d_1_neg', 's151_d_1_pos', 's151_d_3_A_neg', 's151_d_3_A_pos',
            's151_d_5_neg', 's151_d_5_pos', 's152_a_neg', 's152_a_pos',
            's152_c_2_A_neg', 's152_c_2_A_pos', 's152_d_1_D_neg', 's152_d_1_D_pos',
            's152_d_2_A_neg', 's152_d_2_A_pos', 's152_d_2_C_neg', 's152_d_2_C_pos',
            's152_d_2_G_neg', 's152_d_2_G_pos', 's152_d_2_H_neg', 's152_d_2_H_pos',
            's1_a_2_iv_neg', 's1_a_2_iv_pos', 's1_a_2_neg', 's1_a_2_pos',
            's1_a_2_v_neg', 's1_a_2_v_pos', 's1_b_i_neg', 's1_b_i_pos',
            's1_b_neg', 's1_b_pos', 's1_c_iii_neg', 's1_c_iii_pos',
            's1_c_neg', 's1_c_pos', 's1_d_i_neg', 's1_d_i_pos',
            's1_d_ii_neg', 's1_d_ii_pos', 's1_d_neg', 's1_d_pos',
            's2_a_1_B_neg', 's2_a_1_B_pos', 's2_b_1_A_i_II_neg', 's2_b_1_A_i_II_pos',
            's2_b_1_A_i_I_neg', 's2_b_1_A_i_I_pos', 's2_b_1_A_i_neg', 's2_b_1_A_i_pos',
            's2_b_1_A_ii_neg', 's2_b_1_A_ii_pos', 's2_b_3_A_neg', 's2_b_3_A_pos',
            's3301_neg', 's3301_pos', 's3306_a_1_B_neg', 's3306_a_1_B_pos',
            's3306_a_3_neg', 's3306_a_3_pos', 's3306_b_2_C_neg', 's3306_b_2_C_pos',
            's3306_c_10_B_neg', 's3306_c_10_B_pos', 's3306_c_11_neg', 's3306_c_11_pos',
            's3306_c_16_neg', 's3306_c_16_pos', 's3306_c_1_B_neg', 's3306_c_1_B_pos',
            's3306_c_6_neg', 's3306_c_6_pos', 's3306_c_7_neg', 's3306_c_7_pos',
            's3306_c_B_neg', 's3306_c_B_pos', 's63_b_neg', 's63_b_pos',
            's63_c_2_A_i_neg', 's63_c_2_A_i_pos', 's63_c_2_A_ii_neg', 's63_c_2_A_ii_pos',
            's63_c_6_B_neg', 's63_c_6_B_pos', 's63_c_6_D_neg', 's63_c_6_D_pos',
            's63_c_7_i_neg', 's63_c_7_i_pos', 's63_f_1_A_neg', 's63_f_1_A_pos',
            's63_f_2_B_neg', 's63_f_2_B_pos', 's68_a_2_neg', 's68_a_2_pos',
            's68_b_1_B_neg', 's68_b_1_B_pos', 's68_b_1_C_neg', 's68_b_1_C_pos',
            's7703_a_1_neg', 's7703_a_1_pos', 's7703_b_2_neg', 's7703_b_2_pos',
            'tax_case_28', 'tax_case_30', 'tax_case_31', 'tax_case_34',
            'tax_case_43', 'tax_case_46', 'tax_case_48', 'tax_case_49',
            'tax_case_53', 'tax_case_57', 'tax_case_68', 'tax_case_69',
            'tax_case_75', 'tax_case_77', 'tax_case_78', 'tax_case_82',
            'tax_case_85', 'tax_case_9', 'tax_case_90', 'tax_case_93'
        ]
        # Add .pl extension to each name
        return [f"{case_id}.pl" for case_id in test_case_ids]

    def process_case(self, case_file: str, statutes_text: str, case_number: int, total: int, force_regenerate: bool) -> Dict:
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
                # Pass statutes_text to generate_query
                query = self.generator.generate_query(case_data, statutes_text)
                self.stats['successful_generation'] += 1
                with open(query_file, 'w') as f:
                    # Keep the generated prolog file clean
                    f.write(f"% Generated by stage1_test_run_120.py for case: {case_id}\n")
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
        """Kicks off the run for the 120 test cases."""
        cases = self.get_specific_test_cases()
        total = len(cases)
        self.stats['total_cases'] = total
        
        print(f"\n--- Starting The 120 Case Test Run ---")
        print(f"Total cases: {total}")
        if force_regenerate:
            print("Mode: Forcing regeneration of all queries.")
        print("="*40)
        
        # Load all statutes once before processing
        statutes_text = self.load_all_statutes()
        
        rate_limit_count = 0
        
        for i, case_file in enumerate(cases):
            # Check if this case exists
            case_path = self.cases_dir / case_file
            if not case_path.exists():
                print(f"[{i+1}/{total}] {case_file}: FILE NOT FOUND, skipping...")
                self.stats['errors'].append({'case_id': case_file.replace('.pl', ''), 'error': 'File not found'})
                continue
                
            self.process_case(case_file, statutes_text, i + 1, total, force_regenerate)
            
            # Rate limiting
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

        print("\n" + "="*40)
        print("--- FINAL ACCURACY ---")
        print("="*40)
        print(f"Cases Tested: {total}")
        print(f"Correct: {self.stats['correct_results']} / {total}")
        print(f"Accuracy: {self.stats['correct_results']/total*100:.2f}%")
        
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
                'total_cases': total,
                'correct_cases': correct,
                'accuracy': f"{accuracy:.2f}%",
                'contradiction_failures': self.stats['contradiction_failures'],
                'entailment_failures': self.stats['entailment_failures'],
                'unknown_failures': self.stats['unknown_failures'],
                'errors': self.stats['errors']
            }
            
            json.dump(summary, f, indent=2)

def main():
    parser = argparse.ArgumentParser(description='Runs the 120-case test for Stage 1.')
    parser.add_argument('--api-key', help='Your Gemini API key.')
    parser.add_argument('--batch-size', type=int, default=10, help='How many API calls before a quick pause (default: 10).')
    parser.add_argument('--delay', type=float, default=10.0, help='Seconds to pause between batches (default: 10).')
    parser.add_argument('--force', action='store_true', help='Regenerates queries even if they already exist in the output folder.')
    parser.add_argument('--minimal-fallback', action='store_true', help='Use minimal fallback (no pattern matching) for true LLM testing')
    args = parser.parse_args()
    
    api_key = args.api_key or os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("\nAPI key missing!")
        print("You need to provide your Gemini API key. Use the --api-key flag or set it as an environment variable.")
        sys.exit(1)
    
    print("API key loaded.")
    
    try:
        runner = Stage1TestRunner(api_key=api_key, minimal_fallback=args.minimal_fallback)
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