% Test runner for SARA legal reasoning system
% Run with: swipl -g "run_all_tests" -g halt run_tests.pl

:- use_module(tests).

% Run all tests and generate summary report
run_all_tests :-
    write('=== SARA Legal Reasoning Test Results ==='), nl,
    findall(CaseID, answer(CaseID, _), AllCases),
    length(AllCases, TotalCases),
    format('Total test cases: ~w~n~n', [TotalCases]),
    
    % Run tests and collect results
    findall(CaseID-success-Result, 
            (member(CaseID, AllCases), 
             catch(answer(CaseID, Result), Error, fail)), 
            SuccessResults),
    findall(CaseID-error-Error, 
            (member(CaseID, AllCases), 
             catch(answer(CaseID, _), Error, (Error \= fail))), 
            ErrorResults),
    findall(CaseID-timeout, 
            (member(CaseID, AllCases), 
             \+ catch(answer(CaseID, _), _, fail)), 
            TimeoutResults),
    
    % Print detailed results
    write('=== SUCCESSFUL CASES ==='), nl,
    print_results(SuccessResults),
    nl,
    
    write('=== FAILED CASES ==='), nl,
    print_results(ErrorResults),
    print_results(TimeoutResults),
    nl,
    
    % Print summary
    length(SuccessResults, SuccessCount),
    length(ErrorResults, ErrorCount),
    length(TimeoutResults, TimeoutCount),
    FailCount is ErrorCount + TimeoutCount,
    format('=== SUMMARY ===~n'),
    format('Successful: ~w/~w~n', [SuccessCount, TotalCases]),
    format('Failed: ~w/~w~n', [FailCount, TotalCases]),
    format('Success Rate: ~2f%~n', [SuccessCount * 100 / TotalCases]).

% Helper predicate to print results
print_results([]).
print_results([CaseID-Status-Result|Rest]) :-
    format('~w: ~w -> ~w~n', [CaseID, Status, Result]),
    print_results(Rest).
print_results([CaseID-Status|Rest]) :-
    format('~w: ~w~n', [CaseID, Status]),
    print_results(Rest).

% Test specific case types
test_entailment_cases :-
    write('=== ENTAILMENT/CONTRADICTION CASES ==='), nl,
    findall(CaseID-Result, 
            (answer(CaseID, Result), 
             (Result = true; Result = false)), 
            Results),
    print_results(Results),
    length(Results, Count),
    format('Total entailment cases: ~w~n', [Count]).

test_tax_calculation_cases :-
    write('=== TAX CALCULATION CASES ==='), nl,
    findall(CaseID-Result, 
            (answer(CaseID, Result), 
             number(Result)), 
            Results),
    print_results(Results),
    length(Results, Count),
    format('Total tax calculation cases: ~w~n', [Count]).

% Debug a specific case
debug_case(CaseID) :-
    format('=== DEBUGGING CASE: ~w ===~n', [CaseID]),
    (   fact(CaseID, Facts) ->
        format('Facts: ~w~n', [Facts])
    ;   format('No facts found for case ~w~n', [CaseID])
    ),
    (   catch(answer(CaseID, Result), Error, fail) ->
        format('Result: ~w~n', [Result])
    ;   var(Error) ->
        format('Failed to compute answer (no error)~n')
    ;   format('Error: ~w~n', [Error])
    ). 