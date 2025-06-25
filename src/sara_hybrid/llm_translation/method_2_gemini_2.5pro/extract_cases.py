#!/usr/bin/env python3
import os
import random
import re

def extract_case_info(file_path):
    """Extract case id, text, and question from a case file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract case id from filename
    case_id = os.path.basename(file_path).replace('.pl', '')
    
    # Extract text (content between % Text and % Question)
    text_match = re.search(r'% Text\s*\n(.*?)\n\s*% Question', content, re.DOTALL)
    text = text_match.group(1).strip() if text_match else ""
    
    # Extract question (content between % Question and % Facts)
    question_match = re.search(r'% Question\s*\n(.*?)\n\s*% Facts', content, re.DOTALL)
    question = question_match.group(1).strip() if question_match else ""
    
    return case_id, text, question

def read_train_split_cases(train_split_path):
    """Read case IDs from train split file."""
    with open(train_split_path, 'r', encoding='utf-8') as f:
        case_ids = [line.strip() for line in f if line.strip()]
    return case_ids

def separate_cases_by_prefix(case_ids):
    """Separate cases into 's' cases and 'tax' cases."""
    s_cases = [case_id for case_id in case_ids if case_id.startswith('s')]
    tax_cases = [case_id for case_id in case_ids if case_id.startswith('tax')]
    return s_cases, tax_cases

def main():
    cases_dir = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/data/sara_v3/cases"
    train_split_path = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/data/sara_v3/splits/train"
    
    # Read train split cases
    print("Reading train split cases...")
    train_case_ids = read_train_split_cases(train_split_path)
    print(f"Total train cases: {len(train_case_ids)}")
    
    # Separate cases by prefix
    s_cases, tax_cases = separate_cases_by_prefix(train_case_ids)
    print(f"S cases: {len(s_cases)}")
    print(f"Tax cases: {len(tax_cases)}")
    
    # Randomly select 18 s cases and 8 tax cases
    selected_s_cases = random.sample(s_cases, min(18, len(s_cases)))
    selected_tax_cases = random.sample(tax_cases, min(8, len(tax_cases)))
    
    # Combine selected cases
    selected_case_ids = selected_s_cases + selected_tax_cases
    print(f"Selected {len(selected_s_cases)} s cases and {len(selected_tax_cases)} tax cases")
    
    # Extract information from selected cases
    cases_info = []
    for case_id in selected_case_ids:
        file_path = os.path.join(cases_dir, f"{case_id}.pl")
        if os.path.exists(file_path):
            case_id, text, question = extract_case_info(file_path)
            cases_info.append({
                'case_id': case_id,
                'text': text,
                'question': question
            })
        else:
            print(f"Warning: File not found for case {case_id}")
    
    # Write to output file
    output_file = "src/sara_hybrid/llm_translation/method_2_gemini_2.5pro/selected_cases.txt"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("Selected 26 Cases from Train Split\n")
        f.write("=" * 50 + "\n\n")
        f.write(f"18 S cases and 8 Tax cases\n\n")
        
        # Write S cases first
        f.write("S CASES:\n")
        f.write("-" * 20 + "\n")
        s_cases_info = [case for case in cases_info if case['case_id'].startswith('s')]
        for i, case in enumerate(s_cases_info, 1):
            f.write(f"S Case {i}:\n")
            f.write(f"Case ID: {case['case_id']}\n")
            f.write(f"Text: {case['text']}\n")
            f.write(f"Question: {case['question']}\n")
            f.write("-" * 50 + "\n\n")
        
        # Write Tax cases
        f.write("TAX CASES:\n")
        f.write("-" * 20 + "\n")
        tax_cases_info = [case for case in cases_info if case['case_id'].startswith('tax')]
        for i, case in enumerate(tax_cases_info, 1):
            f.write(f"Tax Case {i}:\n")
            f.write(f"Case ID: {case['case_id']}\n")
            f.write(f"Text: {case['text']}\n")
            f.write(f"Question: {case['question']}\n")
            f.write("-" * 50 + "\n\n")
    
    print(f"Successfully extracted information from {len(cases_info)} cases to {output_file}")
    print("\nSelected S case IDs:")
    for case_id in selected_s_cases:
        print(f"  - {case_id}")
    print("\nSelected Tax case IDs:")
    for case_id in selected_tax_cases:
        print(f"  - {case_id}")

if __name__ == "__main__":
    main() 