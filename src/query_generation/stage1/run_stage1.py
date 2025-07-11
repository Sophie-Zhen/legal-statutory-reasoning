#!/usr/bin/env python3
"""
Stage 1 Main Runner
File: src/query_generation/stage1/run_stage1.py
Generates only Prolog queries for SARA test cases
"""

import os
import sys
import json
import argparse
from datetime import datetime

# Add current directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from llm.gemini_client import GeminiClient
from core.query_generator import Stage1QueryGenerator
from core.case_parser import CaseParser

def main():
    parser = argparse.ArgumentParser(description='Run Stage 1 Query Generation')
    parser.add_argument('--test-single', type=str, help='Test a single case ID')
    parser.add_argument('--limit', type=int, help='Limit number of test cases to process')
    parser.add_argument('--sara-path', type=str, 
                       default='/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts',
                       help='Path to SARA dataset')
    
    args = parser.parse_args()
    
    # Load environment variables from .env file
    env_path = os.path.join(args.sara_path, 'src', '.env')
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value
        print(f"Loaded environment from: {env_path}")
    
    # Initialize LLM client - GeminiClient loads API key from environment
    print("Initializing Gemini client...")
    try:
        llm_client = GeminiClient()
        print("✓ Gemini client initialized successfully")
    except Exception as e:
        print(f"Error initializing Gemini client: {e}")
        print("Make sure GEMINI_API_KEY is set in your .env file")
        sys.exit(1)
    
    # Initialize query generator
    generator = Stage1QueryGenerator(args.sara_path, llm_client)
    
    # Create results directory with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_dir = f"stage1_results_{timestamp}"
    generator.results_dir = results_dir
    os.makedirs(results_dir, exist_ok=True)
    
    print(f"Results will be saved to: {results_dir}")
    
    if args.test_single:
        # Test single case
        print(f"\nTesting single case: {args.test_single}")
        
        # Load case
        case_parser = CaseParser(args.sara_path)
        
        # Use local sara_parallel.jsonl file
        sara_parallel_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sara_parallel.jsonl")
        if not os.path.exists(sara_parallel_path):
            sara_parallel_path = os.path.join(args.sara_path, "data/sara_parallel.jsonl")
            
        print(f"Loading cases from: {sara_parallel_path}")
        
        # Use the parse_sara_parallel_file method
        all_cases = case_parser.parse_sara_parallel_file(sara_parallel_path, filter_test_only=False)
        
        if args.test_single not in all_cases:
            print(f"Error: Case {args.test_single} not found in sara_parallel.jsonl")
            print(f"Available cases: {list(all_cases.keys())[:10]}...")
            sys.exit(1)
        
        test_case = all_cases[args.test_single]
        statute_files = case_parser.load_statute_files()
        
        # Run single case
        result = generator.run_single_case(test_case, statute_files)
        
        # Print detailed result
        print(f"\nResults for {args.test_single}:")
        print(f"  Success: {result['success']}")
        print(f"  Correct: {result['correct']}")
        print(f"  Result: {result['result']}")
        if result['error']:
            print(f"  Error: {result['error']}")
        
        print(f"\nGenerated Query:")
        print(result['query_code'])
        
    else:
        # Run all test cases
        print("\nRunning Stage 1 for all test cases...")
        
        if args.limit:
            print(f"Limiting to first {args.limit} cases")
        
        results = generator.run_all_test_cases(limit=args.limit)
        
        # Save final results
        results_file = os.path.join(results_dir, 'final_results.json')
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        print(f"\nFinal results saved to: {results_file}")
        
        # Also create a CSV for easy analysis
        import csv
        csv_file = os.path.join(results_dir, 'results.csv')
        with open(csv_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['case_id', 'question_type', 'success', 'correct', 'result', 'error'])
            writer.writeheader()
            for r in results:
                writer.writerow({
                    'case_id': r['case_id'],
                    'question_type': r['question_type'],
                    'success': r['success'],
                    'correct': r['correct'],
                    'result': r['result'],
                    'error': r['error'] or ''
                })
        
        print(f"CSV results saved to: {csv_file}")

if __name__ == "__main__":
    main()