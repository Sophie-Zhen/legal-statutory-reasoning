import subprocess
import os

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
test_file = "test_available.pl"

# Create a test file to check available predicates
with open(test_file, 'w') as f:
    f.write(f"""
:- working_directory(_, '{sara_path}/data/sara_v3').
:- consult('statutes/prolog/init.pl').
:- consult('cases/s1_d_iv_neg.pl').

test :-
    % Check what person exists
    (person(P) -> format('Person: ~w~n', [P]) ; write('No person/1 found\\n')),
    % Check what year
    (year(Y) -> format('Year: ~w~n', [Y]) ; write('No year/1 found\\n')),
    % Check filing status
    (finance(1,alice), s7703(alice,_,2017,_) -> write('Alice is married\\n') ; write('Marriage status unclear\\n')),
    % Try to calculate tax
    (s1_d(alice,2017,_,28864,Tax) -> format('Tax from s1_d/5: ~w~n', [Tax]) ; write('s1_d/5 failed\\n')),
    % Check taxable income
    (finance(alice,2017,_,_,_,TaxInc,_,_,_,_,_) -> format('Taxable income: ~w~n', [TaxInc]) ; write('No finance facts\\n')),
    halt(0).

:- initialization(test).
""")

# Run it
result = subprocess.run(['swipl', '-g', 'true', '-t', 'halt(1)', test_file], 
                       capture_output=True, text=True, timeout=5)

print("Output:")
print(result.stdout)
if result.stderr:
    print("\nErrors:")
    print(result.stderr)

# Clean up
os.remove(test_file)