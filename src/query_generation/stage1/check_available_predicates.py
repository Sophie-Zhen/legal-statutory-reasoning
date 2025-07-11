import subprocess
import os

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
test_file = "check_predicates.pl"

# Create a test file to list available predicates
with open(test_file, 'w') as f:
    f.write(f"""
:- working_directory(_, '{sara_path}/data/sara_v3').
:- consult('statutes/prolog/init.pl').

test :-
    % Check for income/tax related predicates
    write('=== Tax calculation predicates ===\\n'),
    (current_predicate(income_tax/3) -> write('income_tax/3 exists\\n') ; true),
    (current_predicate(tax/3) -> write('tax/3 exists\\n') ; true),
    (current_predicate(income_tax_s1/3) -> write('income_tax_s1/3 exists\\n') ; true),
    
    % Check s3306_c_5 arity
    write('\\n=== s3306_c_5 predicates ===\\n'),
    (current_predicate(s3306_c_5/3) -> write('s3306_c_5/3 exists\\n') ; true),
    (current_predicate(s3306_c_5/4) -> write('s3306_c_5/4 exists\\n') ; true),
    (current_predicate(s3306_c_5/5) -> write('s3306_c_5/5 exists\\n') ; true),
    
    % Check s1_d predicates
    write('\\n=== s1_d predicates ===\\n'),
    (current_predicate(s1_d/5) -> write('s1_d/5 exists\\n') ; true),
    (current_predicate(s1_d_iv/2) -> write('s1_d_iv/2 exists\\n') ; true),
    
    % List all predicates starting with 'tax'
    write('\\n=== All tax* predicates ===\\n'),
    forall(
        (current_predicate(F/A), atom_chars(F, Chars), append(['t','a','x'], _, Chars)),
        format('~w/~w~n', [F, A])
    ),
    
    halt(0).

:- initialization(test).
""")

# Run it
result = subprocess.run(['swipl', '-g', 'true', '-t', 'halt(1)', test_file], 
                       capture_output=True, text=True, timeout=5)

print("Output:")
print(result.stdout)
if result.stderr:
    print("\nWarnings/Errors:")
    print(result.stderr)

# Clean up
os.remove(test_file)

# Also check a specific case to see what's available
print("\n\n=== Checking s1_d_iv_neg case ===")
test_file2 = "check_case.pl"
with open(test_file2, 'w') as f:
    f.write(f"""
:- working_directory(_, '{sara_path}/data/sara_v3').
:- consult('statutes/prolog/init.pl').
:- consult('cases/s1_d_iv_neg.pl').

test :-
    write('Testing s1_d_iv/2 with values from case:\\n'),
    (s1_d_iv(28864, Tax) -> format('s1_d_iv(28864, ~w)~n', [Tax]) ; write('s1_d_iv/2 failed\\n')),
    halt(0).

:- initialization(test).
""")

result2 = subprocess.run(['swipl', '-g', 'true', '-t', 'halt(1)', test_file2], 
                        capture_output=True, text=True, timeout=5)
print("Output:")
print(result2.stdout)
if result2.stderr:
    print("\nWarnings/Errors:")
    print(result2.stderr)

os.remove(test_file2)