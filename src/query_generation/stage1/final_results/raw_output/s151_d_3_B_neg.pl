```prolog
% Facts for the case narrative
% The taxable year is 2024.
taxable_year(r1, 2024).

% Bob and Alice are married to each other. They file a joint return.
filer(r1, bob).
filer(r1, alice).
files_joint_return(r1).
spouse(bob, alice).

% Bob is 66 years old. Alice is 64 years old.
age(bob, 66).
age(alice, 64).

% Bob is blind.
is_blind(bob).

% Their adjusted gross income is $100,000.
adjusted_gross_income(r1, 100000).

% They do not itemize their deductions.
itemizes_deductions(r1, false).

% They have one child, Charles, who is 10 years old.
child_of(charles, bob).
child_of(charles, alice).
age(charles, 10).

% Charles lives with them.
has_same_principal_place_of_abode(charles, r1).

% Charles has no income.
gross_income(charles, 0).

% Charles does not file a joint return.
has_not_filed_joint_return(charles).


% Query to solve the case
% QUESTION: What is the amount of tax imposed on Bob and Alice?
case_query(Result) :-
    (   tax_imposed(r1, Tax)
    ->  Result = Tax
    ;   Result = 0
    ).
```

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT