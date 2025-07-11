answer(s1_a_1_i_pos, Result) :-
    fact(s1_a_1_i_pos, gross_income(alice, 2015, GI)),
    s1_a_1_i_tax_imposed(s1_a_1_i_pos, alice, 2015, GI, TaxImposed),
    TaxImposed > 0,
    Result = true.

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT