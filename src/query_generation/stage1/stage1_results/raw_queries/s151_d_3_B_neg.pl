answer(s151_d_3_B_neg, Result) :-
    fact(s151_d_3_B_neg, adjusted_gross_income(alice, 2015, AGI)),
    s151_d_3_B_applicable_percentage(s151_d_3_B_neg, alice, 2015, AGI, ComputedPercentage),
    ( round(ComputedPercentage) =\= 22 -> Result = true ; Result = false ).

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT