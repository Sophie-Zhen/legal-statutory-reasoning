import os
import re

# Paths
ANALYSIS_PATH = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/src/gpt-statutes/sara_run/results_num/numerical_analysis.txt"
TEST_SPLIT_PATH = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/data/sara_v3/splits/test"
CASES_DIR = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/data/sara_v3/cases"
OUTPUT_PATH = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/src/gpt-statutes/sara_run/results_num/test_split_analysis.txt"

# Helper to extract case id from a question by matching to a case file
# We'll use the first line of each case file as a signature to match

def extract_question_prefixes(analysis_path):
    """Extract everything before 'How much' from each correct question."""
    prefixes = []
    with open(analysis_path, 'r') as f:
        lines = f.readlines()
    in_questions = False
    for line in lines:
        if line.strip().startswith('Questions with correct answers:'):
            in_questions = True
            continue
        if in_questions:
            if line.strip().startswith('RUNNING:'):
                q = line.strip()[len('RUNNING: '):]
                idx = q.lower().find('how much')
                if idx != -1:
                    prefix = q[:idx].strip()
                    prefixes.append(prefix)
            elif line.strip() == '':
                continue
            else:
                break
    return prefixes

def parse_case_texts(cases_dir):
    """For each .pl file, extract content after '% Text' and before '% Question', map to case id."""
    case_texts = {}
    for fname in os.listdir(cases_dir):
        if fname.endswith('.pl'):
            case_id = fname[:-3]
            fpath = os.path.join(cases_dir, fname)
            with open(fpath, 'r') as f:
                lines = f.readlines()
            text = []
            in_text = False
            for line in lines:
                if line.strip().startswith('% Text'):
                    in_text = True
                    continue
                if line.strip().startswith('% Question'):
                    break
                if in_text:
                    # Remove leading '% ' if present
                    l = line.strip()
                    if l.startswith('% '):
                        l = l[2:]
                    elif l.startswith('%'):
                        l = l[1:]
                    text.append(l)
            case_texts[case_id] = ' '.join(text).strip()
    return case_texts

def load_test_case_ids(test_split_path):
    with open(test_split_path, 'r') as f:
        return set(line.strip() for line in f if line.strip())

def match_prefixes_to_cases(prefixes, case_texts):
    """For each prefix, find if it is a substring of any case's extracted text, return the case id."""
    matched_case_ids = set()
    for prefix in prefixes:
        for case_id, case_text in case_texts.items():
            if prefix and prefix in case_text:
                matched_case_ids.add(case_id)
                break
    return matched_case_ids

def main():
    prefixes = extract_question_prefixes(ANALYSIS_PATH)
    case_texts = parse_case_texts(CASES_DIR)
    test_case_ids = load_test_case_ids(TEST_SPLIT_PATH)
    matched_case_ids = match_prefixes_to_cases(prefixes, case_texts)
    correct_test_cases = matched_case_ids & test_case_ids
    output_lines = []
    output_lines.append(f"Correctly answered test cases: {len(correct_test_cases)} / 20")
    output_lines.append(f"Percentage: {100.0 * len(correct_test_cases) / 20:.2f}%")
    output_lines.append("Case IDs:")
    for cid in sorted(correct_test_cases):
        output_lines.append(cid)
    # Print to stdout
    for line in output_lines:
        print(line)
    # Save to file
    with open(OUTPUT_PATH, 'w') as f:
        for line in output_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    main() 