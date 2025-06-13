"""
Core utilities for Prolog integration.
"""

import subprocess
import tempfile
import os
import re
from pathlib import Path

def get_swipl_path():
    """Get the path to the SWI-Prolog executable."""
    # Try common locations
    possible_paths = [
        '/opt/homebrew/Cellar/swi-prolog/9.2.9/bin/swipl',  # macOS Homebrew
        '/usr/bin/swipl',  # Linux
        'swipl'  # If it's in PATH
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
        try:
            result = subprocess.run(['which', 'swipl'], capture_output=True, text=True)
            if result.returncode == 0:
                return result.stdout.strip()
        except:
            continue
    
    raise Exception("Could not find SWI-Prolog executable. Please install it or specify the path.")

def get_required_statutes(facts):
    """Determine which statute files need to be loaded based on the facts."""
    statutes = set()
    statute_pattern = r's(\d+)_'
    
    # Find all section numbers in the facts
    matches = re.finditer(statute_pattern, facts)
    for match in matches:
        section_num = match.group(1)
        statutes.add(f"section{section_num}.pl")
    
    # Always include utils.pl and init.pl
    statutes.update(['utils.pl', 'init.pl'])
    return statutes

def clean_prolog_code(code):
    """Clean and prepare Prolog code for execution."""
    lines = code.split('\n')
    cleaned_lines = []
    
    # Get required statutes
    statutes = get_required_statutes(code)
    statute_path = Path("data/sara_v3/statutes/prolog")
    
    # Add statute loading
    for statute in statutes:
        if (statute_path / statute).exists():
            cleaned_lines.append(f":- ['{statute_path}/{statute}'].")
    
    # Add common predicate declarations
    common_predicates = [
        "income_/1", "agent_/2", "start_/2", "end_/2", "amount_/2",
        "marriage_/1", "joint_return_/1", "tax/3"
    ]
    
    for pred in common_predicates:
        cleaned_lines.append(f":- discontiguous {pred}.")
    
    # Add section-specific predicate declarations
    section_pattern = r's(\d+)_[a-z]'
    section_predicates = set()
    for line in lines:
        matches = re.finditer(section_pattern, line)
        for match in matches:
            section_num = match.group(1)
            section_predicates.add(f"s{section_num}_a/3")
            section_predicates.add(f"s{section_num}_b/3")
            section_predicates.add(f"s{section_num}_b/4")
            section_predicates.add(f"s{section_num}_c/3")
            section_predicates.add(f"s{section_num}_c/4")
            section_predicates.add(f"s{section_num}_d/3")
    
    for pred in section_predicates:
        cleaned_lines.append(f":- discontiguous {pred}.")
    
    # Add the facts and rules
    for line in lines:
        if not line.strip().startswith(':- [statutes/prolog/init]'):
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
    """Run a Prolog query with the given facts."""
    # Create a temporary file for the Prolog code
    with tempfile.NamedTemporaryFile(mode='w', suffix='.pl', delete=False) as f:
        # Write the facts
        f.write(facts)
        f.write('\n')
        
        # Write the target predicate
        if query.startswith('\\+'):
            target = query[2:].strip()
        else:
            target = query
        if not target.strip().endswith('.'):
            target = target.strip() + '.'
        f.write(f"target :- {target}\n")
        
        # For numerical queries, we need to write the result to stdout
        if 'tax(' in target:
            # Write a more robust query that handles numerical results
            f.write("query :- target, format('~w', [target]).\n")
        else:
            f.write("query :- target.\n")
        
        temp_file = f.name
        print(f"\nWriting to {temp_file}:")
        print("=== Facts and Rules ===")
        print(facts)
        print("=== Query ===")
        print(f"query.")

    try:
        # Get SWI-Prolog path
        swipl_path = get_swipl_path()
        
        # Run SWI-Prolog with the temporary file
        cmd = [swipl_path, '-s', temp_file, '-g', 'query', '-t', 'halt']
        print(f"\nRunning command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"Return code: {result.returncode}")
        print(f"Stdout: {result.stdout}")
        print(f"Stderr: {result.stderr}")
        
        # Handle numerical results
        if 'tax(' in query:
            try:
                # More robust pattern matching for tax results
                patterns = [
                    r'tax\([^,]+,\s*(\d+\.?\d*),\s*\d+\)',  # Original pattern
                    r'tax\([^,]+,\s*(\d+),\s*\d+\)',        # Integer only
                    r'tax\([^,]+,\s*(\d+\.\d+),\s*\d+\)',   # Decimal only
                    r'tax\([^,]+,\s*(\d+\.?\d*)\)'          # No year
                ]
                
                for pattern in patterns:
                    match = re.search(pattern, result.stdout)
                    if match:
                        # Convert to float and round to 2 decimal places
                        tax_amount = float(match.group(1))
                        return str(round(tax_amount, 2))
                
                # If no pattern matches, try to extract any number after "tax"
                match = re.search(r'tax.*?(\d+\.?\d*)', result.stdout)
                if match:
                    tax_amount = float(match.group(1))
                    return str(round(tax_amount, 2))
                    
            except Exception as e:
                print(f"Error parsing numerical result: {e}")
                return None
        
        # Handle boolean results
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