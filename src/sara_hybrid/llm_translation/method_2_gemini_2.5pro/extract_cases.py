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

def main():
    cases_dir = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/data/sara_v3/cases"
    
    # Get all .pl files in the cases directory
    case_files = [f for f in os.listdir(cases_dir) if f.endswith('.pl')]
    
    # Randomly select 20 cases
    selected_files = random.sample(case_files, min(20, len(case_files)))
    
    # Extract information from selected cases
    cases_info = []
    for filename in selected_files:
        file_path = os.path.join(cases_dir, filename)
        case_id, text, question = extract_case_info(file_path)
        cases_info.append({
            'case_id': case_id,
            'text': text,
            'question': question
        })
    
    # Write to output file
    output_file = "selected_cases.txt"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("Randomly Selected 20 Cases\n")
        f.write("=" * 50 + "\n\n")
        
        for i, case in enumerate(cases_info, 1):
            f.write(f"Case {i}:\n")
            f.write(f"Case ID: {case['case_id']}\n")
            f.write(f"Text: {case['text']}\n")
            f.write(f"Question: {case['question']}\n")
            f.write("-" * 50 + "\n\n")
    
    print(f"Successfully extracted information from {len(cases_info)} cases to {output_file}")
    print("Selected case IDs:")
    for case in cases_info:
        print(f"  - {case['case_id']}")

if __name__ == "__main__":
    main() 