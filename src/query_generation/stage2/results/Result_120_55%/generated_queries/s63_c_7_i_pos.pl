% Stage 2 Generated Query
% Case: s63_c_7_i_pos
% Question: Under section 63(c)(7)(i), Alice's basic standard deduction in 2019 is equal to $18000. Entailment

answer('s63_c_7_i_pos', Result) :- (s63_c_7_i(2019, 18000) -> Result = true ; Result = false).
