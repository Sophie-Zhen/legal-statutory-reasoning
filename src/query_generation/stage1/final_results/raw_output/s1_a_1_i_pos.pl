```prolog
%
% facts representing the CASE NARRATIVE
%

% The year is 2024.
tax_year(2024).

% Bob is 45 years old.
person(bob).
age(bob, 45).

% He is not married.
is_married(bob, false).

% Bob's adjusted gross income is $150,000.
adjusted_gross_income(bob, 150000).

% He does not itemize his deductions.
itemizes_deductions(bob, false).

% Bob has a son, Charlie, who is 15 years old.
person(charlie).
relationship(charlie, bob, son).
age(charlie, 15).

% Charlie lived with Bob for the entire year.
lived_with_for_more_than_half_year(charlie, bob).

% Charlie has no income.
gross_income(charlie, 0).

% Charlie did not file a joint return.
filed_joint_return(charlie, false).

% Bob provided more than half of the cost of maintaining the household.
furnished_over_half_of_household_cost(bob).

% Implicit facts for rule completeness
is_nonresident_alien(bob, false).
is_nonresident_alien(charlie, false).
spouse_died_in_preceding_two_years(bob, false).
is_legally_separated(bob, false).
is_married(charlie, false).


%
% case_query that translates the QUESTION
%

% QUESTION: Is Bob a head of household?
% This corresponds to §2(b) Definition of head of household.
case_query(Result) :-
    ( head_of_household(bob) ->
        Result = true
    ;
        Result = false
    ).

```

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT