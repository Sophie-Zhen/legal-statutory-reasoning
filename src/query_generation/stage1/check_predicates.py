import os
import re

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
statutes_dir = os.path.join(sara_path, "data/sara_v3/statutes/prolog")

# Files to check
files_to_check = ['section1.pl', 'section2.pl', 'section63.pl', 'section7703.pl']

for filename in files_to_check:
    filepath = os.path.join(statutes_dir, filename)
    print(f"\n=== {filename} ===")
    
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Find predicate definitions (look for :- at start of line)
        predicates = []
        for line in content.split('\n'):
            if line.strip() and not line.strip().startswith('%'):
                # Look for predicate heads
                match = re.match(r'^(\w+)\((.*?)\)\s*:-', line)
                if match:
                    pred_name = match.group(1)
                    args = match.group(2)
                    arg_count = len([a.strip() for a in args.split(',') if a.strip()])
                    predicates.append(f"{pred_name}/{arg_count}")
        
        # Show unique predicates
        unique_preds = sorted(set(predicates))
        for pred in unique_preds[:10]:  # Show first 10
            print(f"  {pred}")
        
        # Special check for s1_X predicates
        s1_preds = [p for p in unique_preds if p.startswith('s1_')]
        if s1_preds:
            print(f"\n  Section 1 predicates: {s1_preds}")