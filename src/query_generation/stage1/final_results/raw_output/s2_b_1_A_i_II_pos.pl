```prolog
%
% Part 1: Prolog facts that formalize the CASE NARRATIVE
%

% The taxable year in question.
year(2024).

% Individuals involved in the case.
person(bob).
person(charlie).

% Details for Bob.
age(bob, 45).
unmarried(bob, 2024).
adjusted_gross_income(bob, 2024, 150000).
itemizes_deductions(bob, 2024, false).
furnished_over_half_of_household_cost(bob, 2024).

% Details for Charlie.
age(charlie, 20).
unmarried(charlie, 2024).
earned_income(charlie, 2024, 5000).
filed_joint_return(charlie, 2024, false).

% Relationships and living situation.
child_of(charlie, bob).
% "Lived with Bob for the entire year" satisfies the "more than one-half" rule.
principal_place_of_abode_of(charlie, bob, 2024).

%
% Part 2: A single `case_query(Result)` predicate that translates the QUESTION
%

% QUESTION: Is Bob a head of household?
% This query checks if Bob meets the definition of a "head of a household"
% under §2(b) for the taxable year 2024. The predicate
% `is_head_of_household(Person, Year)` is the logical construct that
% would be defined by a Prolog implementation of the statutes.
case_query(Result) :-
    ( is_head_of_household(bob, 2024) ->
        Result = true
    ;
        Result = false
    ).
```

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT