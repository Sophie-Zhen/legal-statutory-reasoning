% File: section1.pl
:- module(section1,[tax/3]).

%% tax(Status, TaxableIncome, Tax).
%% Status = joint | surviving_spouse | head_of_household | single | married_separate

% Married filing jointly & surviving spouse
tax(joint, TI, Tax) :-
    TI =< 36900,             Tax is TI * 0.15.
tax(joint, TI, Tax) :-
    TI >  36900, TI =< 89150, Tax is 5535    + (TI-36900)*0.28.
tax(joint, TI, Tax) :-
    TI >  89150, TI =<140000, Tax is 20165   + (TI-89150)*0.31.
tax(joint, TI, Tax) :-
    TI > 140000, TI =<250000, Tax is 35928.5 + (TI-140000)*0.36.
tax(joint, TI, Tax) :-
    TI > 250000,              Tax is 75528.5 + (TI-250000)*0.396.

% Surviving spouse uses the same brackets
tax(surviving_spouse, TI, Tax) :-
    tax(joint, TI, Tax).

% Heads of household
tax(head_of_household, TI, Tax) :-
    TI =< 29600,             Tax is TI * 0.15.
tax(head_of_household, TI, Tax) :-
    TI >  29600, TI =< 76400, Tax is 4440    + (TI-29600)*0.28.
tax(head_of_household, TI, Tax) :-
    TI >  76400, TI =<127500, Tax is 17544   + (TI-76400)*0.31.
tax(head_of_household, TI, Tax) :-
    TI > 127500, TI =<250000, Tax is 33385   + (TI-127500)*0.36.
tax(head_of_household, TI, Tax) :-
    TI > 250000,              Tax is 77485   + (TI-250000)*0.396.

% Single (unmarried, neither surviving spouse nor head)
tax(single, TI, Tax) :-
    TI =< 22100,             Tax is TI * 0.15.
tax(single, TI, Tax) :-
    TI >  22100, TI =< 53500, Tax is 3315    + (TI-22100)*0.28.
tax(single, TI, Tax) :-
    TI >  53500, TI =<115000, Tax is 12107   + (TI-53500)*0.31.
tax(single, TI, Tax) :-
    TI > 115000, TI =<250000, Tax is 31172   + (TI-115000)*0.36.
tax(single, TI, Tax) :-
    TI > 250000,              Tax is 79772   + (TI-250000)*0.396.

% Married filing separately
tax(married_separate, TI, Tax) :-
    TI =< 18450,             Tax is TI * 0.15.
tax(married_separate, TI, Tax) :-
    TI >  18450, TI =< 44575, Tax is 2767.5  + (TI-18450)*0.28.
tax(married_separate, TI, Tax) :-
    TI >  44575, TI =< 70000, Tax is 10082.5 + (TI-44575)*0.31.
tax(married_separate, TI, Tax) :-
    TI >  70000, TI =<125000, Tax is 17964.25+ (TI-70000)*0.36.
tax(married_separate, TI, Tax) :-
    TI > 125000,              Tax is 37764.25+ (TI-125000)*0.396.