#!/usr/bin/env python3
"""
stage2_paper_100_test.py - Run the full Stage 2 pipeline (Text -> Facts -> Query)
on the paper's specific 100 test cases.
"""

import os
import sys
import argparse
from pathlib import Path

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from stage2_main import Stage2Pipeline

# The 100 non-tax cases from the paper
PAPER_100_CASES = [
    's151_d_1_neg', 's151_d_1_pos', 's151_d_3_A_neg', 's151_d_3_A_pos', 
    's151_d_5_neg', 's151_d_5_pos', 's152_a_neg', 's152_a_pos', 
    's152_c_1_B_neg', 's152_c_1_B_pos', 's152_c_1_E_neg', 's152_c_1_E_pos', 
    's152_c_2_A_neg', 's152_c_2_A_pos', 's152_c_3_neg', 's152_c_3_pos', 
    's152_d_1_D_neg', 's152_d_1_D_pos', 's152_d_2_C_neg', 's152_d_2_C_pos', 
    's152_d_2_G_neg', 's152_d_2_G_pos', 's152_d_2_H_neg', 's152_d_2_H_pos', 
    's1_a_1_iv_neg', 's1_a_1_iv_pos', 's1_a_2_v_neg', 's1_a_2_v_pos', 
    's1_b_i_neg', 's1_b_i_pos', 's1_c_ii_neg', 's1_c_ii_pos', 
    's1_d_iii_neg', 's1_d_iii_pos', 's2_a_1_B_neg', 's2_a_1_B_pos', 
    's2_b_1_A_i_II_neg', 's2_b_1_A_i_II_pos', 's2_b_1_A_i_I_neg', 's2_b_1_A_i_I_pos', 
    's2_b_1_A_ii_neg', 's2_b_1_A_ii_pos', 's2_b_3_A_neg', 's2_b_3_A_pos', 
    's3301_neg', 's3301_pos', 's3306_a_1_B_neg', 's3306_a_1_B_pos', 
    's3306_b_10_A_neg', 's3306_b_10_A_pos', 's3306_b_15_neg', 's3306_b_15_pos', 
    's3306_c_10_A_ii_neg', 's3306_c_10_A_ii_pos', 's3306_c_13_neg', 's3306_c_13_pos', 
    's3306_c_1_A_i_neg', 's3306_c_1_A_i_pos', 's3306_c_5_neg', 's3306_c_5_pos', 
    's63_c_1_neg', 's63_c_1_pos', 's63_c_2_A_ii_neg', 's63_c_2_A_ii_pos', 
    's63_c_5_neg', 's63_c_5_pos', 's63_c_7_i_neg', 's63_c_7_i_pos', 
    's63_d_neg', 's63_d_pos', 's63_f_1_B_neg', 's63_f_1_B_pos', 
    's63_f_2_B_neg', 's63_f_2_B_pos', 's68_a_2_neg', 's68_a_2_pos', 
    's68_b_1_C_neg', 's68_b_1_C_pos', 's68_f_neg', 's68_f_pos', 
    's7703_a_2_neg', 's7703_a_2_pos', 's7703_b_2_neg', 's7703_b_2_pos',
    # -- The 16 missing cases to make it 100 --
    's151_b_neg', 's151_b_pos', 's152_b_1_neg', 's152_b_1_pos',
    's1_a_1_neg', 's1_a_1_pos', 's2_a_2_A_neg', 's2_a_2_A_pos',
    's2_b_1_B_neg', 's2_b_1_B_pos', 's3306_b_7_neg', 's3306_b_7_pos',
    's63_c_6_D_neg', 's63_c_6_D_pos', 's68_a_1_neg', 's68_a_1_pos'
]

def main():
    parser = argparse.ArgumentParser(description='Run Stage 2 on the 100 paper test cases.')
    parser.add_argument('--run-name', default="paper_100_test", help='Name for results directory.')
    parser.add_argument('--api-key', help='Gemini API key (or set GEMINI_API_KEY env var).')
    parser.add_argument('--batch-size', type=int, default=10, help='Batch size for rate limiting.')
    parser.add_argument('--delay', type=float, default=10.0, help='Delay between batches (seconds).')
    parser.add_argument('--skip-existing', action='store_true', help='Skip cases that already have results.')

    args = parser.parse_args()

    api_key = args.api_key or os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("\n❌ Error: No Gemini API key provided!")
        print("Please provide via --api-key or set GEMINI_API_KEY environment variable.")
        sys.exit(1)
    
    print(f"✓ Using Gemini API key.")
    case_files = [f"{case}.pl" for case in PAPER_100_CASES]
    
    try:
        pipeline = Stage2Pipeline(api_key=api_key, run_name=args.run_name)
        
        cases_to_run = case_files
        if args.skip_existing:
            print("📋 Checking for existing results to skip...")
            remaining_cases = []
            for case_file in case_files:
                case_id = case_file.replace('.pl', '')
                # Check if the final query file exists
                query_file = pipeline.queries_dir / f"{case_id}.pl"
                if not query_file.exists():
                    remaining_cases.append(case_file)
                else:
                    print(f"  Skipping {case_id} (already exists)")
            
            cases_to_run = remaining_cases
            print(f"📋 Cases remaining after filtering: {len(cases_to_run)}")
        
        if not cases_to_run:
            print("✅ No new cases to process!")
            return

        # Runs the full Stage 2 pipeline on the selected cases
        results = pipeline.run_batch(
            cases_to_run,
            batch_size=args.batch_size,
            delay=args.delay
        )
        
    except Exception as e:
        print(f"\n❌ A fatal error occurred: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()