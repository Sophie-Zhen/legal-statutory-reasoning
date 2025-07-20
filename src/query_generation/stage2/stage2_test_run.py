#!/usr/bin/env python3
"""
stage2_test_run.py - Run Stage 2 on specific test case sets.
"""

import os
import sys
import argparse
from pathlib import Path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from src.query_generation.stage2.stage2_main import Stage2Pipeline

# The 120 test cases (including tax cases)
DEFAULT_120_CASES = [
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
    's7703_a_2_neg', 's7703_a_2_pos', 's7703_b_2_neg', 's7703_b_2_pos'
]

def main():
    
    parser = argparse.ArgumentParser(description='Run Stage 2 on specific test sets.')
    parser.add_argument('--paper-100', action='store_true', help='Run on the 100 specific non-tax cases from the paper.')
    parser.add_argument('--subset', type=int, help='Run only the first N cases from the selected test set.')
    parser.add_argument('--run-name', help='Name for results directory (e.g., "run_100_v2").')
    parser.add_argument('--api-key', help='Gemini API key (or set GEMINI_API_KEY env var).')
    parser.add_argument('--batch-size', type=int, default=10, help='Batch size for rate limiting.')
    parser.add_argument('--delay', type=float, default=10.0, help='Delay between batches (seconds).')
    parser.add_argument('--start-from', type=int, default=0, help='Start from case index N.')
    parser.add_argument('--skip-existing', action='store_true', help='Skip cases that already have results.')
    
    args = parser.parse_args()
    
    # Test Case Selection 
    if args.paper_100:
        TEST_CASES = PAPER_100_CASES
        print("🎯 Running Stage 2 on the 100 specific non-tax paper cases.")
        default_run_name = "stage2_paper_100_test"
    else:
        TEST_CASES = DEFAULT_120_CASES
        print("🎯 Running Stage 2 on the default 120 test cases.")
        default_run_name = "stage2_default_120_test"

    api_key = args.api_key or os.getenv('GEMINI_API_KEY')
    if not api_key:
        try:
            from dotenv import load_dotenv
            env_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts/src/.env"
            if os.path.exists(env_path):
                load_dotenv(env_path)
                api_key = os.getenv('GEMINI_API_KEY')
        except ImportError:
            pass
    
    if not api_key:
        print("\n❌ Error: No Gemini API key provided!")
        print("Please provide via one of these methods:")
        print("1. Command line: --api-key YOUR_KEY")
        print("2. Environment variable: export GEMINI_API_KEY=YOUR_KEY")
        print("3. In your .env file: GEMINI_API_KEY=YOUR_KEY")
        sys.exit(1)
    
    print(f"✓ Using Gemini API key: {api_key[:10]}...")
    
    #  Case List Filtering
    case_files = [f"{case}.pl" for case in TEST_CASES]
    
    if args.start_from > 0:
        case_files = case_files[args.start_from:]
        print(f"📋 Starting from case index {args.start_from}")
    
    if args.subset:
        case_files = case_files[:args.subset]
        print(f"📋 Running subset: first {len(case_files)} cases from the selected set.")
    
    print(f"📋 Total cases to process: {len(case_files)}")
    
    try:
        # Pipeline Initialization and Execution 
        run_name = args.run_name or default_run_name
        pipeline = Stage2Pipeline(api_key=api_key, run_name=run_name)
        
        if args.skip_existing:
            remaining_cases = []
            for case_file in case_files:
                case_id = case_file.replace('.pl', '')
                query_file = pipeline.queries_dir / f"{case_id}.pl"
                if not query_file.exists():
                    remaining_cases.append(case_file)
                else:
                    print(f"  Skipping {case_id} (already exists)")
            
            case_files = remaining_cases
            print(f"📋 Cases remaining after filtering: {len(case_files)}")
        
        if not case_files:
            print("✅ No new cases to process!")
            return
        
        results = pipeline.run_batch(
            case_files,
            batch_size=args.batch_size,
            delay=args.delay
        )
        
        # Results Summary 
        if 'stats' in results:
            stats = results['stats']
            total_processed = stats.get('total_cases', 0)
            if total_processed > 0:
                 accuracy = (stats['correct_results'] / total_processed) * 100
                 print(f"\n📈 Performance on Test Set:")
                 print(f"   - Your Stage 2 result: {stats['correct_results']}/{total_processed} = {accuracy:.1f}% accuracy")
            else:
                print("\nNo cases were processed in this run.")
        
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
