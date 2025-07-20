#!/usr/bin/env python3
"""
This is the one for the official test cases to get the real accuracy benchmark.
MODIFIED: Now it checks which of the 100 benchmark files actually exist locally.
"""

import os
import sys
import json
import time
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

# ... (rest of the imports and setup remain the same) ...
try:
    from dotenv import load_dotenv
    env_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts/src/.env"
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print("Found .env file, loading keys from there.")
except ImportError:
    print("Warning: python-dotenv isn't installed. You should 'pip install' it to handle your API key better.")

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    from case_parser import CaseParser
    from query_generator_v2 import QueryGeneratorLLMV2
    from test_accuracy import AccuracyTester
except ImportError as e:
    print(f"Import failed: {e}")
    print("Are all the other .py files (case_parser, etc.) in the same folder as this script?")
    sys.exit(1)

class Stage1TestRunner:
    def __init__(self, api_key: Optional[str] = None):
        self.base_dir = Path("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
        self.cases_dir = self.base_dir / "data/sara_v3/cases"
        self.statutes_dir = self.base_dir / "data/sara_v3/statutes/prolog"
        
        self.output_dir = Path("results") / "stage1_benchmark_run_100"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"Saving generated files to: {self.output_dir}")
        
        try:
            self.parser = CaseParser(self.cases_dir)
            self.generator = QueryGeneratorLLMV2(api_key=api_key)
            self.tester = AccuracyTester(
                statutes_dir=str(self.statutes_dir),
                cases_dir=str(self.cases_dir)
            )
            print("Parser, Generator, and Tester are ready.")
        except Exception as e:
            print(f"Initialization error: {e}")
            raise
        
        self.stats = {
            'total_cases': 0, 'successful_generation': 0, 'successful_execution': 0,
            'correct_results': 0, 'errors': [], 'missing_files': 0
        }
        
    def get_specific_test_cases(self) -> List[str]:
        """
        This is the official list of 100 test cases from the Blair-Stanek paper.
        The run script will filter this list against locally available files.
        """
        benchmark_ids = [
            's1_a_1_i_neg', 's1_a_1_i_pos', 's1_a_1_ii_neg', 's1_a_1_ii_pos', 's1_a_1_iii_neg',
            's1_a_1_iii_pos', 's1_a_1_iv_neg', 's1_a_1_iv_pos', 's1_a_1_v_neg', 's1_a_1_v_pos',
            's1_a_2_i_neg', 's1_a_2_i_pos', 's1_a_2_ii_neg', 's1_a_2_ii_pos', 's1_a_2_iii_neg',
            's1_a_2_iii_pos', 's1_b_i_neg', 's1_b_i_pos', 's1_b_ii_neg', 's1_b_ii_pos',
            's1_b_iii_neg', 's1_b_iii_pos', 's1_b_iv_neg', 's1_b_iv_pos', 's1_b_v_neg',
            's1_b_v_pos', 's1_c_i_neg', 's1_c_i_pos', 's1_c_ii_neg', 's1_c_ii_pos',
            's1_d_iii_neg', 's1_d_iii_pos', 's1_d_iv_neg', 's1_d_iv_pos', 's1_d_v_neg',
            's1_d_v_pos', 's151_d_2_neg', 's151_d_2_pos', 's151_d_3_A_neg', 's151_d_3_A_pos',
            's151_d_3_B_neg', 's151_d_3_B_pos', 's151_d_4_neg', 's151_d_4_pos', 's2_a_1_A_neg',
            's2_a_1_A_pos', 's63_c_2_A_i_neg', 's63_c_2_A_i_pos', 's63_c_2_B_neg',
            's63_c_2_B_pos', 's63_c_2_C_neg', 's63_c_2_C_pos', 's63_c_3_neg', 's63_c_3_pos',
            's63_c_4_neg', 's63_c_4_pos', 's63_c_5_neg', 's63_c_5_pos', 's63_d_neg',
            's63_d_pos', 's68_a_1_neg', 's68_a_1_pos', 's68_a_2_neg', 's68_a_2_pos',
            's68_a_3_neg', 's68_a_3_pos', 's68_a_neg', 's68_a_pos', 's68_c_neg',
            's68_c_pos', 's68_d_neg', 's68_d_pos', 's151_a_neg', 's151_a_pos',
            's151_b_neg', 's151_b_pos', 's151_c_neg', 's151_c_pos', 's152_b_1_neg',
            's152_b_1_pos', 's152_b_2_neg', 's152_b_2_pos', 's152_c_1_A_neg',
            's152_c_1_A_pos', 's152_c_1_B_neg', 's152_c_1_B_pos', 's152_d_2_D_neg',
            's152_d_2_D_pos', 's152_d_2_F_neg', 's152_d_2_F_pos', 's2_b_1_A_i_neg',
            's2_b_1_A_i_pos', 's2_b_2_neg', 's2_b_2_pos', 's7703_a_2_neg',
            's7703_a_2_pos', 's7703_b_1_neg', 's7703_b_1_pos', 's7703_b_3_neg',
            's7703_b_3_pos'
        ]
        
        # NEW: Check which files actually exist in the cases directory
        available_cases = []
        for case_id in benchmark_ids:
            if (self.cases_dir / f"{case_id}.pl").exists():
                available_cases.append(f"{case_id}.pl")
            else:
                self.stats['missing_files'] += 1
        
        return available_cases
    
    # --- The process_case, print_final_stats, save_results, and main functions ---
    # --- can remain the same as the previous version. I am including them here ---
    # --- for completeness. Just copy the whole file. ---

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
                query = self.generator.generate_query(case_data)
                self.stats['successful_generation'] += 1
                with open(query_file, 'w') as f:
                    f.write(f"# Generated by stage1_test_run.py for case: {case_id}\n")
                    f.write(query + "\n")

            test_result = self.tester.test_query(case_id, query)
            
            if test_result.get('success'):
                self.stats['successful_execution'] += 1
                if test_result.get('correct'):
                    self.stats['correct_results'] += 1
                    print(f"-> PASSED")
                else:
                    print(f"-> FAILED (expected {test_result.get('expected')}, got {test_result.get('actual')})")
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
        """Kicks off the run for the available benchmark cases."""
        cases = self.get_specific_test_cases()
        total = len(cases)
        self.stats['total_cases'] = total
        
        print(f"\n--- Starting The Benchmark Run ---")
        if self.stats['missing_files'] > 0:
            print(f"Warning: {self.stats['missing_files']} of the 100 benchmark files were not found in your directory.")
        print(f"Total cases to run: {total}")
        if force_regenerate:
            print("Mode: Forcing regeneration of all queries.")
        print("="*40)
        
        for i, case_file in enumerate(cases):
            self.process_case(case_file, i + 1, total, force_regenerate)
            if (i + 1) % batch_size == 0 and (i + 1) < total:
                time.sleep(delay)

        self.save_results()
        self.print_final_stats()

    def print_final_stats(self):
        """Prints the final summary."""
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
        
        if self.stats['errors'] or self.stats['missing_files'] > 0:
            print(f"\nIssues Encountered:")
            if self.stats['missing_files'] > 0:
                print(f"- {self.stats['missing_files']} benchmark files were missing.")
            if self.stats['errors']:
                print(f"- {len(self.stats['errors'])} cases had Prolog errors.")
        
        print(f"\nGenerated files are in: {self.output_dir}")

    def save_results(self):
        """Saves a simple summary.txt file."""
        summary_file = self.output_dir / "summary.txt"
        with open(summary_file, 'w') as f:
            total = self.stats['total_cases']
            correct = self.stats['correct_results']
            accuracy = (correct / total * 100) if total > 0 else 0
            f.write(f"Stage 1 - Benchmark Summary\n")
            f.write(f"Run at: {datetime.now().isoformat()}\n")
            f.write(f"--------------------------------------\n")
            f.write(f"Total Cases Tested: {total} (out of 100 official benchmark cases)\n")
            f.write(f"Missing Benchmark Files: {self.stats['missing_files']}\n")
            f.write(f"Correct Cases: {correct}\n")
            f.write(f"Final Accuracy: {accuracy:.2f}%\n")

def main():
    parser = argparse.ArgumentParser(description='Runs the benchmark test for Stage 1 on available files.')
    parser.add_argument('--api-key', help='Your Gemini API key.')
    parser.add_argument('--batch-size', type=int, default=10, help='How many API calls before a quick pause.')
    parser.add_argument('--delay', type=float, default=10.0, help='Seconds to pause between batches.')
    parser.add_argument('--force', action='store_true', help='Regenerates queries even if they already exist.')
    args = parser.parse_args()
    
    api_key = args.api_key or os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("\nAPI key missing!")
        print("You need to provide your Gemini API key. Use the --api-key flag or set it as an environment variable.")
        sys.exit(1)
    
    print("API key loaded.")
    
    try:
        runner = Stage1TestRunner(api_key=api_key)
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