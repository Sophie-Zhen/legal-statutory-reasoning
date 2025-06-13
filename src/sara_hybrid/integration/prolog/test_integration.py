"""
Test script to verify the Prolog integration functionality.
"""

import pandas as pd
import re
from pathlib import Path
from .prolog_utils import clean_prolog_code, run_prolog_query

# Get the directory where this file is located
CURRENT_DIR = Path(__file__).parent

def load_local_sara_dataset():
    """Load the SARA dataset from local files."""
    base_path = Path("data/sara_v3")
    cases_path = base_path / "cases"
    splits_path = base_path / "splits"
    
    # Read train and test splits
    with open(splits_path / "train", "r") as f:
        train_cases = [line.strip() for line in f if line.strip()]
    with open(splits_path / "test", "r") as f:
        test_cases = [line.strip() for line in f if line.strip()]
    
    # Process each case
    cases = []
    for case_id in train_cases + test_cases:
        case_file = cases_path / f"{case_id}.pl"
        if not case_file.exists():
            continue
            
        with open(case_file, "r") as f:
            content = f.read()
            
        # Extract sections using regex
        text_match = re.search(r"% Text\n(.*?)\n\n% Question", content, re.DOTALL)
        question_match = re.search(r"% Question\n(.*?)\n\n% Facts", content, re.DOTALL)
        facts_match = re.search(r"% Facts\n(.*?)\n\n% Test", content, re.DOTALL)
        test_match = re.search(r"% Test\n(.*?)(?:\n:-|$)", content, re.DOTALL)
        
        if all([text_match, question_match, facts_match, test_match]):
            cases.append({
                'id': case_id,
                'text': text_match.group(1).strip(),
                'question': question_match.group(1).strip(),
                'facts': facts_match.group(1).strip(),
                'test': test_match.group(1).strip(),
                'answer': 'Entailment' if '_pos' in case_id else 'Contradiction'
            })
    
    return pd.DataFrame(cases)

def test_simple_prolog():
    """Test basic Prolog functionality with a simple example."""
    print("\n=== Testing Simple Prolog Query ===")
    facts = """
    parent(john, mary).
    parent(mary, tom).
    grandparent(X, Y) :- parent(X, Z), parent(Z, Y).
    """
    query = "grandparent(john, tom)"
    
    result = run_prolog_query(facts, query)
    print(f"Simple query result: {result}")
    assert result == "true", "Simple Prolog query failed"

def get_question_type(case_id):
    """Determine if a question is numerical or logical based on case ID."""
    if 'pos' in case_id or 'neg' in case_id:
        return 'logical'
    return 'numerical'

def extract_numerical_answer(answer):
    """Extract numerical value from answer string."""
    # Remove any non-numeric characters except decimal point
    num_str = re.sub(r'[^\d.]', '', answer)
    try:
        return float(num_str)
    except ValueError:
        return None

def run_all_sara_cases():
    """Run all SARA cases and calculate accuracy statistics."""
    print("\n=== Running All SARA Cases ===")
    df_train = load_local_sara_dataset()
    total = len(df_train)
    correct_logical = 0
    correct_numerical = 0
    skipped = 0
    results = []
    
    for idx, row in df_train.iterrows():
        case_id = row['id']
        question = row['question']
        expected = row['answer']
        
        # Determine question type from case ID
        question_type = get_question_type(case_id)
        if question_type is None:
            skipped += 1
            continue
            
        cleaned_facts = clean_prolog_code(row['facts'])
        test_query = row['test'].strip(':- ')
        
        if case_id == 'tax_case_1':
            print("\n=== Generated Prolog Code for tax_case_1 ===")
            print(cleaned_facts)
            print("=== Query ===")
            print(test_query)
            print("=== End Generated Code ===")
        
        result = run_prolog_query(cleaned_facts, test_query)
        
        # Handle numerical questions (tax calculations)
        if question_type == 'numerical':
            expected_num = extract_numerical_answer(expected)
            result_num = extract_numerical_answer(result)
            is_correct = (expected_num is not None and result_num is not None and 
                         abs(expected_num - result_num) < 0.01)  # Allow small floating point differences
            if is_correct:
                correct_numerical += 1
            mapped_result = str(result_num) if result_num is not None else result
            
        # Handle logical questions (entailment/contradiction)
        else:  # logical
            mapped = 'Entailment' if result == 'true' else 'Contradiction'
            is_correct = (mapped.lower() == expected.lower())
            if is_correct:
                correct_logical += 1
            mapped_result = mapped
            
        results.append({
            'id': case_id,
            'question': question,
            'question_type': question_type,
            'expected': expected,
            'prolog_result': mapped_result,
            'is_correct': is_correct
        })
        
        if idx % 10 == 0:
            print(f"Processed {idx+1}/{total} cases...")
    
    # Calculate statistics
    processed = total - skipped
    logical_cases = sum(1 for r in results if r['question_type'] == 'logical')
    numerical_cases = sum(1 for r in results if r['question_type'] == 'numerical')
    
    logical_accuracy = (correct_logical / logical_cases * 100) if logical_cases > 0 else 0
    numerical_accuracy = (correct_numerical / numerical_cases * 100) if numerical_cases > 0 else 0
    overall_accuracy = ((correct_logical + correct_numerical) / processed * 100) if processed > 0 else 0
    
    print(f"\nProcessed {processed} cases (skipped {skipped} cases)")
    print(f"Logical questions: {logical_cases} cases, Accuracy: {logical_accuracy:.2f}% ({correct_logical}/{logical_cases})")
    print(f"Numerical questions: {numerical_cases} cases, Accuracy: {numerical_accuracy:.2f}% ({correct_numerical}/{numerical_cases})")
    print(f"Overall accuracy: {overall_accuracy:.2f}% ({correct_logical + correct_numerical}/{processed})")
    
    # Save results to CSV in the integration/prolog folder
    results_file = CURRENT_DIR / 'sara_prolog_results.csv'
    pd.DataFrame(results).to_csv(results_file, index=False)
    print(f"Results saved to {results_file}")

def test_sara_sample():
    """Test with a sample from the SARA dataset."""
    print("\n=== Testing SARA Dataset Sample ===")
    df_train = load_local_sara_dataset()
    print("\nAvailable columns in the dataset:")
    print(df_train.columns.tolist())
    sample_row = df_train.iloc[0]
    print(f"\nProcessing SARA case ID: {sample_row['id']}")
    print(f"Question: {sample_row['question']}")
    cleaned_facts = clean_prolog_code(sample_row['facts'])
    test_query = sample_row['test'].strip(':- ')
    result = run_prolog_query(cleaned_facts, test_query)
    print(f"SARA test query result: {result}")
    sample_row['result'] = result
    print(f"Expected answer: {sample_row['answer']}")

if __name__ == "__main__":
    print("Starting Prolog integration tests...")
    try:
        test_simple_prolog()
        test_sara_sample()
        run_all_sara_cases()
        print("\nAll tests completed successfully!")
    except Exception as e:
        print(f"\nError during testing: {e}")
        raise 