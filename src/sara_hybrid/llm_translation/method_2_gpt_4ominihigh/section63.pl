% File: section63.pl
:- module(section63,[taxable_income/4, standard_deduction/3, additional_standard/3]).

%% taxable_income(GrossIncome, ItemizedD, StandardD, TI)
taxable_income(GI, Itemized, Std, TI) :-
    ( Itemized > 0 ->
        TI is GI - Itemized
    ;   TI is GI - Std
    ).

%% standard_deduction(Status, AGI, SD)
standard_deduction(Status, AGI, SD) :-
    basic_standard(Status, Base),
    additional_standard(Status, AGI, Add),
    SD is Base + Add.

basic_standard(joint,   2 * 3000).   % 200% of 3,000 for 2018–2025
basic_standard(surviving_spouse, 2*3000).
basic_standard(head_of_household, 18000).
basic_standard(single, 12000).
basic_standard(married_separate, 12000).

%% additional_standard(Status, AGI, Add)
additional_standard(_, AGI, 0) :-
    AGI < 0, !.
additional_standard(_, _, 0).  % unless aged/blind; handled below

%% Section 63(f)
% additional_standard(Person, AGI, 600 or 750 per aged/blind)
additional_standard(_, _, 0).  % placeholder: rely on per-case facts