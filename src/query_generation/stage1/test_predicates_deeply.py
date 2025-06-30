import subprocess
import os

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
test_file = "deep_test.pl"

# Create a comprehensive test
with open(test_file, 'w') as f:
    f.write(f"""
:- working_directory(_, '{sara_path}/data/sara_v3').
:- consult('statutes/prolog/init.pl').
:- consult('cases/s1_d_iv_neg.pl').

test :-
    write('=== Testing tax/3 ===\\n'),
    (tax(alice, 2017, Tax) -> format('tax(alice, 2017, ~w)~n', [Tax]) ; write('tax(alice, 2017, X) failed\\n')),
    
    write('\\n=== Testing s1_d/5 ===\\n'),
    (s1_d(alice, 2017, _, 28864, Tax) -> format('s1_d(alice, 2017, _, 28864, ~w)~n', [Tax]) ; write('s1_d failed\\n')),
    
    write('\\n=== Testing s1_d_iv/2 directly ===\\n'),
    (s1_d_iv(28864, Tax) -> format('s1_d_iv(28864, ~w)~n', [Tax]) ; write('s1_d_iv(28864, X) failed\\n')),
    
    write('\\n=== What facts exist? ===\\n'),
    forall(s7703(A,B,C,D), format('s7703(~w,~w,~w,~w)~n', [A,B,C,D])),
    forall(s63(A,B,C), format('s63(~w,~w,~w)~n', [A,B,C])),
    
    write('\\n=== Testing the expected query pattern ===\\n'),
    (s1_d_iv(28864, 5683) -> write('s1_d_iv(28864, 5683) succeeds\\n') ; write('s1_d_iv(28864, 5683) fails\\n')),
    
    halt(0).

:- initialization(test).
""")

# Run it
result = subprocess.run(['swipl', '-g', 'true', '-t', 'halt(1)', test_file], 
                       capture_output=True, text=True, timeout=5)

print("Output:")
print(result.stdout)
if result.stderr:
    print("\nWarnings (ignoring redefinition warnings):")
    # Filter out redefinition warnings
    for line in result.stderr.split('\n'):
        if 'Redefined' not in line and 'Warning:' not in line and line.strip():
            print(line)

os.remove(test_file)

# Test s3306_c_5 case too
print("\n\n=== Testing s3306_c_5_pos case ===")
test_file2 = "test_s3306.pl"
with open(test_file2, 'w') as f:
    f.write(f"""
:- working_directory(_, '{sara_path}/data/sara_v3').
:- consult('statutes/prolog/init.pl').
:- consult('cases/s3306_c_5_pos.pl').

test :-
    write('Testing s3306_c_5/4:\\n'),
    (s3306_c_5(alice, bob, _, 2017) -> write('s3306_c_5(alice, bob, _, 2017) succeeds\\n') 
     ; write('s3306_c_5(alice, bob, _, 2017) fails\\n')),
    
    write('\\nTrying different patterns:\\n'),
    (s3306_c_5(_, _, _, 2017) -> write('s3306_c_5(_, _, _, 2017) succeeds\\n') 
     ; write('s3306_c_5(_, _, _, 2017) fails\\n')),
     
    halt(0).

:- initialization(test).
""")

result2 = subprocess.run(['swipl', '-g', 'true', '-t', 'halt(1)', test_file2], 
                        capture_output=True, text=True, timeout=5)
print("Output:")
print(result2.stdout)

os.remove(test_file2)