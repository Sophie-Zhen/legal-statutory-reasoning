from datasets import load_dataset
import pandas as pd
import numpy as np
import subprocess
import tempfile
import os

print('=====================')
ds = load_dataset("jhu-clsp/SARA")

df_train = pd.DataFrame(ds['train'])

def clean_prolog_code(code):
    # Remove the line that tries to load the init file which is not available
    lines = code.split('\n')
    cleaned_lines = []
    
    # Add discontiguous declarations for all predicates
    cleaned_lines.extend([
        ":- discontiguous s151_a/3.",
        ":- discontiguous s151_b/3.",
        ":- discontiguous s151_b/4.",
        ":- discontiguous s151_c/4.",
        ":- discontiguous s152_c_1/3.",
        ":- discontiguous income_/1.",
        ":- discontiguous agent_/2.",
        ":- discontiguous start_/2.",
        ":- discontiguous end_/2.",
        ":- discontiguous amount_/2.",
        ":- discontiguous marriage_/1.",
        ":- discontiguous joint_return_/1."
    ])
    
    # Add predicate definitions
    cleaned_lines.extend([
        "s151_a(Person, Amount, Year) :- s151_c(Person, _, Amount, Year).",
        "s151_b(Person1, Person2, Year) :- marriage_(M), agent_(M, Person1), agent_(M, Person2), start_(M, Start), sub_string(Start, 0, 4, _, YearStr), atom_number(YearStr, Year).",
        "s151_b(Person1, Person2, Amount, Year) :- s151_b(Person1, Person2, Year), s151_a(Person1, Amount, Year)."
    ])
    
    for line in lines:
        if not line.strip().startswith(':- [statutes/prolog/init]'):
            # Add a period at the end if missing
            line = line.strip()
            if line and not line.endswith('.'):
                line += '.'
            cleaned_lines.append(line)
    
    # Add a wrapper predicate for negation queries
    if any('\\+' in line for line in lines):
        cleaned_lines.append("query :- \\+ target.")
    else:
        cleaned_lines.append("query :- target.")
        
    return '\n'.join(cleaned_lines)

def run_prolog_query(facts, query):
    # Create a temporary file for the Prolog code
    with tempfile.NamedTemporaryFile(mode='w', suffix='.pl', delete=False) as f:
        # Write the facts
        f.write(facts)
        f.write('\n')
        
        # Write the target predicate
        if query.startswith('\\+'):
            # Remove the negation operator for the target
            target = query[2:].strip()
        else:
            target = query
        if not target.strip().endswith('.'):
            target = target.strip() + '.'
        f.write(f"target :- {target}\n")
        
        temp_file = f.name
        print(f"\nWriting to {temp_file}:")
        print("=== Facts and Rules ===")
        print(facts)
        print("=== Query ===")
        print(f"query.")

    try:
        # Run SWI-Prolog with the temporary file
        cmd = ['/opt/homebrew/Cellar/swi-prolog/9.2.9/bin/swipl', '-s', temp_file, '-g', 'query', '-t', 'halt']
        print(f"\nRunning command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"Return code: {result.returncode}")
        print(f"Stdout: {result.stdout}")
        print(f"Stderr: {result.stderr}")
        
        # If return code is 0, the query succeeded
        # If return code is 1, the query failed
        # This matches Prolog's behavior where success means the query is true
        # and failure means the query is false
        if result.returncode == 0:
            return "true"
        elif result.returncode == 1:
            return "false"
        else:
            return "error"
    except Exception as e:
        print(f"Error running Prolog query: {e}")
        return None
    finally:
        # Clean up the temporary file
        os.unlink(temp_file)

# Only process the first few rows for testing
for idx, row in df_train.head(5).iterrows():
    print(f"\nProcessing row {idx}")
    # Load facts and rules
    cleaned_facts = clean_prolog_code(row['facts'])
    test_query = row['test'].strip(':- ')
    
    try:
        result = run_prolog_query(cleaned_facts, test_query)
        df_train.at[idx, 'result'] = result
        print(f"Test query result: {result}")
    except Exception as e:
        print(f"Error executing test query: {e}")

df_train.to_csv('sara_test_results.csv', index=False)