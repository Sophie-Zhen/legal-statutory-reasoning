answer(s2_b_1_A_i_II_pos, Result) :-
    fact(s2_b_1_A_i_II_pos, gross_income(alice, 2019, GrossIncome)),
    s2_b_1_A_i_II_applicable_percentage(s2_b_1_A_i_II_pos, alice, 2019, GrossIncome, ComputedPercentage),
    (ComputedPercentage > 0 -> Result = true; Result = false).

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT