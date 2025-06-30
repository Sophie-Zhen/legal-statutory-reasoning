#!/usr/bin/env python3
"""
Check available test cases
File: check_test_cases.py
"""
import os
import json

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"

# Check test split file
test_split_file = os.path.join(sara_path, "data/sara_v3/splits/test")
print("Checking test split file...")
if os.path.exists(test_split_file):
    with open(test_split_file, 'r') as f:
        test_cases = [line.strip() for line in f if line.strip()]
    print(f"Found {len(test_cases)} test cases in split file")
    print(f"First 10: {test_cases[:10]}")
    if 's151_d_1_neg' in test_cases:
        print("✓ s151_d_1_neg is in test split")
    else:
        print("✗ s151_d_1_neg is NOT in test split")
else:
    print("✗ Test split file not found!")

print("\n" + "="*50 + "\n")

# Check sara_parallel.jsonl
sara_parallel_file = os.path.join(sara_path, "data/sara_parallel.jsonl")
print("Checking sara_parallel.jsonl...")
if os.path.exists(sara_parallel_file):
    case_ids = []
    with open(sara_parallel_file, 'r') as f:
        for line in f:
            data = json.loads(line.strip())
            case_id = data.get('id', '')
            if case_id:
                case_ids.append(case_id)
    print(f"Found {len(case_ids)} cases in sara_parallel.jsonl")
    print(f"First 10: {case_ids[:10]}")
    if 's151_d_1_neg' in case_ids:
        print("✓ s151_d_1_neg is in sara_parallel.jsonl")
    else:
        print("✗ s151_d_1_neg is NOT in sara_parallel.jsonl")
        # Check if any similar case exists
        similar = [c for c in case_ids if 's151' in c]
        if similar:
            print(f"Similar cases found: {similar[:5]}")
else:
    print("✗ sara_parallel.jsonl not found!")

print("\n" + "="*50 + "\n")

# Check case files directory
cases_dir = os.path.join(sara_path, "data/sara_v3/cases")
print("Checking case files directory...")
if os.path.exists(cases_dir):
    case_files = [f for f in os.listdir(cases_dir) if f.endswith('.pl')]
    print(f"Found {len(case_files)} case files")
    if 's151_d_1_neg.pl' in case_files:
        print("✓ s151_d_1_neg.pl exists in cases directory")
    
    # Show some tax cases
    tax_cases = [f for f in case_files if f.startswith('tax_case')]
    if tax_cases:
        print(f"\nFound {len(tax_cases)} tax cases")
        print(f"Examples: {tax_cases[:5]}")