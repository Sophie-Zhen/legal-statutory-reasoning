```prolog
%
% Facts for the case narrative
%

% The taxable year is 2024.
taxable_year(2024).

% Bob and Alice are married and file a joint return.
% 'bob_and_alice' is the atom representing their joint filing unit.
filer(bob_and_alice).
joint_return(bob_and_alice).
party_to_joint_return(bob, bob_and_alice).
party_to_joint_return(alice, bob_and_alice).
married(bob, alice).
spouse_of(bob, alice).
spouse_of(alice, bob).
married_at_close_of_year(bob, alice, 2024).

% Their adjusted gross income is $150,000.
adjusted_gross_income(bob_and_alice, 150000).

% They do not itemize their deductions.
itemizes_deductions(bob_and_alice, false).

% Bob is 66 years old.
person(bob).
age(bob, 66).

% Alice is 64 years old.
person(alice).
age(alice, 64).

% Neither Bob nor Alice is blind.
is_blind(bob, false).
is_blind(alice, false).

% They have one child, Charles, who is 18 years old.
person(charles).
child_of(charles, bob).
child_of(charles, alice).
age(charles, 18).

% Charles lives with them for the entire year.
% This satisfies the "more than one-half of such taxable year" requirement.
principal_abode_for_more_than_half_year(charles, bob_and_alice).

% Charles has no income and does not file a joint return.
gross_income(charles, 0).
% The fact that Charles does not file a joint return is represented
% by the absence of a joint_return/1 fact for him.

% Bob and Alice provide more than half of the cost of maintaining their household.
furnishes_over_half_cost_of_household(bob_and_alice).


%
% Query for the case
%

% What is the tax liability for Bob and Alice?
% The calculated tax liability is 31402.5.
% Taxable Income = 150000 (AGI) - 24000 (Base STD) - 600 (Age) - 0 (Exemptions) = 125400.
% Tax = 20165 + (125400 - 89150) * 0.31 = 20165 + 36250 * 0.31 = 20165 + 11237.5 = 31402.5.
case_query(Result) :-
    ( tax_liability(bob_and_alice, 31402.5) ->
        Result = true
    ;
        Result = false
    ).
```

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT