import subprocess
import os

sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
test_file = "find_pattern.pl"

with open(test_file, 'w') as f:
    f.write(f"""
:- working_directory(_, '{sara_path}/data/sara_v3').
:- consult('statutes/prolog/init.pl').
:- consult('cases/s3306_c_5_pos.pl').

test :-
    write('Finding s3306_c_5/4 patterns that succeed:\\n'),
    findall([E1,E2,E3,E4], s3306_c_5(E1,E2,E3,E4), Results),
    length(Results, Count),
    format('Found ~w results~n', [Count]),
    (Count > 0 -> 
        (member(First, Results), format('Example: s3306_c_5(~w)~n', [First])) 
        ; true),
    halt(0).

:- initialization(test).
""")

result = subprocess.run(['swipl', '-g', 'true', '-t', 'halt(1)', test_file], 
                       capture_output=True, text=True, timeout=5)
print(result.stdout)

os.remove(test_file)