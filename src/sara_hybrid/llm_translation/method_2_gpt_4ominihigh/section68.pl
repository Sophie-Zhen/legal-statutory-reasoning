% File: section68.pl
:- module(section68,[pease_limit/4]).

%% pease_limit(Status, AGI, ItemizedD, ReducedD)
pease_limit(Status, AGI, ItemD, NewD) :-
    applicable_amount(Status, AA),
    Excess is max(0, AGI - AA),
    Lim1 is Excess * 0.03,
    Lim2 is ItemD * 0.80,
    Reduction is min(Lim1, Lim2),
    NewD is ItemD - Reduction.

applicable_amount(joint,             300000).
applicable_amount(surviving_spouse,  300000).
applicable_amount(head_of_household, 275000).
applicable_amount(single,            250000).
applicable_amount(married_separate,  300000 / 2).